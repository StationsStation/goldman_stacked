// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

struct MockEVMCallRequestV1 {
    uint16 appRequestLabel;
    uint32 targetEid;
    bool isBlockNum;
    uint64 blockNumOrTimestamp;
    uint64 confirmations;
    address to;
    bytes callData;
}

library MockReadCodecV1 {
    function encode(uint16 version, MockEVMCallRequestV1[] memory requests) internal pure returns (bytes memory) {
        // Simplified encoding for testing
        return abi.encode(version, requests);
    }
} 