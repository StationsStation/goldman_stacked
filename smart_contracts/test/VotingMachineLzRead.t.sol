// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {MockEndpoint} from "./mocks/MockEndpoint.sol";
import {MockVotingMachineLzRead} from "./mocks/MockVotingMachineLzRead.sol";

contract VotingMachineLzReadTest is Test {
    MockEndpoint public endpoint;
    MockVotingMachineLzRead public votingMachine;
    address public constant VOTING_TOKEN = address(1);
    uint256 public constant GOVERNOR_CHAIN_ID = 1;

    function setUp() public {
        endpoint = new MockEndpoint(1);
        votingMachine = new MockVotingMachineLzRead(
            address(endpoint),
            VOTING_TOKEN,
            GOVERNOR_CHAIN_ID
        );
    }

    function testSetup() public {
        assertEq(address(votingMachine.endpoint()), address(endpoint));
        assertEq(votingMachine.votingToken(), VOTING_TOKEN);
        assertEq(votingMachine.governorChainId(), GOVERNOR_CHAIN_ID);
    }
} 