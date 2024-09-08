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

    /* Mint */
    for (let i = 0; i < 5; i++) {
        const _currentTime = (await ethers.provider.getBlock()).timestamp;
        const awards = ethers.parseUnits("10", 18);
        const metadata = {
            name: `test game name #${i}.`,
            description: `test game description #${i}.`,
            gameType: "secret",
            prompt: ethers.encodeBytes32String("MyPrompt"),
            secret: ethers.encodeBytes32String("MySecret"),
            start: _currentTime, // Current timestamp (start)
            end: _currentTime + 86400, // End timestamp (24 hours from now)
            winner: ethers.ZeroAddress,
        };
        console.log(metadata);

        {
            const txMint = await gameContract.mint(deployer.address, metadata, awards);
            await txMint.wait();
            console.log("NFT mint:", txMint.hash);
        }
    }

    /* Get NFT data */
    console.log(await gameContract.getNfts(0, 5));
}

// Error handling for async/await
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
