// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableContract {
    address public owner;
    struct Candidate {
        string name;
        uint256 votes;
    }

    Candidate[] public candidates;
    address[] public voters;

    mapping(address => uint256) public balances;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // 1️⃣ Reentrancy Vulnerability
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdarw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: amount}(""); // Vulnerable to reentrancy
        require(success, "Transfer failed");

        balances[msg.sender] = 0;
    }

    // 2️⃣ Integer Overflow/Underflow
    function transfer(address to, uint256 amount) external {
        unchecked {
            balances[msg.sender] -= amount; // ⚠️ No check on underflow
            balances[to] += amount; // ⚠️ No check on overflow
        }
    }

    // 3️⃣ Untrusted `delegatecall`
    function execute(address target, bytes calldata data) external {
        (bool success, ) = target.delegatecall(data); // ⚠️ Allows arbitrary code execution
        require(success, "Delegatecall failed");
    }

    // 4️⃣ Precision Error (Division Rounding Issue)
    function divide(uint256 a, uint256 b) external pure returns (uint256) {
        return a / b; // ⚠️ Solidity truncates decimals, causing precision errors
    }

    // 5️⃣ Insufficient Access Control
    function changeOwner(address newOwner) external {
        owner = newOwner; // ⚠️ No access control check
    }

    // 6️⃣ DoS via Block Gas Limit
    function registerCandidate(string memory _name) public {
        candidates.push(Candidate(_name, 0));
    }

    function vote(uint256 _candidateIndex) public {
        require(_candidateIndex < candidates.length, "Invalid candidate");
        candidates[_candidateIndex].votes++;
        voters.push(msg.sender);
    }

    function findWinner() public view returns (string memory) {
        uint256 maxVotes = 0;
        uint256 winnerIndex = 0;

        for (uint256 i = 0; i < voters.length; i++) {
            if (candidates[i].votes > maxVotes) {
                maxVotes = candidates[i].votes;
                winnerIndex = i;
            }
        }
        return candidates[winnerIndex].name;
    }

    // 7️⃣ Unencrypted On-Chain Data
    struct User {
        string username;
        string password; // ⚠️ Storing sensitive data on-chain
    }

    mapping(address => User) public users;

    function register(
        string memory _username,
        string memory _password
    ) external {
        users[msg.sender] = User(_username, _password); // ⚠️ Exposes user data to anyone
    }

    // 8️⃣ Timestamp Dependence
    function isLuckyWinner() external view returns (bool) {
        return (block.timestamp % 2 == 0); // ⚠️ Miners can manipulate block timestamps
    }
}
