// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

interface IGovernanceExecutor {
    function execute(
        address makerAsset,
        address takerAsset,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes memory predicate,
        bytes memory permit,
        bytes memory interaction
    ) external;
}

interface IGovernor {
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
    ) external payable returns (uint256 proposalId);
}

/// @title CallProposeBase
contract CallProposeBase is Script {
    using OptionsBuilder for bytes;

    // Gas limit for the executor
    uint128 public constant GAS_LIMIT = 1000000;
    // msg.value for the lzReceive() function on destination in wei
    uint128 public constant MSG_VALUE = 0;

    function run() external {
        address governor = address(0x3070692B3A338ac2B583419c33CFeE641FC10c26);
        address governanceExecutor = address(0xBF5609fD47508143b7E9A1dcf0B814fFDB451FF0);
        address signer = address(0x52370eE170c0E2767B32687166791973a0dE7966);

        address makerAsset = address(0x9d0E8f5b25384C7310CB8C6aE32C8fbeb645d083);
        address takerAsset = address(0x4200000000000000000000000000000000000006);

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT, MSG_VALUE);
        address[] memory targets = new address[](1);
        targets[0] = governanceExecutor;
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = signer;
        values[0] = 0;
        calldatas[0] = abi.encodeCall(IGovernanceExecutor.execute, (makerAsset, takerAsset, 100, 100, "", "", ""));
        string memory description = "Limit order 1";

        //MessagingFee memory fee = _quote(31084, cmd, options, false);

        vm.startBroadcast(signer);
        IGovernor(governor).propose{value: 1000000000000000}(targets, values, calldatas, description, options);
        vm.stopBroadcast();
    }
}
