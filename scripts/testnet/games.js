const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address, await ethers.provider.getBalance(deployer.address));

    /* Settings */

    const gameContract = await ethers.getContractAt("Game", "0x6f244f852f560Cd7Ae16454Adff2b2A5Cd408c5a");
    const awardContract = await ethers.getContractAt("USDC", "0xe75C08A708b1c328e990e60Cb1bd081714c58Ed2");
    const badgeContract = await ethers.getContractAt("Verified", "0xC6B4dC567149757864Cbd40D42482F4e9db4f840");

    console.log("Game:", await gameContract.getAddress());
    console.log("USDC:", await awardContract.getAddress());
    console.log("Verified:", await badgeContract.getAddress());

    /* Get NFT data */
    console.log(await gameContract.getNfts(0, 3));
    // console.log((await gameContract.counterToTokenId(0)).toString(16));
}

// Error handling for async/await
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
