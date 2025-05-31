// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GovernanceExecutor.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock LimitOrderProtocol
contract MockLimitOrderProtocol is ILimitOrderProtocol {
    function fillOrder(
        bytes calldata order,
        bytes calldata signature,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes calldata interaction
    ) external payable returns (uint256, uint256) {
        return (makingAmount, takingAmount);
    }
}

// Mock Token for testing
contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract GovernanceExecutorTest is Test {
    GovernanceExecutor public executor;
    MockLimitOrderProtocol public limitOrderProtocol;
    MockToken public tokenA;
    MockToken public tokenB;

    address public constant OWNER = address(1);
    address public constant TIMELOCK = address(2);

    function setUp() public {
        vm.startPrank(OWNER);
        
        limitOrderProtocol = new MockLimitOrderProtocol();
        executor = new GovernanceExecutor(TIMELOCK, address(limitOrderProtocol));
        
        tokenA = new MockToken("Token A", "TKA");
        tokenB = new MockToken("Token B", "TKB");
        
        vm.stopPrank();
    }

    function testInitialSetup() public {
        assertEq(executor.timelock(), TIMELOCK);
        assertEq(executor.limitOrderProtocol(), address(limitOrderProtocol));
    }

    function testExecuteOrder() public {
        address makerAsset = address(tokenA);
        address takerAsset = address(tokenB);
        uint256 makingAmount = 1000;
        uint256 takingAmount = 500;
        bytes memory predicate = "";
        bytes memory permit = "";
        bytes memory interaction = "";

        vm.prank(TIMELOCK);
        executor.execute(
            makerAsset,
            takerAsset,
            makingAmount,
            takingAmount,
            predicate,
            permit,
            interaction
        );

        // Get the order hash
        bytes memory order = abi.encode(
            address(executor), // maker
            address(0),     // taker (anyone)
            makerAsset,
            takerAsset,
            makingAmount,
            takingAmount,
            uint256(block.timestamp), // salt
            "", // makerAssetData
            "", // takerAssetData
            "", // getMakingAmount
            "", // getTakingAmount
            predicate,
            permit,
            interaction,
            0 // nonce
        );
        bytes32 orderHash = keccak256(order);

        // Verify order was approved
        assertTrue(executor.approvedHashes(orderHash));
    }

    function testCannotExecuteSameProposalTwice() public {
        address makerAsset = address(tokenA);
        address takerAsset = address(tokenB);
        uint256 makingAmount = 1000;
        uint256 takingAmount = 500;
        bytes memory predicate = "";
        bytes memory permit = "";
        bytes memory interaction = "";

        vm.startPrank(TIMELOCK);
        
        // Set a fixed timestamp for testing
        vm.warp(1000);
        
        // First execution
        executor.execute(
            makerAsset,
            takerAsset,
            makingAmount,
            takingAmount,
            predicate,
            permit,
            interaction
        );

        // Get the order hash from the first execution
        bytes memory order = abi.encode(
            address(executor), // maker
            address(0),     // taker (anyone)
            makerAsset,
            takerAsset,
            makingAmount,
            takingAmount,
            uint256(1000), // salt (same timestamp)
            "", // makerAssetData
            "", // takerAssetData
            "", // getMakingAmount
            "", // getTakingAmount
            predicate,
            permit,
            interaction,
            executor.nonce() - 1 // nonce from first execution
        );
        bytes32 orderHash = keccak256(order);

        // Verify the order hash was approved
        assertTrue(executor.approvedHashes(orderHash));

        // Try to execute the same order again with the same parameters
        vm.warp(1000); // Use the same timestamp
        vm.store(
            address(executor),
            bytes32(uint256(0)), // nonce storage slot
            bytes32(executor.nonce() - 1) // Use the same nonce as first execution
        );
        vm.expectRevert("Order has been already approved");
        executor.execute(
            makerAsset,
            takerAsset,
            makingAmount,
            takingAmount,
            predicate,
            permit,
            interaction
        );
        
        vm.stopPrank();
    }

    function testOrderSignatureValidation() public {
        address makerAsset = address(tokenA);
        address takerAsset = address(tokenB);
        uint256 makingAmount = 1000;
        uint256 takingAmount = 500;
        bytes memory predicate = "";
        bytes memory permit = "";
        bytes memory interaction = "";

        vm.prank(TIMELOCK);
        executor.execute(
            makerAsset,
            takerAsset,
            makingAmount,
            takingAmount,
            predicate,
            permit,
            interaction
        );

        // Create the same order bytes as in the execute function
        bytes memory order = abi.encode(
            address(executor), // maker
            address(0),     // taker (anyone)
            makerAsset,
            takerAsset,
            makingAmount,
            takingAmount,
            uint256(block.timestamp), // salt
            "", // makerAssetData
            "", // takerAssetData
            "", // getMakingAmount
            "", // getTakingAmount
            predicate,
            permit,
            interaction,
            0 // nonce
        );

        bytes32 orderHash = keccak256(order);
        
        // Check that the order hash is approved
        assertTrue(executor.approvedHashes(orderHash));
        
        // Verify ERC-1271 signature validation
        bytes4 magicValue = executor.isValidSignature(orderHash, "");
        assertEq(magicValue, bytes4(0x1626ba7e));
    }

    function testInvalidSignature() public {
        bytes32 randomHash = keccak256("random hash");
        bytes4 magicValue = executor.isValidSignature(randomHash, "");
        assertEq(magicValue, bytes4(0xffffffff));
    }
} 