// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
    bytes4 constant MAGICVALUE = 0x1626ba7e; // ERC-1271
    bytes4 constant INVALID_SIGNATURE = 0xffffffff;

    mapping(bytes32 => bool) public approvedHashes;
    mapping(uint256 => bool) public executedProposals;

    address public limitOrderProtocol;

    constructor(address _limitOrderProtocol) {
        limitOrderProtocol = _limitOrderProtocol;
    }

    /// @notice Утверждение и исполнение лимитного ордера через голосование DAO
    function execute(
        uint256 proposalId,
        address makerAsset,
        address takerAsset,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes calldata predicate,
        bytes calldata permit,
        bytes calldata interaction,
        bytes calldata signature
    ) external {
        require(!executedProposals[proposalId], "Proposal already executed");
        executedProposals[proposalId] = true;

        // Формируем order struct как bytes (ABI-encoded), без подписи
        bytes memory order = abi.encode(
            address(this), // maker
            address(0),     // taker (anyone)
            makerAsset,
            takerAsset,
            makingAmount,
            takingAmount,
            uint256(block.timestamp), // salt (можно заменить на nonce или голос id)
            "", // makerAssetData
            "", // takerAssetData
            "", // getMakingAmount
            "", // getTakingAmount
            predicate,
            permit,
            interaction
        );

        // Хэшируем order как обычно делается в LimitOrderProtocol
        bytes32 orderHash = keccak256(order);

        // DAO голосованием одобряет хэш ордера
        approvedHashes[orderHash] = true;

        // emit order for off-chain
    }

    /// @notice ERC-1271 поддержка подписи ордера контрактом
    function isValidSignature(bytes32 hash, bytes memory) public view returns (bytes4) {
        if (approvedHashes[hash]) {
            return MAGICVALUE;
        } else {
            return INVALID_SIGNATURE;
        }
    }
} 
