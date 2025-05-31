// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

/// @title Timelock - Smart contract for the timelock
contract Timelock is TimelockController {
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors)
        TimelockController(minDelay, proposers, executors, msg.sender)
    {}
}