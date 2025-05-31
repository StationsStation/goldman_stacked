// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./MockTypes.sol";
import "./MockEndpoint.sol";

// Mock base contract for OApp functionality
contract MockOApp {
    address payable public immutable endpoint;
    address public immutable owner;
    mapping(uint32 => bytes32) public peers;

    constructor(address _endpoint, address _owner) {
        endpoint = payable(_endpoint);
        owner = _owner;
    }

    function setPeer(uint32 _eid, bytes32 _peer) external {
        require(msg.sender == owner, "Not owner");
        peers[_eid] = _peer;
    }

    function _lzSend(
        uint32 _dstEid,
        bytes memory _payload,
        bytes memory _options,
        MockMessagingFee memory _fee,
        address payable _refundAddress
    ) internal virtual returns (MockMessagingReceipt memory) {
        bytes32 receiver = peers[_dstEid];
        require(receiver != bytes32(0), "Peer not set");
        
        MockMessagingParams memory params = MockMessagingParams(
            _dstEid,
            receiver,
            _payload,
            _options,
            false
        );
        return MockEndpoint(endpoint).send{value: _fee.nativeFee}(
            params,
            _refundAddress,
            _payload
        );
    }

    function _quote(
        uint32 _dstEid,
        bytes memory _payload,
        bytes memory _options,
        bool _payInLzToken
    ) internal view virtual returns (MockMessagingFee memory) {
        bytes32 receiver = peers[_dstEid];
        require(receiver != bytes32(0), "Peer not set");
        
        MockMessagingParams memory params = MockMessagingParams(
            _dstEid,
            receiver,
            _payload,
            _options,
            _payInLzToken
        );
        return MockEndpoint(endpoint).quote(params, _payload);
    }

    function lzReceive(
        MockOrigin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable virtual {
        require(msg.sender == endpoint, "MockOApp: invalid endpoint");
        _lzReceive(_origin, _guid, _message, _executor, _extraData);
    }

    function _lzReceive(
        MockOrigin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) internal virtual {}
}

// Mock for OAppOptionsType3
contract MockOAppOptionsType3 is MockOApp {
    constructor(address _endpoint, address _owner) MockOApp(_endpoint, _owner) {}

    function combineOptions(
        uint32,
        uint16,
        bytes memory _extraOptions
    ) internal pure returns (bytes memory) {
        return _extraOptions;
    }
}

// Mock for OAppRead
contract MockOAppRead is MockOApp {
    constructor(address _endpoint, address _owner) MockOApp(_endpoint, _owner) {}
}