import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture, mine } from "@nomicfoundation/hardhat-network-helpers";

describe("DogeTCG", function () {

  async function deployDogeTCGFixture() {
    const [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    const DogeTCG = await ethers.getContractFactory("DogeTCG");
    const dogeTCG = await DogeTCG.deploy(await owner.getAddress());
    await dogeTCG.setWhitelist(await owner.getAddress(), true);

    return { dogeTCG, owner, addr1, addr2, addrs };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { dogeTCG, owner } = await loadFixture(deployDogeTCGFixture);
      expect(await dogeTCG.owner()).to.equal(await owner.getAddress());
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const { dogeTCG, owner } = await loadFixture(deployDogeTCGFixture);
      const ownerBalance = await dogeTCG.balanceOf(await owner.getAddress());
      expect(await dogeTCG.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Token Transfers and Minting", function () {
    it("Transferring tokens should adjust balances and potentially trigger minting", async function () {
      const amount = 10;
      const { dogeTCG, owner, addr1 } = await loadFixture(deployDogeTCGFixture);
      const transferAmount = ethers.utils.parseUnits(amount.toString(), 18);
      await dogeTCG.connect(owner).transfer(await addr1.getAddress(), transferAmount);
      const owned = await dogeTCG.getTokenIdsOwnedBy(addr1.getAddress());
      expect(owned.length).to.be.equal(amount);
    });
  });

  describe("Reveal Card", function () {
    it("Should reveal a card", async function () {
      const amount = 10;
      const { dogeTCG, owner, addr1 } = await loadFixture(deployDogeTCGFixture);
      const transferAmount = ethers.utils.parseUnits(amount.toString(), 18);
      dogeTCG.connect(owner).addImgSource('test.png');
      await dogeTCG.connect(owner).transfer(await addr1.getAddress(), transferAmount);

      const tokenId = 1;
      await dogeTCG.connect(addr1).revealCard(tokenId);
      const tokeuri = await dogeTCG.tokenURI(tokenId);
      console.log(tokeuri);
      expect(tokeuri).to.contain('DogeTCG');
      // expect(card.attack1).to.not.be.empty;
      // expect(card.attack2).to.not.be.empty;
      // expect(card.attack3).to.not.be.empty;
      // expect(card.name).to.not.be.empty;
    });

  });

});
