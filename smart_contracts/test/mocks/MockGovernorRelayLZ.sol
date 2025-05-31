// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./MockTypes.sol";
import "./MockOApp.sol";

// Mock GovernorRelayLZ that uses our mocks
contract MockGovernorRelayLZ is MockOAppRead {
    address public governor;
    uint32 public immutable remoteChainId;

    constructor(address _endpoint, uint256 _remoteChainId)
        MockOAppRead(_endpoint, msg.sender)
    {
        remoteChainId = uint32(_remoteChainId);
    }

    function changeGovernor(address _governor) external {
        governor = _governor;
    }

    function sendProposalDetails(
        bytes32 proposalId,
        uint256 startTime,
        uint256 endTime,
        bytes calldata options
    ) external payable {
        require(msg.sender == governor, "Only governor");

        bytes memory payload = abi.encode(proposalId, startTime, endTime);

        MockMessagingFee memory fee = _quote(remoteChainId, payload, options, false);
        require(msg.value >= fee.nativeFee);

        _lzSend(
            remoteChainId,
            payload,
            options,
            MockMessagingFee(msg.value, 0),
            payable(msg.sender)
        );
    }

    function receiveVote(bytes calldata payload) external {
        (bytes32 proposalId, uint256 totalVotes) = abi.decode(payload, (bytes32, uint256));

        (bool ok, ) = governor.call(
            abi.encodeWithSignature("relayResult(bytes32,uint256)", proposalId, totalVotes)
        );
        require(ok, "Governor call failed");
    }
} 