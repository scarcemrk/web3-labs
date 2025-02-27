// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/VulnerableContract.sol";

contract PrecisionErrorTest is Test {
    VulnerableContract public vulnerable;

    function setUp() public {
        vulnerable = new VulnerableContract();
    }

    function testPrecisionError() public view{
        uint256 result = vulnerable.divide(5, 2);
        assertEq(result, 2, "Precision error not demonstrated");
    }
}
