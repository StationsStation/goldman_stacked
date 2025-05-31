// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { MessagingFee, MessagingReceipt, Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { OAppRead } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppRead.sol";
import { OAppOptionsType3, EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { ReadCodecV1, EVMCallRequestV1 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface IVotingToken {
    function getPastVotes(address account, uint256 timepoint) external view returns (uint256);
}


contract VotingMachineLzRead is OAppRead, OAppOptionsType3 {
    event ProposalRegistered(bytes32 indexed proposalId, uint256 startTime, uint256 endTime);
    event LzVoteRequested(bytes32 readId, bytes32 proposalId, address voter);
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);

    /// lzRead responses are sent from arbitrary channels with Endpoint IDs in the range of
    /// `eid > 4294965694` (which is `type(uint32).max - 1600`).
    uint32 public constant READ_CHANNEL_EID_THRESHOLD = 4294965694;
    // lzRead specific channel: https://docs.layerzero.network/v2/deployments/read-contracts
    uint32 public constant READ_CHANNEL = 4294967295;
    uint16 public constant READ_MSG_TYPE = 0;

    address public immutable votingToken;
    uint32 public immutable governorChainId;

    mapping(bytes32 => VoteRequest) public pendingVotes;
    mapping(bytes32 => mapping(address => uint256)) public voteWeight;
    mapping(bytes32 => uint256) public totalNumVotes;
    mapping(bytes32 => mapping(address => bool)) public hasVoted;
    mapping(bytes32 => uint256) public proposalSnapshots;
    mapping(bytes32 => uint256) public proposalSnapshotEndTimes;

    struct VoteRequest {
        bytes32 proposalId;
        address voter;
    }

    constructor(address _endpoint, address _votingToken, uint256 _governorChainId)
        OAppRead(_endpoint, msg.sender) Ownable(msg.sender)
    {
        votingToken = _votingToken;
        governorChainId = uint32(_governorChainId);
    }

    /// @notice Internal function to handle incoming messages and read responses.
    /// @dev Filters messages based on `srcEid` to determine the type of incoming data.
    /// @param _origin The origin information containing the source Endpoint ID (`srcEid`).
    /// @param _guid The unique identifier for the received message.
    /// @param _message The encoded message data.
    /// @param _executor The executor address.
    /// @param _extraData Additional data.
    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) internal virtual override {
        /**
         * @dev The `srcEid` (source Endpoint ID) is used to determine the type of incoming message.
         * - If `srcEid` is greater than READ_CHANNEL_EID_THRESHOLD (4294965694),
         *   it corresponds to arbitrary channel IDs for lzRead responses.
         * - All other `srcEid` values correspond to standard LayerZero messages.
         */
        if (_origin.srcEid > READ_CHANNEL_EID_THRESHOLD) {
            // Handle lzRead responses from arbitrary channels.
            _readLzReceive(_origin, _guid, _message, _executor, _extraData);
        } else {
            // Handle standard LayerZero messages.
            _messageLzReceive(_origin, _guid, _message, _executor, _extraData);
        }
    }

    /// @notice Internal function to handle standard LayerZero messages.
    /// @dev _origin The origin information (unused in this implementation).
    /// @dev _guid The unique identifier for the received message (unused in this implementation).
    /// @param _message The encoded message data.
    /// @dev _executor The executor address (unused in this implementation).
    /// @dev _extraData Additional data (unused in this implementation).
    function _messageLzReceive(
        Origin calldata /* _origin */,
        bytes32 /* _guid */,
        bytes calldata _message,
        address /* _executor */,
        bytes calldata /* _extraData */
    ) internal virtual {
        (bytes32 proposalId, uint256 startTime, uint256 endTime) = abi.decode(_message, (bytes32, uint256, uint256));
        require(proposalSnapshots[proposalId] == 0, "Snapshot already set");

        proposalSnapshots[proposalId] = startTime;
        proposalSnapshotEndTimes[proposalId] = endTime;

        emit ProposalRegistered(proposalId, startTime, endTime);
    }

    /// @notice Internal function to handle lzRead responses.
    /// @notice For the simplicity no sync is taken care of such that users don't vote more than from one chain.
    /// @dev _origin The origin information (unused in this implementation).
    /// @dev _guid The unique identifier for the received message (unused in this implementation).
    /// @param _message The encoded message data.
    /// @dev _executor The executor address (unused in this implementation).
    /// @dev _extraData Additional data (unused in this implementation).
    function _readLzReceive(
        Origin calldata /* _origin */,
        bytes32 _guid,
        bytes calldata _message,
        address /* _executor */,
        bytes calldata /* _extraData */
    ) internal virtual {
        VoteRequest memory vote = pendingVotes[_guid];
        require(!hasVoted[vote.proposalId][vote.voter], "Already voted");

        uint256 power = abi.decode(_message, (uint256));
        require(power > 0, "Voting power is zero");
        voteWeight[vote.proposalId][vote.voter] = power;
        totalNumVotes[vote.proposalId] += power;
        hasVoted[vote.proposalId][vote.voter] = true;

        // Matching proposal Id vote cast on L1
        // Note: by default the count is always For
        emit VoteCast(vote.voter, uint256(vote.proposalId), uint8(1), power, "");

        delete pendingVotes[_guid];
    }

    /// @dev Constructs a command to query votes of msg.sender on a Governor chain Id.
    /// @param startTime Proposal voting start time.
    /// @return The encoded request.
    function _getCmd(uint256 startTime) internal view returns (bytes memory) {
        bytes memory callData = abi.encodeWithSelector(IVotingToken.getPastVotes.selector, msg.sender, startTime);

        EVMCallRequestV1[] memory readRequests = new EVMCallRequestV1[](1);
        readRequests[0] = EVMCallRequestV1({
            appRequestLabel: uint16(0),
            targetEid: uint32(governorChainId),
            isBlockNum: false,
            blockNumOrTimestamp: uint64(block.timestamp),
            confirmations: 15,
            to: votingToken,
            callData: callData
        });

        return ReadCodecV1.encode(0, readRequests);
    }

    /// @dev Sends a read request to LayerZero, querying votes of msg.sender on a Governor chain Id.
    /// @param proposalId Proposal Id.
    /// @return receipt The LayerZero messaging receipt for the request.
    function getVotesLzRead(
        bytes32 proposalId,
        bytes calldata extraOptions
    ) external payable returns (MessagingReceipt memory receipt) {
        require(block.timestamp <= proposalSnapshotEndTimes[proposalId], "Voting has ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        uint256 startTime = proposalSnapshots[proposalId];
        require(startTime > 0, "Proposal Id is not registered");
        require(block.timestamp >= startTime, "Voting has not started yet");

        bytes memory cmd = _getCmd(startTime);

        MessagingFee memory fee = _quote(READ_CHANNEL, cmd, extraOptions, false);
        require(msg.value >= fee.nativeFee);

        receipt =
            _lzSend(
                READ_CHANNEL,
                cmd,
                combineOptions(READ_CHANNEL, READ_MSG_TYPE, extraOptions),
                MessagingFee(msg.value, 0),
                payable(msg.sender)
            );

        pendingVotes[receipt.guid] = VoteRequest(proposalId, msg.sender);

        emit LzVoteRequested(receipt.guid, proposalId, msg.sender);
    }

    function quote(uint256 startTime, bytes calldata _options) external view returns (uint256, uint256) {
        bytes memory cmd = _getCmd(startTime);
        MessagingFee memory fee = _quote(governorChainId, cmd, _options, false);
        return (fee.nativeFee, fee.lzTokenFee);
    }

    function getVoteWeight(bytes32 proposalId, address voter) external view returns (uint256) {
        return voteWeight[proposalId][voter];
    }
}
