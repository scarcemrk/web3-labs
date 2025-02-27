// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/SecureContract.sol";

contract SecureContractTest is Test {
    SecureContract secureContract;
    address user1;
    address user2;

    function setUp() public {
        secureContract = new SecureContract();
        user1 = address(0x1);
        user2 = address(0x2);
    }

    /// 🏦 1️⃣ **Test Deposit Functionality**
    function testDeposit() public {
        vm.deal(user1, 5 ether); // Give user1 some ETH

        vm.prank(user1);
        secureContract.deposit{value: 2 ether}(); // Deposit 2 ETH

        assertEq(secureContract.balances(user1), 2 ether, "Deposit balance incorrect");
    }

    /// 💸 2️⃣ **Test Secure Withdrawal**
    function testWithdraw() public {
        vm.deal(user1, 5 ether);

        vm.prank(user1);
        secureContract.deposit{value: 2 ether}();

        uint256 balanceBefore = user1.balance;

        vm.prank(user1);
        secureContract.withdraw();

        uint256 balanceAfter = user1.balance;

        assertEq(balanceAfter, balanceBefore + 2 ether, "Withdraw amount incorrect");
        assertEq(secureContract.balances(user1), 0, "Balance not reset to zero");
    }

    /// 🔄 3️⃣ **Test Reentrancy Protection (Ensure Attack Fails)**
    function testReentrancyFails() public {
    ReentrancyAttacker attacker = new ReentrancyAttacker(secureContract);
    vm.deal(address(attacker), 1 ether);

    vm.expectRevert();
    attacker.attack{value: 1 ether}();
}

}

/// **Malicious Reentrancy Attacker Contract (Should Fail)**
contract ReentrancyAttacker {
    SecureContract public target;
    bool internal attackTriggered = false;

    constructor(SecureContract _target) {
        target = _target;
    }

    receive() external payable {
        if (!attackTriggered) {
            attackTriggered = true;
            target.withdraw(); // ⚠️ Triggers reentrancy attempt
        }
    }

    function attack() external payable {
        target.deposit{value: msg.value}();
        target.withdraw(); // Triggers fallback, which calls `withdraw` again
    }
}
