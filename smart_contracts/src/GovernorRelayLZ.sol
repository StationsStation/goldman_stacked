// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract GovernorRelayLZ {
    address public immutable trustedExecutor;
    address public immutable governor;

    constructor(address _trustedExecutor, address _governor) {
        trustedExecutor = _trustedExecutor;
        governor = _governor;
    }

    function receiveVote(bytes calldata payload) external {
        require(msg.sender == trustedExecutor, "Only trusted executor");

        (bytes32 proposalId, uint256 totalVotes) = abi.decode(payload, (bytes32, uint256));

        (bool ok, ) = governor.call(
            abi.encodeWithSignature("relayResult(bytes32,uint256)", proposalId, totalVotes)
        );
        require(ok, "Governor call failed");
    }
}

