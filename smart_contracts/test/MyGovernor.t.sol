// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/MyGovernor.sol";
import "../src/VotingToken.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";

// Mock GovernorRelay
contract MockGovernorRelay is IGovernorRelay {
    bytes32 public lastProposalId;
    uint256 public lastStartTime;
    uint256 public lastEndTime;
    bytes public lastOptions;
    bytes32 public lastFinalizeProposalId;
    bytes public lastFinalizeOptions;

    function sendProposalDetails(
        bytes32 proposalId,
        uint256 startTime,
        uint256 endTime,
        bytes calldata options
    ) external payable {
        lastProposalId = proposalId;
        lastStartTime = startTime;
        lastEndTime = endTime;
        lastOptions = options;
    }

    function finalizeProposalVotes(
        bytes32 proposalId,
        bytes calldata options
    ) external payable {
        lastFinalizeProposalId = proposalId;
        lastFinalizeOptions = options;
    }
}

contract MyGovernorTest is Test {
    MyGovernor public governor;
    VotingToken public token;
    TimelockController public timelock;
    MockGovernorRelay public relay;

    address public constant OWNER = address(1);
    address public constant VOTER = address(2);
    address[] public proposers;
    address[] public executors;

    function setUp() public {
        vm.startPrank(OWNER);
        
        // Deploy token - 1_000_000 tokens are minted to OWNER
        token = new VotingToken();
        
        // Setup timelock roles
        proposers = new address[](1);
        proposers[0] = OWNER;
        executors = new address[](1);
        executors[0] = OWNER;
        
        // Deploy timelock
        timelock = new TimelockController(
            1 days, // minDelay
            proposers,
            executors,
            OWNER
        );
        
        // Deploy relay
        relay = new MockGovernorRelay();
        
        // Deploy governor
        governor = new MyGovernor(
            token,
            timelock,
            address(relay)
        );
        
        // Setup roles
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 cancellerRole = timelock.CANCELLER_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0)); // Anyone can execute
        timelock.grantRole(cancellerRole, OWNER);
        
        // Transfer tokens to voter instead of minting
        token.transfer(VOTER, 100 ether);
        
        // Delegate voting power to self
        vm.stopPrank();
        
        vm.startPrank(VOTER);
        token.delegate(VOTER);
        vm.stopPrank();
    }

    function testInitialSetup() public {
        assertEq(address(governor.token()), address(token));
        assertEq(address(governor.timelock()), address(timelock));
        assertEq(address(governor.governorRelay()), address(relay));
        assertEq(token.balanceOf(OWNER), 1_000_000 ether - 100 ether); // Initial supply minus transferred
        assertEq(token.balanceOf(VOTER), 100 ether);
    }

    function testPropose() public {
        // Prepare proposal
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("transfer(address,uint256)", VOTER, 1 ether);
        
        string memory description = "Transfer tokens to voter";
        bytes memory options = "";

        // Create proposal
        vm.prank(VOTER);
        uint256 proposalId = governor.propose(targets, values, calldatas, description, options);

        // Verify proposal was created
        assertEq(uint256(relay.lastProposalId()), proposalId);
        assertEq(relay.lastStartTime(), governor.proposalSnapshot(proposalId));
        assertEq(relay.lastEndTime(), governor.proposalDeadline(proposalId));
        assertEq(relay.lastOptions(), options);
    }

    function testVotingDelay() public {
        assertEq(governor.votingDelay(), 1 minutes);
    }

    function testVotingPeriod() public {
        assertEq(governor.votingPeriod(), 1 hours);
    }

    function testProposalLifecycle() public {
        uint256 initialVoterBalance = token.balanceOf(VOTER);
        
        // Transfer tokens to timelock for proposal execution
        vm.startPrank(OWNER);
        token.transfer(address(timelock), 10 ether); // Transfer enough tokens for the proposal
        vm.stopPrank();
        
        // Prepare proposal
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("transfer(address,uint256)", VOTER, 1 ether);
        
        string memory description = "Transfer tokens to voter";
        bytes memory options = "";

        // Create proposal
        vm.startPrank(VOTER);
        uint256 proposalId = governor.propose(targets, values, calldatas, description, options);
        
        // Wait for voting delay and advance blocks
        vm.roll(block.number + governor.votingDelay() + 1);
        vm.warp(block.timestamp + governor.votingDelay() + 1);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Active));

        // Vote
        governor.castVote(proposalId, 1); // Vote in favor

        // Wait for voting period to end and advance blocks
        vm.roll(block.number + governor.votingPeriod() + 1);
        vm.warp(block.timestamp + governor.votingPeriod() + 1);

        // Finalize votes before checking state
        bytes memory finalizeOptions = "";
        governor.finalizeProposalVotes(proposalId, finalizeOptions);
        
        // Mock the relay recording the votes
        vm.stopPrank();
        vm.prank(address(relay));
        governor.recordFinalizedProposalVotes(proposalId, 100 ether); // Add significant voting power
        vm.startPrank(VOTER);

        // Wait for a few blocks to ensure state is updated
        vm.roll(block.number + 5);
        vm.warp(block.timestamp + 5);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Succeeded));

        // Queue
        bytes32 descHash = keccak256(bytes(description));
        governor.queue(targets, values, calldatas, descHash);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Queued));

        // Wait for timelock and advance blocks
        vm.roll(block.number + 5);
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);

        // Execute
        governor.execute(targets, values, calldatas, descHash);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Executed));
        
        vm.stopPrank();

        // Verify execution
        assertEq(token.balanceOf(VOTER), initialVoterBalance + 1 ether);
    }

    function testCancelProposal() public {
        // Prepare proposal
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("transfer(address,uint256)", VOTER, 1 ether);
        
        string memory description = "Transfer tokens to voter";
        bytes memory options = "";

        // Create proposal as VOTER
        vm.prank(VOTER);
        uint256 proposalId = governor.propose(targets, values, calldatas, description, options);
        
        // Wait for one block
        vm.roll(block.number + 1);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Pending));

        // Cancel proposal as the proposer (VOTER)
        vm.prank(VOTER);
        bytes32 descHash = keccak256(bytes(description));
        governor.cancel(targets, values, calldatas, descHash);
        
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Canceled));
    }

    function testRecordFinalizedProposalVotes() public {
        // Create a proposal
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("transfer(address,uint256)", VOTER, 1 ether);
        string memory description = "Transfer tokens to voter";
        bytes memory options = "";

        vm.prank(VOTER);
        uint256 proposalId = governor.propose(targets, values, calldatas, description, options);

        // Record finalized votes as the relay
        vm.prank(address(relay));
        governor.recordFinalizedProposalVotes(proposalId, 1000);

        // Verify the votes were recorded
        assertEq(governor.mapFinalizedProposalIdCounts(proposalId), 1000);
    }
} 