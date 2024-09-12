const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address, await ethers.provider.getBalance(deployer.address));
    // process.exit(1);

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
    const gameFrontendContract = await ethers.deployContract(
        "GameFrontend",
        [
            await gameContract.getAddress()
        ]
    );
    await gameFrontendContract.waitForDeployment();

    const badgeContract = await ethers.deployContract("Verified");
    await badgeContract.waitForDeployment();

    console.log("Game:", await gameContract.getAddress());
    console.log("GameFrontend:", await gameFrontendContract.getAddress());
    console.log("USDC:", await awardContract.getAddress());
    console.log("Verified:", await badgeContract.getAddress());

    {
        const txMint = await awardContract.mint(deployer.address, ethers.parseUnits("10000000", 18));
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

// Game: 0xB24a2fCEF85F0201C8c26A734677f0ceb4901866
// GameFrontend: 0xCA1481483375B9563e6dF7646B50F8AC00D2b233
// USDC: 0x49CABE91af53c01df296178c13EC5a0f824aea57
// Verified: 0x5a050A10907184831A9Fa136e191b2C940Df6C7B

// USDC mint: 0xc735997b5326a2d4a33daf6c008720020f581a88481a3c270de685b31b9b0118
// USDC approve: 0x921858330a46b4422c8f3b73d3779972db103573913060aeb84dbf3d5688d5dc
