const { ethers } = require("hardhat");

async function main() {
    console.log("=== DEX Trading Engine Deployment ===\n");

    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with account:", deployer.address);

    const balance = await ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.formatEther(balance), "ETH\n");

    // Deploy Test Tokens
    console.log("--- Deploying Test Tokens ---");

    const TestToken = await ethers.getContractFactory("TestToken");

    // Deploy ETH token (for testing)
    const ethToken = await TestToken.deploy(
        "Test Ethereum",
        "tETH",
        18,
        1000000 // 1 million tokens
    );
    await ethToken.waitForDeployment();
    const ethTokenAddress = await ethToken.getAddress();
    console.log("✓ tETH deployed to:", ethTokenAddress);

    // Deploy USDT token (for testing)
    const usdtToken = await TestToken.deploy(
        "Test USDT",
        "tUSDT",
        18,
        10000000 // 10 million tokens
    );
    await usdtToken.waitForDeployment();
    const usdtTokenAddress = await usdtToken.getAddress();
    console.log("✓ tUSDT deployed to:", usdtTokenAddress);

    // Deploy DEX Contract
    console.log("\n--- Deploying DEX Contract ---");

    const DEXContract = await ethers.getContractFactory("DEXContract");
    const dexContract = await DEXContract.deploy();
    await dexContract.waitForDeployment();
    const dexAddress = await dexContract.getAddress();
    console.log("✓ DEX Contract deployed to:", dexAddress);

    // Mint some tokens to deployer for testing
    console.log("\n--- Minting Test Tokens ---");

    const mintAmount = ethers.parseEther("10000");
    await ethToken.mint(deployer.address, mintAmount);
    console.log("✓ Minted 10,000 tETH to deployer");

    await usdtToken.mint(deployer.address, mintAmount);
    console.log("✓ Minted 10,000 tUSDT to deployer");

    // Summary
    console.log("\n=== Deployment Summary ===");
    console.log("DEX Contract:", dexAddress);
    console.log("tETH Token:", ethTokenAddress);
    console.log("tUSDT Token:", usdtTokenAddress);
    console.log("\nDeployer Address:", deployer.address);

    // Save deployment info
    const deploymentInfo = {
        network: (await ethers.provider.getNetwork()).name,
        chainId: (await ethers.provider.getNetwork()).chainId.toString(),
        deployer: deployer.address,
        contracts: {
            DEXContract: dexAddress,
            tETH: ethTokenAddress,
            tUSDT: usdtTokenAddress
        },
        timestamp: new Date().toISOString()
    };

    const fs = require('fs');
    fs.writeFileSync(
        'deployment.json',
        JSON.stringify(deploymentInfo, null, 2)
    );
    console.log("\n✓ Deployment info saved to deployment.json");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
