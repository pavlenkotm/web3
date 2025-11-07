const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTCollection", function () {
    let nftCollection;
    let owner;
    let addr1;
    let addr2;

    const NAME = "Test NFT Collection";
    const SYMBOL = "TNFT";
    const MAX_SUPPLY = 100;
    const MINT_PRICE = ethers.parseEther("0.1");

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        const NFTCollection = await ethers.getContractFactory("NFTCollection");
        nftCollection = await NFTCollection.deploy(
            NAME,
            SYMBOL,
            MAX_SUPPLY,
            MINT_PRICE
        );
        await nftCollection.waitForDeployment();
    });

    describe("Deployment", function () {
        it("Should set the correct name and symbol", async function () {
            expect(await nftCollection.name()).to.equal(NAME);
            expect(await nftCollection.symbol()).to.equal(SYMBOL);
        });

        it("Should set the correct max supply", async function () {
            expect(await nftCollection.maxSupply()).to.equal(MAX_SUPPLY);
        });

        it("Should set the correct mint price", async function () {
            expect(await nftCollection.mintPrice()).to.equal(MINT_PRICE);
        });

        it("Should set the owner correctly", async function () {
            expect(await nftCollection.owner()).to.equal(owner.address);
        });

        it("Should start with minting enabled", async function () {
            expect(await nftCollection.mintingEnabled()).to.be.true;
        });
    });

    describe("Minting", function () {
        it("Should mint NFT with correct payment", async function () {
            const uri = "ipfs://QmTest1";
            await nftCollection.connect(addr1).mint(addr1.address, uri, {
                value: MINT_PRICE
            });

            expect(await nftCollection.ownerOf(1)).to.equal(addr1.address);
            expect(await nftCollection.tokenURI(1)).to.equal(uri);
            expect(await nftCollection.totalSupply()).to.equal(1);
        });

        it("Should fail to mint without sufficient payment", async function () {
            await expect(
                nftCollection.connect(addr1).mint(addr1.address, "ipfs://QmTest1", {
                    value: ethers.parseEther("0.05")
                })
            ).to.be.revertedWith("Insufficient payment");
        });

        it("Should fail to mint when minting is disabled", async function () {
            await nftCollection.toggleMinting();

            await expect(
                nftCollection.connect(addr1).mint(addr1.address, "ipfs://QmTest1", {
                    value: MINT_PRICE
                })
            ).to.be.revertedWith("Minting is disabled");
        });

        it("Should emit NFTMinted event", async function () {
            const uri = "ipfs://QmTest1";
            await expect(
                nftCollection.connect(addr1).mint(addr1.address, uri, {
                    value: MINT_PRICE
                })
            )
                .to.emit(nftCollection, "NFTMinted")
                .withArgs(1, addr1.address, uri);
        });
    });

    describe("Owner Minting", function () {
        it("Should allow owner to mint for free", async function () {
            const uri = "ipfs://QmTest1";
            await nftCollection.ownerMint(addr1.address, uri);

            expect(await nftCollection.ownerOf(1)).to.equal(addr1.address);
            expect(await nftCollection.tokenMinter(1)).to.equal(owner.address);
        });

        it("Should fail when non-owner tries to use ownerMint", async function () {
            await expect(
                nftCollection.connect(addr1).ownerMint(addr1.address, "ipfs://QmTest1")
            ).to.be.reverted;
        });

        it("Should allow batch minting", async function () {
            const uris = ["ipfs://QmTest1", "ipfs://QmTest2", "ipfs://QmTest3"];
            await nftCollection.batchMint(addr1.address, uris);

            expect(await nftCollection.totalSupply()).to.equal(3);
            expect(await nftCollection.balanceOf(addr1.address)).to.equal(3);
        });
    });

    describe("Supply Management", function () {
        it("Should track remaining supply correctly", async function () {
            expect(await nftCollection.remainingSupply()).to.equal(MAX_SUPPLY);

            await nftCollection.ownerMint(addr1.address, "ipfs://QmTest1");

            expect(await nftCollection.remainingSupply()).to.equal(MAX_SUPPLY - 1);
        });

        it("Should prevent minting beyond max supply", async function () {
            // Mint to max supply
            for (let i = 0; i < MAX_SUPPLY; i++) {
                await nftCollection.ownerMint(addr1.address, `ipfs://QmTest${i}`);
            }

            await expect(
                nftCollection.ownerMint(addr1.address, "ipfs://QmTestExtra")
            ).to.be.revertedWith("Max supply reached");
        });

        it("Should allow owner to update max supply", async function () {
            const newMaxSupply = 200;
            await nftCollection.setMaxSupply(newMaxSupply);

            expect(await nftCollection.maxSupply()).to.equal(newMaxSupply);
        });

        it("Should not allow setting max supply below current supply", async function () {
            await nftCollection.ownerMint(addr1.address, "ipfs://QmTest1");
            await nftCollection.ownerMint(addr1.address, "ipfs://QmTest2");

            await expect(
                nftCollection.setMaxSupply(1)
            ).to.be.revertedWith("Cannot set below current supply");
        });
    });

    describe("Token Enumeration", function () {
        beforeEach(async function () {
            await nftCollection.ownerMint(addr1.address, "ipfs://QmTest1");
            await nftCollection.ownerMint(addr1.address, "ipfs://QmTest2");
            await nftCollection.ownerMint(addr2.address, "ipfs://QmTest3");
        });

        it("Should return all tokens owned by address", async function () {
            const tokens = await nftCollection.tokensOfOwner(addr1.address);

            expect(tokens.length).to.equal(2);
            expect(tokens[0]).to.equal(1);
            expect(tokens[1]).to.equal(2);
        });

        it("Should return correct total supply", async function () {
            expect(await nftCollection.totalSupply()).to.equal(3);
        });
    });

    describe("Price Management", function () {
        it("Should allow owner to update mint price", async function () {
            const newPrice = ethers.parseEther("0.2");
            await nftCollection.setMintPrice(newPrice);

            expect(await nftCollection.mintPrice()).to.equal(newPrice);
        });

        it("Should emit MintPriceUpdated event", async function () {
            const newPrice = ethers.parseEther("0.2");

            await expect(nftCollection.setMintPrice(newPrice))
                .to.emit(nftCollection, "MintPriceUpdated")
                .withArgs(newPrice);
        });
    });

    describe("Withdrawal", function () {
        it("Should allow owner to withdraw funds", async function () {
            // Mint some NFTs to add funds to contract
            await nftCollection.connect(addr1).mint(addr1.address, "ipfs://QmTest1", {
                value: MINT_PRICE
            });

            const initialBalance = await ethers.provider.getBalance(owner.address);
            const contractBalance = await ethers.provider.getBalance(await nftCollection.getAddress());

            await nftCollection.withdraw();

            const finalBalance = await ethers.provider.getBalance(owner.address);
            expect(finalBalance).to.be.gt(initialBalance);
        });

        it("Should fail to withdraw when no balance", async function () {
            await expect(nftCollection.withdraw()).to.be.revertedWith("No balance to withdraw");
        });
    });
});
