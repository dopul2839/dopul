# DGold DSilver Project (ICP Implementation)

## Blockhack Devpost 2024

## Overview

The DGold DSilver project aims to create value NFTs representing gold and silver reserves. This project will allow users to mint, validate, and transfer these NFTs securely using the Internet Computer Protocol (ICP) blockchain. Additionally, users can stake their NFTs for monthly rewards in DGSu tokens and participate in a DEX to exchange DGSU tokens for other cryptocurrencies like ICP, ADA, SOL, Bitcoin, or USDT.

## Project Tasks

### Major Tasks for the Hackathon

1. **Create Gold NFT and Silver NFT**
2. **Validate the NFT's Authenticity**
3. **Transfer NFT from Person A to Person B**
   - Both Person A and B will pay transfer fees.
4. **Try to make DEX available to get the DGSU Tokens by Swapping for ICP, ADA, SOL, Bitcoin, or USDT**
5. **Stake Gold or Silver NFTs for Monthly Rewards in DGSU Tokens**
   - APY: Approximately 24% per year (2% per month).
   - Staking periods: 6 months or 12 months (specifications pending).

## Project Details

### Token and NFT Creation

- **ICP Blockchain** was used to create canisters and, in turn, create tokens and NFTs.
- **UGoldg**: Stores gold reserves in grams (RGoldg: Total reserve in the system).
  - RGoldg is the total of all UGoldg in the system, audited and verified.
- **USilverg**: Stores silver reserves in grams (RSilverg: Total reserve in the system).
  - RSilverg is the total of all USilverg in the system, audited and verified.
- **DGSu**: Utility token for incentives (creators, validators, liquidity providers, admins, supporters, marketing, tech, VCs, early adopters, TRUST foundation, etc.).

### Functions

1. **Create Gold NFT for 1 Gram (99.99% Pure)**

   - Validate the gold as real. (Validator validates the real gold and creates NFT.)
   - Update UGoldg balance by 1 gram in the system.
   - Validator (VAL1) will get 100 DGSu tokens (incentive).
   - User 1 will get 200 DGSu tokens (incentive).
   - RGoldg updated accordingly.

2. **Create Silver NFT for 1 Oz (31.1035 grams, 99.99% Pure)**

   - Validate the silver as real. (Validator validates the real silver and creates NFT.)
   - Update USilverg balance by 31.1035 grams in the system.
   - Validator (VAL2) will get 93.31 DGSu tokens (incentive).
   - User 1 will get 62.21 DGSu tokens (incentive).
   - RSilverg updated accordingly.

3. **Transfer NFT of Gold/Silver Grams**
   - User 1 can transfer Silver NFT to User 2.
   - User 2 transfers 1500 DGSu tokens to User 1.
   - Transfer fees for both users.

## Script Execution

To start the environment and execute the project setup, clone the repository, give execution permissions to the script, and run it:

```bash
git clone https://github.com/apatel2582/DGoldDSilverICP.git
cd DGoldDSilverICP/
chmod +x sample.sh
./sample.sh
```

## Milestones

### Current Phase

- **Creating and validating NFTs for gold and silver.**
- **Transferring NFTs between users.**
- **Deploying canisters for ledger and NFT functionality.**

### Upcoming Phases

1. **Implement Token Transfers during NFT transfers.**
1. **Implement DEX for swapping DGSU tokens with other cryptocurrencies.**
1. **Enable staking for gold and silver NFTs with monthly rewards.**
1. **Develop comprehensive user guides and process charts for NFT creation and validation globally.**
1. **Establish master validators and creators in different regions.**
1. **Prepare detailed documentation, including mission, vision, goals, issues, and a 2-year plan.**

---

By following this guide, you can effectively set up and deploy the DGold DSilver project components, ensuring a smooth and secure implementation of the system.

## Team Members - DGold DSilver

- **Jerry**: Project Manager
- **Spencer**: Business Analyst
- **Anishkumar Patel**: Blockchain Developer
- **Gopikrishnan Rajeev**: Developer

## Sponsors

- **Nodle.com**
- **Earn IOT Daily**
- **Angels of Ryina**
- **Metaverse Gaming**
- **Team Kartik**
