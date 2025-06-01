// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

interface IGovernorRelay {
    function sendProposalDetails(bytes32 proposalId, uint256 startTime, uint256 endTime, bytes calldata options) external payable;
    function finalizeProposalVotes(bytes32 proposalId, bytes calldata options) external payable;
}

contract MyGovernor is Governor, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {
    event GovernorRelayUpdated(address indexed newGovernorRelay);
    event ProposalIdCountsRecorded(uint256 indexed proposalId, uint256 totalNumVotes);

    address public immutable governorRelay;

    mapping(uint256 => uint256) public mapFinalizedProposalIdCounts;

    constructor(IVotes _token, TimelockController _timelock, address _governorRelay)
        Governor("MyGovernor")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(0)
        GovernorTimelockControl(_timelock)
    {
        governorRelay = _governorRelay;
    }

    /// @notice Apparently this is in blocks.
    function votingDelay() public pure override returns (uint256) {
        return 30;
    }

    /// @notice Apparently this is in blocks.
    function votingPeriod() public pure override returns (uint256) {
        return 1_000;
    }

    /// @dev Create a new proposal to change the protocol / contract parameters and send its snapshot details cross-chain.
    /// @param targets The ordered list of target addresses for calls to be made during proposal execution.
    /// @param values The ordered list of values to be passed to the calls made during proposal execution.
    /// @param calldatas The ordered list of data to be passed to each individual function call during proposal execution.
    /// @param description A human readable description of the proposal and the changes it will enact.
    /// @param options Cross-chain options.
    /// @return proposalId The Id of the newly created proposal.
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        bytes calldata options
    ) external payable returns (uint256 proposalId)
    {
        proposalId = super.propose(targets, values, calldatas, description);
        uint256 startTime = proposalSnapshot(proposalId);
        uint256 endTime = proposalDeadline(proposalId);

        IGovernorRelay(governorRelay).sendProposalDetails{value: msg.value}(bytes32(proposalId), startTime, endTime, options);
    }

    function finalizeProposalVotes(uint256 proposalId, bytes calldata options) external payable {
        ProposalState curState = super.state(proposalId);

        // Check that the proposal is not yet finalized
        if (curState == ProposalState.Defeated || curState == ProposalState.Succeeded) {
            require(mapFinalizedProposalIdCounts[proposalId] == 0, "Proposal is already finalized");

            IGovernorRelay(governorRelay).finalizeProposalVotes{value: msg.value}(bytes32(proposalId), options);
        }
    }

    function recordFinalizedProposalVotes(uint256 proposalId, uint256 totalNumVotes) external {
        require(msg.sender == governorRelay, "Only governor relay");

        mapFinalizedProposalIdCounts[proposalId] = totalNumVotes;

        emit ProposalIdCountsRecorded(proposalId, totalNumVotes);
    }

    /// @notice For the sake of simplicity we only vote For cross-chain.
    function proposalVotes(uint256 proposalId) public view override returns (uint256, uint256 forVotes, uint256) {
        // Get for votes
        (, forVotes, ) = super.proposalVotes(proposalId);

        // Add cross-chain obtained votes into the proposal votes on a main governing chain
        forVotes += mapFinalizedProposalIdCounts[proposalId];

        return (0, forVotes, 0);
    }

    /// @notice For the sake of simplicity we only vote For cross-chain.
    function _quorumReached(uint256 proposalId) internal view override(Governor, GovernorCountingSimple) returns (bool) {
        // Get for votes
        (, uint256 forVotes, ) = proposalVotes(proposalId);

        return quorum(proposalSnapshot(proposalId)) <= forVotes;
    }

    /// @notice For the sake of simplicity we only vote For cross-chain.
    function _voteSucceeded(uint256 proposalId) internal view override(Governor, GovernorCountingSimple) returns (bool) {
        // Get for votes
        (, uint256 forVotes, ) = proposalVotes(proposalId);

        return forVotes > 0;
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState curState)
    {
        curState = super.state(proposalId);

        // Check that the proposal is finalized
        if (curState == ProposalState.Defeated || curState == ProposalState.Succeeded) {
            require(mapFinalizedProposalIdCounts[proposalId] > 0, "Proposal voting has ended, but was not finalized yet");
        }
    }

    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function _queueOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint48)
    {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }
}
