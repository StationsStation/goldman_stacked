// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";

/// @title LayerZero Receive Configuration Script
/// @notice Defines and applies ULN (DVN) config for inbound message verification via LayerZero Endpoint V2.
contract SetReceiveConfigBaseLz is Script {
    // For ReadLib the only possible DVN config type is CONFIG_TYPE_READ_LID_CONFIG = 1: https://vscode.blockscan.com/42161/0xbcd4CADCac3F767C57c4F402932C4705DF62BEFf
    uint32 constant ULN_CONFIG_TYPE = 1;

    function run() external {
        address endpoint = address(0x1a44076050125825900e736c501f859c50fE728c);
        address oapp      = address(0x7a9470bE221B757f7cB99a60fca3e3Bc12189F24);
        uint32 eid        = 4294967295;
        address receiveLib= address(0x1273141a3f7923AA2d9edDfA402440cE075ed8Ff);
        address signer    = address(0x52370eE170c0E2767B32687166791973a0dE7966);
        address[] memory requiredDVNs = new address[](1);
        requiredDVNs[0] = address(0xB1473AC9f58FB27597a21710da9D1071841E8163);

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