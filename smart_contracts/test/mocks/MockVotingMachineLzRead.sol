// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./MockTypes.sol";
import "./MockOAppRead.sol";

// Mock VotingMachineLzRead that uses our mocks
contract MockVotingMachineLzRead is MockOAppReadWithOptions {
    address public immutable votingToken;
    uint256 public immutable governorChainId;

    mapping(bytes32 => VoteRequest) public pendingVotes;
    mapping(bytes32 => mapping(address => uint256)) public voteWeight;
    mapping(bytes32 => mapping(address => bool)) public hasVoted;
    mapping(bytes32 => uint256) public proposalSnapshots;
    mapping(bytes32 => uint256) public proposalSnapshotEndTimes;

    struct VoteRequest {
        bytes32 proposalId;
        address voter;
    }

    constructor(
        address _endpoint,
        address _votingToken,
        uint256 _governorChainId
    ) MockOAppReadWithOptions(_endpoint, msg.sender) {
        votingToken = _votingToken;
        governorChainId = _governorChainId;
    }

    function _lzReceive(
        MockOrigin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address,
        bytes calldata
    ) internal override {
        if (_origin.srcEid == uint32(governorChainId)) {
            (bytes32 proposalId, uint256 startTime, uint256 endTime) = abi.decode(_message, (bytes32, uint256, uint256));
            require(proposalSnapshots[proposalId] == 0, "Snapshot already set");
            proposalSnapshots[proposalId] = startTime;
            proposalSnapshotEndTimes[proposalId] = endTime;
        } else if (_origin.srcEid > READ_CHANNEL_EID_THRESHOLD) {
            VoteRequest memory vote = pendingVotes[_guid];
            require(!hasVoted[vote.proposalId][vote.voter], "Already voted");
            uint256 power = abi.decode(_message, (uint256));
            require(power > 0, "Voting power is zero");
            voteWeight[vote.proposalId][vote.voter] = power;
            hasVoted[vote.proposalId][vote.voter] = true;
            delete pendingVotes[_guid];
        }
    }

    uint32 public constant READ_CHANNEL_EID_THRESHOLD = 4294965694;
    uint32 public constant READ_CHANNEL = 4294967295;
    uint16 public constant READ_MSG_TYPE = 0;

    function getVotesLzRead(
        bytes32 proposalId,
        bytes calldata extraOptions
    ) external payable returns (MockMessagingReceipt memory receipt) {
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        uint256 startTime = proposalSnapshots[proposalId];
        require(block.timestamp >= startTime, "Voting has not started yet");

        bytes memory cmd = "";  // Simplified for testing
        receipt = _lzSend(
            READ_CHANNEL,
            cmd,
            combineOptions(READ_CHANNEL, READ_MSG_TYPE, extraOptions),
            MockMessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        pendingVotes[receipt.guid] = VoteRequest(proposalId, msg.sender);
    }
} 