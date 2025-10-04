GroupVault Smart Contract

**GroupVault** is a decentralized smart contract built on the **Stacks blockchain** using **Clarity**.  
It enables multiple users to **pool, lock, and manage STX collectively**, ensuring transparent and trustless fund management for teams, DAOs, and communities.

---

Overview

GroupVault allows participants to create and manage shared STX vaults where each member contributes to a common pool.  
Funds can be withdrawn only when certain group conditions are met, ensuring accountability and secure collaboration.

---

Features

- **Vault Creation** – Initialize a shared STX vault with custom rules.  
- **Group Contributions** – Track individual member deposits in real-time.  
- **Secure Withdrawals** – Enable consensus-based or admin-approved withdrawals.  
- **Transparency** – View total balance, member shares, and contribution history.  
- **Security** – Enforces on-chain fund management with immutable logic.  
- **Audit-Ready** – Clear record of all transactions stored immutably on the blockchain.

---

Smart Contract Functions

| Function | Type | Description |
|-----------|------|-------------|
| `create-vault` | Public | Deploy a new group vault with admin and initial members. |
| `contribute` | Payable | Allows members to deposit STX into the group vault. |
| `request-withdrawal` | Public | Initiate a withdrawal request subject to group approval. |
| `approve-withdrawal` | Public | Approve pending withdrawal requests. |
| `get-vault-info` | Read-only | Retrieve details about vault balance, members, and status. |

---

Testing and Validation

This contract was tested using **Clarinet**, the Stacks development framework.

Run Tests
```bash
clarinet test
