const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Generic Token", function () {
    async function deployTokenFixture() {
        [owner, addr1, addr2] = await ethers.getSigners();

        const Generic = await ethers.getContractFactory("Generic");

        const genericToken = await Arawx.deploy()

        await genericToken.deployed()

        return { Generic, genericToken, owner, addr1, addr2 }
    }

    describe("Deployment", function () {
        it("Checking token owner", async function () {
            const { genericToken, owner } = await loadFixture(deployTokenFixture);
            
            expect(await genericToken.owner()).to.equal(owner.address);
        });

        it("Checking if owner had the total supply", async function () {
            const { genericToken, owner } = await loadFixture(deployTokenFixture);
            
            expect(await genericToken.balanceOf(owner.address)).to.equal(await genericToken._totalSupply());
        });
    });

    describe("Transaction", function () {
        it("Checking token transfer between two accounts", async function () {
            const { genericToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);

            await expect(genericToken.transfer(addr1.address, 50))
            .to.changeTokenBalances(genericToken, [owner, addr1], [-50, 50]);

            await expect(genericToken.connect(addr1).transfer(addr2.address, 50))
            .to.changeTokenBalances(genericToken, [addr1, addr2], [-50, 50]);
        });

        it("Checking transfer event emission", async function () {
            const { genericToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
      
            await expect(genericToken.transfer(addr1.address, 50))
            .to.emit(genericToken, "Transfer")
            .withArgs(owner.address, addr1.address, 50);
      
            await expect(genericToken.connect(addr1).transfer(addr2.address, 50))
            .to.emit(genericToken, "Transfer")
            .withArgs(addr1.address, addr2.address, 50);
        });
      
        it("Checking transaction abortion", async function () {
            const { genericToken, owner, addr1 } = await loadFixture(deployTokenFixture);
      
            const initialOwnerBalance = await genericToken.balanceOf(owner.address);
      
            await expect(genericToken.connect(addr1).transfer(owner.address, 1))
            .to.be.revertedWithCustomError(genericToken, "InsufficientBalance");
      
            expect(await genericToken.balanceOf(owner.address)).to.equal(initialOwnerBalance);
        });
    });
});