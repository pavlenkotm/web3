const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("DEXContract", function () {
    // Fixture to deploy contracts
    async function deployDEXFixture() {
        const [owner, user1, user2] = await ethers.getSigners();

        // Deploy test tokens
        const TestToken = await ethers.getContractFactory("TestToken");
        const tokenA = await TestToken.deploy("Token A", "TKA", 18, 1000000);
        const tokenB = await TestToken.deploy("Token B", "TKB", 18, 1000000);

        // Deploy DEX contract
        const DEXContract = await ethers.getContractFactory("DEXContract");
        const dex = await DEXContract.deploy();

        // Mint tokens to users
        const mintAmount = ethers.parseEther("10000");
        await tokenA.mint(user1.address, mintAmount);
        await tokenA.mint(user2.address, mintAmount);
        await tokenB.mint(user1.address, mintAmount);
        await tokenB.mint(user2.address, mintAmount);

        return { dex, tokenA, tokenB, owner, user1, user2 };
    }

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            const { dex, owner } = await loadFixture(deployDEXFixture);
            expect(await dex.owner()).to.equal(owner.address);
        });
    });

    describe("Deposits", function () {
        it("Should allow users to deposit tokens", async function () {
            const { dex, tokenA, user1 } = await loadFixture(deployDEXFixture);

            const depositAmount = ethers.parseEther("100");

            // Approve DEX to spend tokens
            await tokenA.connect(user1).approve(await dex.getAddress(), depositAmount);

            // Deposit
            await expect(dex.connect(user1).deposit(await tokenA.getAddress(), depositAmount))
                .to.emit(dex, "Deposit")
                .withArgs(user1.address, await tokenA.getAddress(), depositAmount);

            // Check balance
            const balance = await dex.getBalance(user1.address, await tokenA.getAddress());
            expect(balance).to.equal(depositAmount);
        });

        it("Should fail to deposit without approval", async function () {
            const { dex, tokenA, user1 } = await loadFixture(deployDEXFixture);

            const depositAmount = ethers.parseEther("100");

            // Try to deposit without approval
            await expect(
                dex.connect(user1).deposit(await tokenA.getAddress(), depositAmount)
            ).to.be.reverted;
        });

        it("Should fail to deposit zero amount", async function () {
            const { dex, tokenA, user1 } = await loadFixture(deployDEXFixture);

            await expect(
                dex.connect(user1).deposit(await tokenA.getAddress(), 0)
            ).to.be.revertedWith("Amount must be greater than 0");
        });
    });

    describe("Withdrawals", function () {
        it("Should allow users to withdraw tokens", async function () {
            const { dex, tokenA, user1 } = await loadFixture(deployDEXFixture);

            const depositAmount = ethers.parseEther("100");
            const withdrawAmount = ethers.parseEther("50");

            // Deposit first
            await tokenA.connect(user1).approve(await dex.getAddress(), depositAmount);
            await dex.connect(user1).deposit(await tokenA.getAddress(), depositAmount);

            // Withdraw
            await expect(dex.connect(user1).withdraw(await tokenA.getAddress(), withdrawAmount))
                .to.emit(dex, "Withdraw")
                .withArgs(user1.address, await tokenA.getAddress(), withdrawAmount);

            // Check balance
            const balance = await dex.getBalance(user1.address, await tokenA.getAddress());
            expect(balance).to.equal(depositAmount - withdrawAmount);
        });

        it("Should fail to withdraw more than balance", async function () {
            const { dex, tokenA, user1 } = await loadFixture(deployDEXFixture);

            const depositAmount = ethers.parseEther("100");
            const withdrawAmount = ethers.parseEther("200");

            // Deposit first
            await tokenA.connect(user1).approve(await dex.getAddress(), depositAmount);
            await dex.connect(user1).deposit(await tokenA.getAddress(), depositAmount);

            // Try to withdraw more than balance
            await expect(
                dex.connect(user1).withdraw(await tokenA.getAddress(), withdrawAmount)
            ).to.be.revertedWith("Insufficient balance");
        });
    });

    describe("Order Placement", function () {
        it("Should allow owner to place buy orders", async function () {
            const { dex, tokenA, tokenB, owner, user1 } = await loadFixture(deployDEXFixture);

            const depositAmount = ethers.parseEther("2000");
            const orderPrice = ethers.parseEther("2000");
            const orderQuantity = ethers.parseEther("1");

            // User deposits quote token (tokenB)
            await tokenB.connect(user1).approve(await dex.getAddress(), depositAmount);
            await dex.connect(user1).deposit(await tokenB.getAddress(), depositAmount);

            // Owner places order for user
            await expect(
                dex.connect(owner).placeOrder(
                    1, // order ID
                    user1.address,
                    await tokenA.getAddress(), // base token
                    await tokenB.getAddress(), // quote token
                    0, // BUY
                    1, // LIMIT
                    orderPrice,
                    orderQuantity
                )
            ).to.emit(dex, "OrderPlaced")
            .withArgs(1, user1.address, 0, orderPrice, orderQuantity);

            // Check order
            const order = await dex.getOrder(1);
            expect(order.id).to.equal(1);
            expect(order.user).to.equal(user1.address);
            expect(order.side).to.equal(0); // BUY
        });

        it("Should lock funds when placing order", async function () {
            const { dex, tokenA, tokenB, owner, user1 } = await loadFixture(deployDEXFixture);

            const depositAmount = ethers.parseEther("2000");
            const orderPrice = ethers.parseEther("2000");
            const orderQuantity = ethers.parseEther("1");

            // User deposits quote token
            await tokenB.connect(user1).approve(await dex.getAddress(), depositAmount);
            await dex.connect(user1).deposit(await tokenB.getAddress(), depositAmount);

            const balanceBefore = await dex.getBalance(user1.address, await tokenB.getAddress());

            // Place order
            await dex.connect(owner).placeOrder(
                1,
                user1.address,
                await tokenA.getAddress(),
                await tokenB.getAddress(),
                0, // BUY
                1, // LIMIT
                orderPrice,
                orderQuantity
            );

            const balanceAfter = await dex.getBalance(user1.address, await tokenB.getAddress());
            const expectedLocked = (orderPrice * orderQuantity) / ethers.parseEther("1");

            expect(balanceBefore - balanceAfter).to.equal(expectedLocked);
        });
    });

    describe("Trade Execution", function () {
        it("Should execute trades between matched orders", async function () {
            const { dex, tokenA, tokenB, owner, user1, user2 } = await loadFixture(deployDEXFixture);

            const tradePrice = ethers.parseEther("2000");
            const tradeQuantity = ethers.parseEther("1");

            // User1 deposits quote token for buy order
            await tokenB.connect(user1).approve(await dex.getAddress(), ethers.parseEther("2000"));
            await dex.connect(user1).deposit(await tokenB.getAddress(), ethers.parseEther("2000"));

            // User2 deposits base token for sell order
            await tokenA.connect(user2).approve(await dex.getAddress(), tradeQuantity);
            await dex.connect(user2).deposit(await tokenA.getAddress(), tradeQuantity);

            // Place buy order
            await dex.connect(owner).placeOrder(
                1,
                user1.address,
                await tokenA.getAddress(),
                await tokenB.getAddress(),
                0, // BUY
                1, // LIMIT
                tradePrice,
                tradeQuantity
            );

            // Place sell order
            await dex.connect(owner).placeOrder(
                2,
                user2.address,
                await tokenA.getAddress(),
                await tokenB.getAddress(),
                1, // SELL
                1, // LIMIT
                tradePrice,
                tradeQuantity
            );

            // Execute trade
            await expect(
                dex.connect(owner).executeTrade(1, 2, tradePrice, tradeQuantity)
            ).to.emit(dex, "TradeExecuted")
            .withArgs(1, 2, tradePrice, tradeQuantity);

            // Check balances after trade
            const user1BaseBalance = await dex.getBalance(user1.address, await tokenA.getAddress());
            const user2QuoteBalance = await dex.getBalance(user2.address, await tokenB.getAddress());

            expect(user1BaseBalance).to.equal(tradeQuantity);
            expect(user2QuoteBalance).to.equal((tradePrice * tradeQuantity) / ethers.parseEther("1"));
        });
    });

    describe("Order Cancellation", function () {
        it("Should allow users to cancel their orders", async function () {
            const { dex, tokenA, tokenB, owner, user1 } = await loadFixture(deployDEXFixture);

            const depositAmount = ethers.parseEther("2000");
            const orderPrice = ethers.parseEther("2000");
            const orderQuantity = ethers.parseEther("1");

            // Deposit and place order
            await tokenB.connect(user1).approve(await dex.getAddress(), depositAmount);
            await dex.connect(user1).deposit(await tokenB.getAddress(), depositAmount);

            await dex.connect(owner).placeOrder(
                1,
                user1.address,
                await tokenA.getAddress(),
                await tokenB.getAddress(),
                0, // BUY
                1, // LIMIT
                orderPrice,
                orderQuantity
            );

            const balanceBefore = await dex.getBalance(user1.address, await tokenB.getAddress());

            // Cancel order
            await expect(dex.connect(user1).cancelOrder(1))
                .to.emit(dex, "OrderCancelled")
                .withArgs(1);

            // Check that funds are returned
            const balanceAfter = await dex.getBalance(user1.address, await tokenB.getAddress());
            expect(balanceAfter).to.be.greaterThan(balanceBefore);

            // Check order status
            const order = await dex.getOrder(1);
            expect(order.status).to.equal(3); // CANCELLED
        });

        it("Should not allow non-owner to cancel others' orders", async function () {
            const { dex, tokenA, tokenB, owner, user1, user2 } = await loadFixture(deployDEXFixture);

            const depositAmount = ethers.parseEther("2000");
            const orderPrice = ethers.parseEther("2000");
            const orderQuantity = ethers.parseEther("1");

            // User1 deposits and places order
            await tokenB.connect(user1).approve(await dex.getAddress(), depositAmount);
            await dex.connect(user1).deposit(await tokenB.getAddress(), depositAmount);

            await dex.connect(owner).placeOrder(
                1,
                user1.address,
                await tokenA.getAddress(),
                await tokenB.getAddress(),
                0, // BUY
                1, // LIMIT
                orderPrice,
                orderQuantity
            );

            // User2 tries to cancel user1's order
            await expect(
                dex.connect(user2).cancelOrder(1)
            ).to.be.revertedWith("Not authorized");
        });
    });
});
