// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

struct MockOrigin {
    uint32 srcEid;
    bytes32 sender;
    uint64 nonce;
}

struct MockMessagingFee {
    uint256 nativeFee;
    uint256 lzTokenFee;
}

struct MockMessagingReceipt {
    bytes32 guid;
    uint64 nonce;
    MockMessagingFee fee;
}

struct MockMessagingParams {
    uint32 dstEid;
    bytes32 receiver;
    bytes message;
    bytes options;
    bool payInLzToken;
}

interface IMockLzReceiver {
    function lzReceive(
        MockOrigin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable;
}

interface ILayerZeroEndpointV2 {
    function send(
        MockMessagingParams calldata _params,
        address payable _refundAddress,
        bytes calldata _message
    ) external payable returns (MockMessagingReceipt memory);

    function quote(
        MockMessagingParams calldata _params,
        bytes calldata _message
    ) external view returns (MockMessagingFee memory);

    function peers(uint32 _eid) external view returns (address);
    function setDelegate(address _delegate) external;
    function setPeer(uint32 _eid, address _peer) external;
} 