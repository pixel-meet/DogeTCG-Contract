# Trading card game contract based on ERC404

This is a powerful endless trading card game contract based on ERC404 standard.
Every mint gets a unrevealed card that can be revealed by the owner of the card.



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


