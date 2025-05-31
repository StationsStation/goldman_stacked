// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { MessagingFee, MessagingReceipt, Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { OAppRead } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppRead.sol";
import { OAppOptionsType3, EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { ReadCodecV1, EVMCallRequestV1 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract GovernorRelayLZ is OAppRead {
    address public governor;
    // TODO account for multiple chains
    uint32 public immutable remoteChainId;

    constructor(address _endpoint, uint256 _remoteChianId)
        OAppRead(_endpoint, msg.sender) Ownable(msg.sender)
    {
        remoteChainId = uint32(_remoteChianId);
    }

    function changeGovernor(address _governor) external {
        governor = _governor;
    }

    function sendProposalDetails(bytes32 proposalId, uint256 startTime, uint256 endTime, bytes calldata options) external payable {
        require(msg.sender == governor, "Only governor");

        bytes memory payload = abi.encode(proposalId, startTime, endTime);

        MessagingFee memory fee = _quote(remoteChainId, payload, options, false);
        require(msg.value >= fee.nativeFee);

        _lzSend(
            remoteChainId, // Destination chain's endpoint ID.
            payload, // Encoded message payload being sent.
            options, // Message execution options (e.g., gas to use on destination).
            MessagingFee(msg.value, 0), // Fee struct containing native gas and ZRO token.
            payable(msg.sender) // The refund address in case the send call reverts.
        );
    }

    function receiveVote(bytes calldata payload) external {

        (bytes32 proposalId, uint256 totalVotes) = abi.decode(payload, (bytes32, uint256));

        (bool ok, ) = governor.call(
            abi.encodeWithSignature("relayResult(bytes32,uint256)", proposalId, totalVotes)
        );
        require(ok, "Governor call failed");
    }

    /// @notice Internal function to handle message responses.
    /// @dev _origin The origin information (unused in this implementation).
    /// @dev _guid The unique identifier for the received message (unused in this implementation).
    /// @param _message The encoded message data.
    /// @dev _executor The executor address (unused in this implementation).
    /// @dev _extraData Additional data (unused in this implementation).
    function _lzReceive(
        Origin calldata /* _origin */,
        bytes32 _guid,
        bytes calldata _message,
        address /* _executor */,
        bytes calldata /* _extraData */
    ) internal override {

    }
}

