# Foundry & Secure Smart Contracts

## Foundry Toolkit

**Foundry is a blazing fast, portable, and modular toolkit for Ethereum application development written in Rust.**

### Components:
- **Forge**: Ethereum testing framework (like Truffle, Hardhat, and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions, and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache or Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose Solidity REPL.

### Documentation
[Foundry Book](https://book.getfoundry.sh/)

### Usage

#### Build
```shell
$ forge build
```

#### Test
```shell
$ forge test
```

#### Format
```shell
$ forge fmt
```

#### Gas Snapshots
```shell
$ forge snapshot
```

#### Anvil - Local Ethereum Node
```shell
$ anvil
```

#### Deploy
```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

#### Cast - Ethereum Interaction
```shell
$ cast <subcommand>
```

#### Help
```shell
$ forge --help
$ anvil --help
$ cast --help
```

---

# Secure vs Vulnerable Smart Contracts

## Introduction
This documentation provides an in-depth comparison between a **vulnerable smart contract** and its **secure counterpart**. Each section highlights specific vulnerabilities present in `VulnerableContract.sol` and explains how they are mitigated in `SecureContract.sol`.

### Why Security Matters
Smart contract vulnerabilities can lead to **fund loss**, **contract manipulation**, and **system compromise**. Implementing best security practices ensures reliability and trustworthiness.

### Summary of Common Vulnerabilities & Fixes
| Vulnerability                 | Issue                                              | Fix Summary                     |
|--------------------------------|----------------------------------------------------|---------------------------------|
| Reentrancy                    | Recursive calls drain funds before balance update | Use `nonReentrant`, update first |
| Integer Overflow/Underflow    | Arithmetic issues lead to fund mismanagement      | Use explicit checks              |
| Untrusted `delegatecall`      | Executes arbitrary code in caller's context       | Restrict execution, validate address |
| Precision Errors              | Solidity truncates decimals                       | Ensure denominator is not zero   |
| Insufficient Access Control   | Any user can modify contract ownership            | Restrict to `onlyOwner`          |
| DoS via Block Gas Limit       | Expanding arrays may exceed gas limit             | Use `mapping` instead of array   |
| Unencrypted On-Chain Data     | Sensitive data stored in plaintext                | Use `keccak256` hashing          |
| Timestamp Dependence          | Miners can manipulate block timestamps            | Use `blockhash` for randomness   |

---

## 1️⃣ Reentrancy Vulnerability
### Vulnerable Code
```solidity
function withdraw() public {
    uint256 amount = balances[msg.sender];
    require(amount > 0, "Insufficient balance");

    (bool success, ) = msg.sender.call{value: amount}(""); // ⚠️ Vulnerable to reentrancy
    require(success, "Transfer failed");

    balances[msg.sender] = 0;
}
```
### Secure Code
```solidity
function withdraw() external nonReentrant {
    uint256 amount = balances[msg.sender];
    require(amount > 0, "Insufficient balance");
    
    balances[msg.sender] = 0; // ✅ Update balance before transfer
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```
### Fix:
✅ Uses `nonReentrant` modifier to prevent reentrancy attacks.

✅ Updates user balance **before** making external calls.

---

## 2️⃣ Integer Overflow/Underflow
### Vulnerable Code
```solidity
function transfer(address to, uint256 amount) external {
    unchecked {
        balances[msg.sender] -= amount; // ⚠️ No check on underflow
        balances[to] += amount; // ⚠️ No check on overflow
    }
}
```
### Secure Code
```solidity
function transfer(address to, uint256 amount) external {
    require(balances[msg.sender] >= amount, "Insufficient balance");
    balances[msg.sender] -= amount;
    balances[to] += amount;
}
```
### Fix:
✅ Ensures sender has enough balance **before** subtraction.

✅ Prevents integer underflow/overflow without relying on `unchecked`.

---

## 3️⃣ Untrusted `delegatecall`
### Vulnerable Code
```solidity
function execute(address target, bytes calldata data) external {
    (bool success, ) = target.delegatecall(data); // ⚠️ Allows arbitrary code execution
    require(success, "Delegatecall failed");
}
```
### Secure Code
```solidity
function execute(address target, bytes calldata data) external onlyOwner {
    require(target != address(0), "Invalid target address");
    (bool success, ) = target.delegatecall(data);
    require(success, "Delegatecall failed");
}
```
### Fix:
✅ Uses `onlyOwner` modifier to restrict execution.

✅ Ensures target address is **not** `address(0)`.

---

## 4️⃣ Precision Errors
### Secure Code
```solidity
function safeDivide(uint256 a, uint256 b) external pure returns (uint256) {
    require(b != 0, "Division by zero");
    return (a * 1e18) / b;
}
```
### Fix:
✅ Ensures denominator is **not zero** before division.

✅ Multiplies numerator by `1e18` to avoid precision errors.

---

## 5️⃣ Insufficient Access Control
### Secure Code
```solidity
modifier onlyOwner {
    require(msg.sender == owner, "Not the owner");
    _;
}
```
### Fix:
✅ Uses `onlyOwner` to restrict sensitive functions.

---

## 6️⃣ DoS via Block Gas Limit
### Secure Code
```solidity
mapping(address => uint256) balances; // ✅ Use mapping instead of array
```
### Fix:
✅ Uses `mapping` instead of arrays to avoid excessive gas usage.

---

## 7️⃣ Unencrypted On-Chain Data
### Secure Code
```solidity
bytes32 private hashedData = keccak256(abi.encodePacked(secretValue));
```
### Fix:
✅ Stores sensitive data as a **hash** using `keccak256`.

---

## 8️⃣ Timestamp Dependence
### Secure Code
```solidity
uint256 randomValue = uint256(blockhash(block.number - 1));
```
### Fix:
✅ Uses `blockhash` instead of `block.timestamp` for randomness.

---

## Conclusion
The `SecureContract` mitigates all identified vulnerabilities using best security practices, including:
✅ **Reentrancy protection** using `nonReentrant`.

✅ **Strict access control** with `onlyOwner`.

✅ **Secure randomness sources**.

✅ **Data integrity** by using hashed storage.

✅ **Gas-efficient structures** to prevent DoS attacks.

🔹 **Always test smart contracts thoroughly before deployment!** 🚀

