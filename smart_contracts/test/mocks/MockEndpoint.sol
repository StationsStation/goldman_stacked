// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./MockTypes.sol";
import "forge-std/console.sol";

contract MockEndpoint {
    uint32 public immutable eid;
    mapping(uint32 => address) public peers;
    address public delegate;
    
    constructor(uint32 _eid) {
        eid = _eid;
    }

    function setDelegate(address _delegate) external {
        delegate = _delegate;
    }

    function setPeer(uint32 _eid, address _peer) external {
        peers[_eid] = _peer;
    }

    function send(
        MockMessagingParams calldata _params,
        address payable _refundAddress,
        bytes calldata _message
    ) external payable returns (MockMessagingReceipt memory) {
        console.log("MockEndpoint.send - Start");
        console.log("dstEid:", _params.dstEid);
        console.log("receiver:", address(uint160(uint256(_params.receiver))));
        console.log("msg.sender:", msg.sender);
        console.log("msg.value:", msg.value);
        console.log("message length:", _message.length);
        console.log("delegate:", delegate);
        
        require(peers[_params.dstEid] != address(0), "EP: Peer not set");
        
        // Convert bytes32 receiver to address and validate
        address receiver = address(uint160(uint256(_params.receiver)));
        require(receiver != address(0), "EP: Invalid receiver address");
        
        // Log important values
        require(msg.value > 0, "EP: No value sent");
        require(_message.length > 0, "EP: Empty message");
        require(delegate != address(0), "EP: No delegate set");
        
        // Simulate sending message to peer
        MockOrigin memory origin = MockOrigin(eid, bytes32(uint256(uint160(msg.sender))), 0);
        
        console.log("MockEndpoint.send - Before lzReceive");
        // Try-catch the lzReceive call to get more info
        try IMockLzReceiver(receiver).lzReceive{value: msg.value}(
            origin,
            bytes32(uint256(block.timestamp)),
            _message,
            delegate,
            ""
        ) {
            console.log("MockEndpoint.send - lzReceive success");
            // Success case
            return MockMessagingReceipt(
                bytes32(uint256(block.timestamp)),
                0,
                MockMessagingFee(msg.value, 0)
            );
        } catch Error(string memory reason) {
            console.log("MockEndpoint.send - lzReceive failed with reason:", reason);
            revert(string.concat("EP: lzReceive failed - ", reason));
        } catch (bytes memory) {
            console.log("MockEndpoint.send - lzReceive failed with no reason");
            revert("EP: lzReceive failed with no reason");
        }
    }

    function quote(
        MockMessagingParams calldata _params,
        bytes calldata _message
    ) external view returns (MockMessagingFee memory) {
        require(peers[_params.dstEid] != address(0), "EP: Peer not set");
        return MockMessagingFee(0.01 ether, 0);
    }

    receive() external payable {}

    function verify(
        MockOrigin calldata,
        address,
        bytes32
    ) external pure {}

    function verifiable(
        MockOrigin calldata,
        address
    ) external pure returns (bool) {
        return true;
    }

    function initializable(
        MockOrigin calldata,
        address
    ) external pure returns (bool) {
        return true;
    }

    function lzToken() external pure returns (address) {
        return address(0);
    }

    function nativeToken() external pure returns (address) {
        return address(0);
    }
} 