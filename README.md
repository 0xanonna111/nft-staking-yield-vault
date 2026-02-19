# NFT Staking Yield Vault

An expert-level smart contract ecosystem for gamified DeFi. This repository enables NFT collections to add utility by rewarding holders with a native utility token based on the duration of their stake.

## Mechanics
* **Staking:** Users transfer ownership of their NFT to the vault.
* **Yield Accrual:** Rewards are calculated linearly per second (or block).
* **Unstaking:** Users can withdraw their NFT and claim accumulated rewards in a single atomic transaction.
* **Emergency Egress:** Built-in safeguards for contract owners to manage reward pools.

## Technical Architecture
The system uses two primary contracts:
1. **RewardToken:** A standard ERC20 token used for payouts.
2. **NFTStaking:** The vault logic that interfaces with any standard ERC721 collection.

## Deployment Guide
1. Deploy the `RewardToken.sol`.
2. Deploy `NFTStaking.sol`, providing the NFT collection address and the Reward Token address.
3. Fund the Staking contract with the Reward Token to begin the yield cycle.
