// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLib.sol";
import { ExecutorConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";

/// @title LayerZero Send Configuration Script
/// @notice Defines and applies ULN (DVN) config for inbound message verification via LayerZero Endpoint V2.
contract SetSendConfigHederaBase is Script {
    uint32 constant EXECUTOR_CONFIG_TYPE = 1;
    uint32 constant ULN_CONFIG_TYPE = 2;

    /// @notice Broadcasts transactions to set both Send ULN and Executor configurations
    function run() external {
        address endpoint = address(0x3A73033C0b1407574C76BdBAc67f126f6b4a9AA9);
        address oapp      = address(0x7bedCA17D29e53C8062d10902a6219F8d1E3B9B5);
        uint32 eid        = 30184;
        address sendLib   = address(0x2367325334447C5E1E0f1b3a6fB947b262F58312);
        address signer    = address(0x52370eE170c0E2767B32687166791973a0dE7966);
        address[] memory requiredDVNs = new address[](1);
        requiredDVNs[0] = address(0xce8358bc28dd8296Ce8cAF1CD2b44787abd65887);

        /// @notice ULNConfig defines security parameters (DVNs + confirmation threshold)
        /// @notice Send config requests these settings to be applied to the DVNs and Executor
        /// @dev 0 values will be interpretted as defaults, so to apply NIL settings, use:
        /// @dev uint8 internal constant NIL_DVN_COUNT = type(uint8).max;
        /// @dev uint64 internal constant NIL_CONFIRMATIONS = type(uint64).max;
        UlnConfig memory uln = UlnConfig({
            confirmations:        15,                                      // minimum block confirmations required
            requiredDVNCount:     1,                                       // number of DVNs required
            optionalDVNCount:     type(uint8).max,                         // optional DVNs count, uint8
            optionalDVNThreshold: 0,                                       // optional DVN threshold
            requiredDVNs:        requiredDVNs,                             // sorted list of required DVN addresses
            optionalDVNs:        new address[](0)                          // sorted list of optional DVNs
        });

        /// @notice ExecutorConfig sets message size limit + fee‑paying executor
        ExecutorConfig memory exec = ExecutorConfig({
            maxMessageSize: 10000,                                       // max bytes per cross-chain message
            executor:       address(0xa20DB4Ffe74A31D17fc24BD32a7DD7555441058e)  // address that pays destination execution fees
        });

        bytes memory encodedUln  = abi.encode(uln);
        bytes memory encodedExec = abi.encode(exec);

        SetConfigParam[] memory params = new SetConfigParam[](2);
        params[0] = SetConfigParam(eid, EXECUTOR_CONFIG_TYPE, encodedExec);
        params[1] = SetConfigParam(eid, ULN_CONFIG_TYPE, encodedUln);

        vm.startBroadcast(signer);
        ILayerZeroEndpointV2(endpoint).setConfig(oapp, sendLib, params);
        vm.stopBroadcast();
    }
}