const hre = require("hardhat");

async function main() {
    console.log("🎨 Deploying NFT Collection...\n");

    const [deployer] = await hre.ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const NFTCollection = await hre.ethers.getContractFactory("NFTCollection");
    const nft = await NFTCollection.deploy(
        "Web3 NFT Collection",
        "W3NFT",
        10000,
        hre.ethers.parseEther("0.08")
    );

    await nft.waitForDeployment();
    console.log("✅ NFT Collection deployed to:", await nft.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
