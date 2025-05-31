// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./MockTypes.sol";
import "./MockEndpoint.sol";

// Mock base contract for OApp functionality
contract MockOAppBase {
    address payable public immutable endpoint;
    address public immutable owner;

    constructor(address _endpoint, address _owner) {
        endpoint = payable(_endpoint);
        owner = _owner;
    }

    function _lzSend(
        uint32 _dstEid,
        bytes memory _payload,
        bytes memory _options,
        MockMessagingFee memory _fee,
        address payable _refundAddress
    ) internal virtual returns (MockMessagingReceipt memory) {
        MockMessagingParams memory params = MockMessagingParams(
            _dstEid,
            bytes32(uint256(uint160(address(_refundAddress)))),
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
        MockMessagingParams memory params = MockMessagingParams(
            _dstEid,
            bytes32(uint256(uint160(address(this)))),
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

// Mock for OAppRead with options
contract MockOAppReadWithOptions is MockOAppBase {
    constructor(address _endpoint, address _owner) MockOAppBase(_endpoint, _owner) {}

    function combineOptions(
        uint32,
        uint16,
        bytes memory _extraOptions
    ) internal pure returns (bytes memory) {
        return _extraOptions;
    }
}

// Mock for OAppOptionsType3
contract MockOAppOptionsType3 is MockOAppBase {
    constructor(address _endpoint, address _owner) MockOAppBase(_endpoint, _owner) {}

    function combineOptions(
        uint32,
        uint16,
        bytes memory _extraOptions
    ) internal pure returns (bytes memory) {
        return _extraOptions;
    }
} 