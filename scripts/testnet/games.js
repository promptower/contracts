const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address, await ethers.provider.getBalance(deployer.address));

    /* Settings */

    const gameContract = await ethers.getContractAt("Game", "0xcf7EC4BB7c0226FAF75cc81308D6361936b065f6");
    const awardContract = await ethers.getContractAt("USDC", "0x41Db4368f74A18240deDB94BCc80dbED1E238c7B");
    const badgeContract = await ethers.getContractAt("Verified", "0x9e378EC114B2C35305A166e99feC5C47013188ec");

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
