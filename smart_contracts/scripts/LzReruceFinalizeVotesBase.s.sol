// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { MessagingReceipt } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

interface IMyGovernor {
    function finalizeProposalVotes(uint256 proposalId, bytes calldata options) external payable;
}

/// @title LzReruceFinalizeVotesBase
contract LzReruceFinalizeVotesBase is Script {
    using OptionsBuilder for bytes;

    // Gas limit for the executor
    uint128 public constant GAS_LIMIT = 1000000;
    // Calldata size
    uint32 public constant CALLDATA_SIZE = 100;
    // msg.value for the lzReceive() function on destination in wei
    uint128 public constant MSG_VALUE = 0;

    function run() external {
        address governor = address(0xE5Da5F4d8644A271226161a859c1177C5214c54e);
        address signer = address(0x52370eE170c0E2767B32687166791973a0dE7966);
        uint256 proposalId = 28879795473662080947213802400002854805423356819059346837403212000082448551091;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReadOption(GAS_LIMIT, CALLDATA_SIZE, MSG_VALUE);
        //MessagingFee memory fee = _quote(31084, cmd, options, false);

        vm.startBroadcast(signer);
        IMyGovernor(governor).finalizeProposalVotes{value: 100000000000000}(proposalId, options);
        vm.stopBroadcast();
    }
}

//