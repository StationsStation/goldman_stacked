// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { OApp } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";


contract VotingMachineLzReadHedera is OApp {
    event ProposalRegistered(bytes32 indexed proposalId, uint256 startTime, uint256 endTime);
    event LzVoteRequested(bytes32 readId, bytes32 proposalId, address voter);
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);

    uint32 public immutable governorChainId;

    mapping(bytes32 => mapping(address => uint256)) public voteWeight;
    mapping(bytes32 => uint256) public totalNumVotes;
    mapping(bytes32 => mapping(address => bool)) public hasVoted;
    mapping(bytes32 => uint256) public proposalSnapshots;
    mapping(bytes32 => uint256) public proposalSnapshotEndTimes;

    struct VoteRequest {
        bytes32 proposalId;
        address voter;
    }

    constructor()
        OApp(0x1a44076050125825900e736c501f859c50fE728c, 0x52370eE170c0E2767B32687166791973a0dE7966) Ownable(0x52370eE170c0E2767B32687166791973a0dE7966)
    {
        governorChainId = uint32(30184);
    }

    /// @notice Internal function to handle incoming messages and read responses.
    /// @dev Filters messages based on `srcEid` to determine the type of incoming data.
    /// @param _message The encoded message data.
    function _lzReceive(
        Origin calldata /* _origin */,
        bytes32 /* _guid */,
        bytes calldata _message,
        address /* _executor */,
        bytes calldata /* _extraData */
    ) internal virtual override {
        (bytes32 proposalId, uint256 startTime, uint256 endTime) = abi.decode(_message, (bytes32, uint256, uint256));
        require(proposalSnapshots[proposalId] == 0, "Snapshot already set");

        proposalSnapshots[proposalId] = startTime;
        proposalSnapshotEndTimes[proposalId] = endTime;

        emit ProposalRegistered(proposalId, startTime, endTime);
    }

    /// @dev Sends a read request to LayerZero, querying votes of msg.sender on a Governor chain Id.
    /// @param proposalId Proposal Id.
    /// @param power Voting power.
    function getVotesLzRead(bytes32 proposalId, uint256 power) external {
        require(block.timestamp <= proposalSnapshotEndTimes[proposalId], "Voting has ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        uint256 startTime = proposalSnapshots[proposalId];
        require(startTime > 0, "Proposal Id is not registered");
        require(block.timestamp >= startTime, "Voting has not started yet");

        emit LzVoteRequested(0, proposalId, msg.sender);

        voteWeight[proposalId][msg.sender] = power;
        totalNumVotes[proposalId] += power;
        hasVoted[proposalId][msg.sender] = true;

        // Matching proposal Id vote cast on L1
        // Note: by default the count is always For
        emit VoteCast(msg.sender, uint256(proposalId), uint8(1), power, "");
    }

    function getVoteWeight(bytes32 proposalId, address voter) external view returns (uint256) {
        return voteWeight[proposalId][voter];
    }
}
