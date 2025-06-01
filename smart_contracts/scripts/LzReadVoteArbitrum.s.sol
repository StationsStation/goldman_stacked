// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { MessagingReceipt } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

interface IVotingMachineLzRead {
    /// @dev Sends a read request to LayerZero, querying votes of msg.sender on a Governor chain Id.
    /// @param proposalId Proposal Id.
    /// @return receipt The LayerZero messaging receipt for the request.
    function getVotesLzRead(
        bytes32 proposalId,
        bytes calldata extraOptions
    ) external payable returns (MessagingReceipt memory receipt);
}

/// @title LzReadVoteArbitrum
/// @notice Defines and applies ULN (DVN) config for inbound message verification via LayerZero Endpoint V2.
contract LzReadVoteArbitrum is Script {
    using OptionsBuilder for bytes;

    // Gas limit for the executor
    uint128 public constant GAS_LIMIT = 1000000;
    // Calldata size
    uint32 public constant CALLDATA_SIZE = 100;
    // msg.value for the lzReceive() function on destination in wei
    uint128 public constant MSG_VALUE = 0;

    function run() external {
        address votingMachineLzRead = address(0x6f7661F52fE1919996d0A4F68D09B344093a349d);
        address signer = address(0x52370eE170c0E2767B32687166791973a0dE7966);
        bytes32 proposalId = 0x3FD9628E03D871B9813D57D8A086984126B9775530E3EA0345FCE32CDC3F0CB3;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReadOption(GAS_LIMIT, CALLDATA_SIZE, MSG_VALUE);
        //MessagingFee memory fee = _quote(31084, cmd, options, false);

        vm.startBroadcast(signer);
        IVotingMachineLzRead(votingMachineLzRead).getVotesLzRead{value: 100000000000000}(proposalId, options);
        vm.stopBroadcast();
    }
}

//