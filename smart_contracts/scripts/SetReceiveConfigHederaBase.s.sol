// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";

/// @title LayerZero Receive Configuration Script
/// @notice Defines and applies ULN (DVN) config for inbound message verification via LayerZero Endpoint V2.
contract SetReceiveConfigHederaBase is Script {
    // For ReadLib the only possible DVN config type is CONFIG_TYPE_READ_LID_CONFIG = 1: https://vscode.blockscan.com/42161/0xbcd4CADCac3F767C57c4F402932C4705DF62BEFf
    uint32 constant ULN_CONFIG_TYPE = 1;

    function run() external {
        address endpoint = address(0x3A73033C0b1407574C76BdBAc67f126f6b4a9AA9);
        address oapp      = address(0x7bedCA17D29e53C8062d10902a6219F8d1E3B9B5);
        uint32 eid        = 30184;
        address receiveLib = address(0xc1B621b18187F74c8F6D52a6F709Dd2780C09821);
        address signer    = address(0x52370eE170c0E2767B32687166791973a0dE7966);
        address[] memory requiredDVNs = new address[](1);
        requiredDVNs[0] = address(0xce8358bc28dd8296Ce8cAF1CD2b44787abd65887);

        /// @notice UlnConfig controls verification threshold for incoming messages
        /// @notice Receive config enforces these settings have been applied to the DVNs and Executor
        /// @dev 0 values will be interpretted as defaults, so to apply NIL settings, use:
        /// @dev uint8 internal constant NIL_DVN_COUNT = type(uint8).max;
        /// @dev uint64 internal constant NIL_CONFIRMATIONS = type(uint64).max;
        UlnConfig memory uln = UlnConfig({
            confirmations:      15,                                       // min block confirmations from source
            requiredDVNCount:   1,                                        // required DVNs for message acceptance
            optionalDVNCount:   type(uint8).max,                          // optional DVNs count
            optionalDVNThreshold: 0,                                      // optional DVN threshold
            requiredDVNs:       requiredDVNs,                             // sorted required DVNs
            optionalDVNs:       new address[](0)                          // no optional DVNs
        });

        bytes memory encodedUln = abi.encode(uln);

        SetConfigParam[] memory params = new SetConfigParam[](1);
        params[0] = SetConfigParam(eid, ULN_CONFIG_TYPE, encodedUln);

        vm.startBroadcast(signer);
        ILayerZeroEndpointV2(endpoint).setConfig(oapp, receiveLib, params);
        vm.stopBroadcast();
    }
}
