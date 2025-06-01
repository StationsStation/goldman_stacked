// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { MessagingFee, MessagingReceipt, Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { OAppRead } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppRead.sol";
import { OAppOptionsType3, EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { ReadCodecV1, EVMCallRequestV1, EVMCallComputeV1 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface IVotingMachine {
    function totalNumVotes(bytes32 proposalId) external returns (uint256);
}

interface IGovernor {
    function recordFinalizedProposalVotes(uint256 proposalId, uint256 totalNumVotes) external;
}

interface IMessagingChannel {
    function eid() external view returns (uint32);
}


contract GovernorRelayLZ is OAppRead, OAppOptionsType3 {
    event GovernorUpdated(address indexed governor);
    event VotingMachinesUpdated(address[] votingMachines);
    event LZProposed(bytes32 indexed proposalId, uint256 startTime, uint256 endTime);
    event LZTotalNumVotesCounted(bytes32 indexed proposalId, uint256 totalNumVotes);
    event LZProposalFinalizationInitiated(bytes32 indexed proposalId, bytes32 indexed guid);

    /// lzRead responses are sent from arbitrary channels with Endpoint IDs in the range of
    /// `eid > 4294965694` (which is `type(uint32).max - 1600`).
    uint32 public constant READ_CHANNEL_EID_THRESHOLD = 4294965694;
    // lzRead specific channel: https://docs.layerzero.network/v2/deployments/read-contracts
    uint32 public constant READ_CHANNEL = 4294967295;
    uint16 public constant READ_MSG_TYPE = 0;
    uint8 internal constant REDUCE_ONLY = 1;

    uint256 public immutable numChains;
    // Some chains don't support LzRead, but we don't want to limit those not to vote
    uint256 public immutable numLzReadSupportedChains;

    address[] public votingMachines;

    uint32[] public remoteChainIds;
    // Some chains don't support LzRead, but we don't want to limit those not to vote
    // Note that LzReduce is going to be executed over supported chains only
    uint32[] public remoteLzReadSupportedChainIds;

    address public governor;

    mapping(bytes32 => bytes32) public pendingVoteCounts;

    constructor(
        address _endpoint,
        uint256[] memory _remoteChianIds,
        uint256[] memory _remoteLzReadSupportedChainIds
    )
        OAppRead(_endpoint, msg.sender) Ownable(msg.sender)
    {
        require(_remoteChianIds.length > 0, "Zero length array");

        remoteChainIds = new uint32[](_remoteChianIds.length);
        votingMachines = new address[](_remoteChianIds.length);
        remoteLzReadSupportedChainIds = new uint32[](_remoteLzReadSupportedChainIds.length);

        for (uint256 i = 0; i < _remoteChianIds.length; ++i) {
            remoteChainIds[i] = uint32(_remoteChianIds[i]);
        }
        for (uint256 i = 0; i < _remoteLzReadSupportedChainIds.length; ++i) {
            remoteLzReadSupportedChainIds[i] = uint32(_remoteLzReadSupportedChainIds[i]);
        }

        numChains = _remoteChianIds.length;
        numLzReadSupportedChains = _remoteLzReadSupportedChainIds.length;
    }

    function changeGovernor(address newGovernor) external {
        governor = newGovernor;

        emit GovernorUpdated(newGovernor);
    }

    function changeVotingMachines(address[] memory newVotingMachines) external {
        require(msg.sender == owner(), "Owner only");

        require(newVotingMachines.length == votingMachines.length, "Wrong array length");
        for (uint256 i = 0; i < numChains; ++i) {
            votingMachines[i] = newVotingMachines[i];
        }

        emit VotingMachinesUpdated(newVotingMachines);
    }

    /// @notice Thanks for making it virtual :).
    function _payNative(uint256 _nativeFee) internal override returns (uint256 nativeFee) {
        require(msg.value >= _nativeFee, "NotEnoughNative");
        return _nativeFee;
    }

    function sendProposalDetails(bytes32 proposalId, uint256 startTime, uint256 endTime, bytes calldata options) external payable {
        require(msg.sender == governor, "Only governor");

        bytes memory payload = abi.encode(proposalId, startTime, endTime);

        uint256 totalFee;
        uint256[] memory fees = new uint256[](numChains);
        for (uint256 i = 0; i < numChains; ++i) {
            MessagingFee memory fee = _quote(remoteChainIds[i], payload, options, false);
            fees[i] = fee.nativeFee;
            totalFee += fee.nativeFee;
        }

        require(msg.value >= totalFee);

        // Allow to vote for all the chains
        for (uint256 i = 0; i < numChains; ++i) {
            _lzSend(
                remoteChainIds[i], // Destination chain's endpoint ID.
                payload, // Encoded message payload being sent.
                options, // Message execution options (e.g., gas to use on destination).
                MessagingFee(fees[i], 0), // Fee struct containing native gas and ZRO token.
                payable(tx.origin) // The refund address in case the send call reverts.
            );
        }

        emit LZProposed(proposalId, startTime, endTime);
    }

    /// @notice Internal function to handle message responses.
    /// @dev _origin The origin information (unused in this implementation).
    /// @dev _guid The unique identifier for the received message (unused in this implementation).
    /// @param _message The encoded message data.
    /// @dev _executor The executor address (unused in this implementation).
    /// @dev _extraData Additional data (unused in this implementation).
    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address /* _executor */,
        bytes calldata /* _extraData */
    ) internal override {
        require(_origin.srcEid > READ_CHANNEL_EID_THRESHOLD, "LZ Read receives only");

        uint256 totalNumVotes = abi.decode(_message, (uint256));

        bytes32 proposalId = pendingVoteCounts[_guid];

        IGovernor(governor).recordFinalizedProposalVotes(uint256(proposalId), totalNumVotes);

        emit LZTotalNumVotesCounted(proposalId, totalNumVotes);
    }

    /// @dev Constructs a command to query votes of msg.sender on a Governor chain Id.
    /// @param proposalId Proposal Id.
    /// @return The encoded request.
    function _getCmd(bytes32 proposalId) internal view returns (bytes memory) {
        bytes memory callData = abi.encodeWithSelector(IVotingMachine.totalNumVotes.selector, proposalId);

        EVMCallRequestV1[] memory readRequests = new EVMCallRequestV1[](numLzReadSupportedChains);
        for (uint256 i = 0; i < numLzReadSupportedChains; ++i) {
            readRequests[i] = EVMCallRequestV1({
                appRequestLabel: uint16(0),
                targetEid: remoteLzReadSupportedChainIds[i],
                isBlockNum: false,
                blockNumOrTimestamp: uint64(block.timestamp),
                confirmations: 15,
                to: votingMachines[i],
                callData: callData
            });
        }

        EVMCallComputeV1 memory computeSettings = EVMCallComputeV1({
            computeSetting: REDUCE_ONLY,
            targetEid: IMessagingChannel(address(endpoint)).eid(),
            isBlockNum: false,
            blockNumOrTimestamp: uint64(block.timestamp),
            confirmations: 15,
            to: address(this)
        });

        return ReadCodecV1.encode(0, readRequests, computeSettings);
    }

    /// @notice For the simplicity no sync is taken care of such that users don't vote more than from one chain.
    function finalizeProposalVotes(bytes32 proposalId, bytes calldata extraOptions) external payable {
        require(msg.sender == governor, "Only governor");

        bytes memory payload = _getCmd(proposalId);

        // TODO Figure out the correct quote check
        //MessagingFee memory fee = _quote(READ_CHANNEL, payload, extraOptions, false);
        //require(msg.value >= fee.nativeFee);

        MessagingReceipt memory receipt =
            _lzSend(
                READ_CHANNEL,
                payload,
                combineOptions(READ_CHANNEL, READ_MSG_TYPE, extraOptions),
                MessagingFee(msg.value, 0),
                payable(tx.origin)
            );

        pendingVoteCounts[receipt.guid] = proposalId;

        emit LZProposalFinalizationInitiated(proposalId, receipt.guid);
    }

    function lzReduce(bytes calldata, bytes[] calldata _responses) external pure returns (bytes memory) {
        //require(_responses.length == 3, "Expected responses from 3 chains");
        uint256 totalNumVotes = 0;
        for (uint256 i = 0; i < _responses.length; i++) {
            uint256 amountOut = abi.decode(_responses[i], (uint256));
            totalNumVotes += amountOut;
        }

        return abi.encode(totalNumVotes);
    }
}

