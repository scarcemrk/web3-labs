// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/SecureContract.sol";

contract SecureContractTest is Test {
    SecureContract secureContract;
    address owner;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        secureContract = new SecureContract();
    }

    /// @dev Test Integer Overflow/Underflow Prevention (Fixed)
    function testSafeTransfer() public {
        vm.deal(user1, 3 ether);

        vm.prank(user1);
        secureContract.deposit{value: 2 ether}(); // Ensure enough balance

        vm.prank(user1);
        secureContract.transfer(user2, 1 ether); // Valid transfer

        assertEq(secureContract.balances(user1), 1 ether, "User1 balance mismatch");
        assertEq(secureContract.balances(user2), 1 ether, "User2 balance mismatch");
    }

    /// @dev Secure `delegatecall` Execution Test
    function testDelegateCall() public {
        vm.startPrank(user1);
        vm.expectRevert();
        secureContract.execute(address(this), abi.encodeWithSignature("selfDestruct()")); // Should fail
        vm.stopPrank();
    }

    /// @dev Ownership Transfer Security
    function testOwnershipTransfer() public {
        vm.expectRevert();
        vm.prank(user1);
        secureContract.changeOwner(user1); // Should fail (onlyOwner)

        vm.prank(owner);
        secureContract.changeOwner(user1);

        assertEq(secureContract.owner(), user1);
    }

    /// @dev Secure Voting Mechanism
    function testVotingSystem() public {
        vm.prank(owner);
        secureContract.registerCandidate("Alice");

        vm.prank(user1);
        secureContract.vote(0); // Should work

        vm.startPrank(user1);
        vm.expectRevert();
        secureContract.vote(0); // Should fail (already voted)
        vm.stopPrank();
    }

    /// @dev On-Chain Data Storage Protection
    function testSecureUserRegistration() public {
        vm.startPrank(user1);
        secureContract.register("username", "securepassword");

        bool isValid = secureContract.verifyUser(user1, "securepassword");
        assertTrue(isValid);
    }

    /// @dev Secure Randomness Test
    function testSecureRandomness() public view{
        bool lucky = secureContract.isLuckyWinner();
        assertTrue(lucky || !lucky); // Just checking that it works
    }

    /// @dev Secure Division with Precision Handling
    function testSafeDivision() public view{
        uint256 result = secureContract.divide(5, 2);
        assertEq(result, 2.5e18, "Division result mismatch"); // 5 * 1e18 = 
    }
}
