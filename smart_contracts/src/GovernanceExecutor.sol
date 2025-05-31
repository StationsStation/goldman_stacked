// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface ILimitOrderProtocol {
    function fillOrder(
        bytes calldata order,
        bytes calldata signature,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes calldata interaction
    ) external payable returns (uint256, uint256);
}

contract GovernanceExecutor {
    event OrderExecuted(bytes32 indexed orderHash);

    bytes4 constant MAGICVALUE = 0x1626ba7e; // ERC-1271
    bytes4 constant INVALID_SIGNATURE = 0xffffffff;

    uint256 public nonce;
    address public immutable timelock;

    mapping(bytes32 => bool) public approvedHashes;

    constructor(address _timelock) {
        timelock = _timelock;
    }

    /// @notice Approves DAO limit order proposal for execution.
    function execute(
        address makerAsset,
        address takerAsset,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes memory predicate,
        bytes memory permit,
        bytes memory interaction
    ) external {
        require(msg.sender == timelock, "Timelock only");

        // Формируем order struct как bytes (ABI-encoded), без подписи
        bytes memory order = abi.encode(
            address(this), // maker
            address(0),    // taker (anyone)
            makerAsset,
            takerAsset,
            makingAmount,
            takingAmount,
            uint256(block.timestamp), // part of salt
            "", // makerAssetData
            "", // takerAssetData
            "", // getMakingAmount
            "", // getTakingAmount
            predicate,
            permit,
            interaction,
            nonce++
        );

        // Hash order as in LimitOrderProtocol
        bytes32 orderHash = keccak256(order);

        // The same order must not be approved twice by the governance
        require(!approvedHashes[orderHash], "Order has been already approved");

        // DAO approves order hash
        approvedHashes[orderHash] = true;

        // emit order for off-chain
        emit OrderExecuted(orderHash);
    }

    /// @notice ERC-1271 support for signing the order by a contract.
    function isValidSignature(bytes32 hash, bytes memory) public view returns (bytes4) {
        if (approvedHashes[hash]) {
            return MAGICVALUE;
        } else {
            return INVALID_SIGNATURE;
        }
    }
}
