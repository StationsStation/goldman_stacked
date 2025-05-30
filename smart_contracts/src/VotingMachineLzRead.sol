// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { MessagingFee, MessagingReceipt, Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { OAppRead } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppRead.sol";
import { OAppOptionsType3, EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { ReadCodecV1, EVMCallRequestV1 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface IVotingToken {
    function getVotes(address account, uint256 ts) external view returns (uint256);
}


contract VotingMachineLzRead is OAppRead, OAppOptionsType3 {
    event LzVoteRequested(bytes32 readId, bytes32 proposalId, address voter);
    event VoteCast(bytes32 proposalId, address voter, uint256 weight);

    address public immutable votingToken;
    address public immutable governor;
    uint256 public immutable governorChainId;

    mapping(bytes32 => VoteRequest) public pendingVotes;
    mapping(bytes32 => mapping(address => uint256)) public voteWeight;
    mapping(bytes32 => mapping(address => bool)) public hasVoted;
    mapping(bytes32 => uint256) public proposalSnapshots;

    struct VoteRequest {
        bytes32 proposalId;
        address voter;
    }

    constructor(address _endpoint, address _delegate, address _votingToken, address _governor, uint256 _governorChainId)
        OAppRead(_endpoint, _delegate) Ownable(_delegate)
    {
        votingToken = _votingToken;
        governor = _governor;
        governorChainId = _governorChainId;
    }

    function registerSnapshot(bytes32 proposalId, uint256 snapshotBlock) external {
        require(proposalSnapshots[proposalId] == 0, "Snapshot already set");
        proposalSnapshots[proposalId] = snapshotBlock;
    }

    /// @dev Handles the aggregated average price from Uniswap V3 pool responses received from LayerZero.
    /// @dev Emits the AggregatedPrice event with the calculated average amount.
    /// @param message Encoded average token output amount.
    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 guid,
        bytes calldata message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        VoteRequest memory vote = pendingVotes[guid];
        require(!hasVoted[vote.proposalId][vote.voter], "Already voted");

        uint256 power = abi.decode(message, (uint256));
        voteWeight[vote.proposalId][vote.voter] = power;
        hasVoted[vote.proposalId][vote.voter] = true;

        emit VoteCast(vote.proposalId, vote.voter, power);

        delete pendingVotes[guid];
    }

    /// @dev Constructs a command to query votes of msg.sender on a Governor chain Id.
    /// @return cmd The encoded command to request Uniswap quotes.
    function _getCmd() internal view returns (bytes memory) {
        bytes memory callData = abi.encodeWithSelector(IVotingToken.getVotes.selector, msg.sender, block.timestamp);

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
    /// @return receipt The LayerZero messaging receipt for the request.
    function getVotesLzRead(
        bytes32 proposalId,
        bytes calldata extraOptions
    ) external payable returns (MessagingReceipt memory receipt) {
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        bytes memory cmd = _getCmd();
        receipt =
            _lzSend(
                uint32(governorChainId),
                cmd,
                combineOptions(uint32(governorChainId), uint16(0), extraOptions),
                MessagingFee(msg.value, 0),
                payable(msg.sender)
            );

        pendingVotes[receipt.guid] = VoteRequest(proposalId, msg.sender);
        emit LzVoteRequested(receipt.guid, proposalId, msg.sender);
    }

    function quote(bytes calldata _options) external view returns (uint256 nativeFee, uint256 lzTokenFee) {
        bytes memory cmd = _getCmd();
        MessagingFee memory fee = _quote(uint32(governorChainId), cmd, _options, false);
        return (fee.nativeFee, fee.lzTokenFee);
    }

    function getVoteWeight(bytes32 proposalId, address voter) external view returns (uint256) {
        return voteWeight[proposalId][voter];
    }

    function totalVotes(bytes32 proposalId, address[] calldata voters) public view returns (uint256 total) {
        for (uint256 i = 0; i < voters.length; i++) {
            total += voteWeight[proposalId][voters[i]];
        }
    }
}

