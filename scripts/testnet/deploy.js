const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address, await ethers.provider.getBalance(deployer.address));

    /* Settings */

    const awardContract = await ethers.deployContract("USDC");
    await awardContract.waitForDeployment();

    const Game = await ethers.getContractFactory("Game");
    const gameContract = await upgrades.deployProxy(
        Game,
        [
            deployer.address,
            await awardContract.getAddress()
        ],
        {
            initializer: "initialize(address,address)",
            unsafeAllow: ["constructor", "state-variable-immutable"],
        }
    );
    await gameContract.waitForDeployment();

    const badgeContract = await ethers.deployContract("Verified");
    await badgeContract.waitForDeployment();

    console.log("Game:", await gameContract.getAddress());
    console.log("USDC:", await awardContract.getAddress());
    console.log("Verified:", await badgeContract.getAddress());

    {
        const txMint = await awardContract.mint(deployer.address, ethers.parseUnits("100", 18));
        await txMint.wait();
        console.log("USDC mint:", txMint.hash);

        const txApprove = await awardContract.approve(await gameContract.getAddress(), ethers.MaxUint256);
        await txApprove.wait();
        console.log("USDC approve:", txApprove.hash);
    }
}

// Error handling for async/await
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

// Game: 0x6f244f852f560Cd7Ae16454Adff2b2A5Cd408c5a
// USDC: 0xe75C08A708b1c328e990e60Cb1bd081714c58Ed2
// Verified: 0xC6B4dC567149757864Cbd40D42482F4e9db4f840
