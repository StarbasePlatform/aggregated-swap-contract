# aggregated-swap-contract

## Introduction
Starbase’s interface resembles that of many other decentralized exchanges (DEXs) in the DeFi space. However, beneath the surface, it boasts several advanced features designed to help users save money on their swaps. Check our website at https://www.starbase.ag

### Best price search
Starbase leverages advanced algorithms to aggregate liquidity from multiple DEXs, ensuring users always get the best prices for their trades. By intelligently routing orders and splitting trades across different platforms, Starbase maximizes liquidity and minimizes slippage, offering users unparalleled price discovery capabilities. This aggregation method is distinct from the automated market maker (AMM) protocols that individual DEXs use. The Starbase router consistently provides better rates, putting more money back into users’ wallets. This advantage becomes even more pronounced as the trade size increases. 

### Fast transactions
With Starbase, users can enjoy lightning-fast transaction speeds, thanks to the high throughput and low latency of the BASE network infrastructure. Transactions are processed quickly and efficiently, minimizing wait times and optimizing trading performance

## Included
- Smart contract source code (located in the `contracts/` folder)
- Contract interfaces (`ABI` and interface definitions)

## How to Use
1. Clone the repository:
   ```bash
   git clone <repository_url>
   ```
2. Install dependencies (if applicable):
   ```bash
   npm install
   ```
3. Compile the contracts:
   ```bash
   npx hardhat compile
   ```
4. Interact with the contracts:
   - Use the provided ABI to interact with the blockchain (tools such as [Ethers.js](https://docs.ethers.io/) or [web3.js](https://web3js.readthedocs.io/) are recommended).


