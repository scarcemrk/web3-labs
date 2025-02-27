// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/VulnerableContract.sol";

contract IntegerOverflowTest is Test {
    VulnerableContract public vulnerable;
    address user = address(0x123);

    function setUp() public {
        vulnerable = new VulnerableContract();
        vm.deal(user, 5 ether);
    }

    function test__Overflow() public {
        vm.startPrank(user);
        vulnerable.deposit{value: 1 ether}();
        
        // Bypass Solidity 8's Safe Math using `unchecked`
        unchecked {
            vulnerable.transfer(address(0), type(uint256).max);
        }
        
        vm.stopPrank();
    }
}
