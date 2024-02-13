# Trading card game contract based on ERC404

DogeTCG represents an innovative evolution in the trading card game (TCG) ecosystem, utilizing the latest ERC-404 standard of Pandora (Fork). 
Our mission is to establish a fully operational TCG system that operates entirely on-chain, ensuring unparalleled reliability and integrity.
Unlike many existing NFTs, DogeTCG eliminates the possibility of attribute manipulation. All card attributes are securely stored on-chain, with CID links pointing to immutable IPFS image sources. This approach guarantees that, unlike other NFT systems, DogeTCG assets are not susceptible to tampering because their existence and attributes are verified and maintained directly on the blockchain.

Starting with Generation #1, these cards mark a significant milestone from which Generation #2 and beyond will evolve the system.

## Usage

### Pre Requisites

Before running any command, make sure to install dependencies:

```sh
yarn install
```

### Compile

Compile the smart contracts with Hardhat:

```sh
yarn compile
```

### Test

Run the tests:

```sh
yarn test
```

#### Test gas costs

To get a report of gas costs, set env `REPORT_GAS` to true

To take a snapshot of the contract's gas costs

```sh
yarn test:gas
```


