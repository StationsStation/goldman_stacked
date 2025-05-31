// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./MockTypes.sol";

contract MockReceiver is IMockLzReceiver {
    address public immutable endpoint;
    address public immutable owner;

    event MessageReceived(
        uint32 srcEid,
        bytes32 sender,
        bytes32 guid,
        bytes message,
        address executor,
        bytes extraData
    );

    constructor(address _endpoint, address _owner) {
        endpoint = _endpoint;
        owner = _owner;
    }

    function lzReceive(
        MockOrigin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable override {
        require(msg.sender == endpoint, "MR: Invalid endpoint");
        
        emit MessageReceived(
            _origin.srcEid,
            _origin.sender,
            _guid,
            _message,
            _executor,
            _extraData
        );
    }
} 