import { ethers } from 'hardhat';
import { Contract, ContractFactory } from 'ethers';

async function main(): Promise<void> {
  const DogeTcgFactory: ContractFactory = await ethers.getContractFactory(
    'DogeTcg',
  );
  const DogeTcg: Contract = await DogeTcgFactory.deploy();
  await DogeTcg.deployed();
  console.log('DogeTcg deployed to: ', DogeTcg.address);
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
