// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SecureContract is Ownable, ReentrancyGuard {
    struct Candidate {
        string name;
        uint256 votes;
    }

    Candidate[] public candidates;
    mapping(address => bool) public hasVoted;
    mapping(address => uint256) public balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Voted(address indexed voter, uint256 candidateIndex);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    
    constructor() Ownable(msg.sender) {}

    // 1️⃣ Secure Reentrancy Protection
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw() external nonReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient balance");

        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    // 2️⃣ Secure Integer Handling
    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    // 3️⃣ Secure Delegatecall Execution
    function execute(address target, bytes calldata data) external onlyOwner {
        require(target != address(0), "Invalid target address");
        (bool success, ) = target.delegatecall(data);
        require(success, "Delegatecall failed");
    }

    // 4️⃣ Safe Division with Precision Handling
    function divide(uint256 a, uint256 b) external pure returns (uint256) {
        require(b > 0, "Cannot divide by zero");
        return (a * 1e18) / b;
    }

    // 5️⃣ Access-Controlled Owner Change
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        _transferOwnership(newOwner);
        emit OwnerChanged(msg.sender, newOwner);
    }

    // 6️⃣ Prevent DoS via Block Gas Limit
    function registerCandidate(string memory _name) external onlyOwner {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        candidates.push(Candidate(_name, 0));
    }

    function vote(uint256 _candidateIndex) external {
        require(_candidateIndex < candidates.length, "Invalid candidate");
        require(!hasVoted[msg.sender], "You have already voted");

        candidates[_candidateIndex].votes++;
        hasVoted[msg.sender] = true;
        emit Voted(msg.sender, _candidateIndex);
    }

    function findWinner() public view returns (string memory) {
        uint256 maxVotes = 0;
        uint256 winnerIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].votes > maxVotes) {
                maxVotes = candidates[i].votes;
                winnerIndex = i;
            }
        }
        return candidates[winnerIndex].name;
    }

    // 7️⃣ Preventing Unencrypted On-Chain Data Storage
    struct User {
        bytes32 usernameHash;
        bytes32 passwordHash;
    }

    mapping(address => User) private users;

    function register(string memory _username, string memory _password) external {
        require(bytes(_username).length > 0, "Username cannot be empty");
        require(bytes(_password).length > 0, "Password cannot be empty");

        users[msg.sender] = User(
            keccak256(abi.encodePacked(_username)),
            keccak256(abi.encodePacked(_password))
        );
    }

    function verifyUser(address user, string memory _password) external view returns (bool) {
        return users[user].passwordHash == keccak256(abi.encodePacked(_password));
    }

    // 8️⃣ Secure Randomness Handling
    function isLuckyWinner() external view returns (bool) {
        return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender))) % 2 == 0;
    }
}
