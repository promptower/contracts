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

    const salt = await gameContract.salts(deployer.address);
    console.log("salt: ", salt);

    const _currentTime = (await ethers.provider.getBlock()).timestamp;
    const awards = ethers.parseUnits("10", 18);
    const metadata = {
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

    /* Token URI */
    {
        const tokenId = (await gameContract["getAccountAddress(address,uint256)"](deployer, salt)).toString();
        console.log("tokenId:", tokenId);

        const tokenURI = await gameContract.tokenURI(tokenId);
        console.log("tokenURI:", tokenURI);
    }

    /* Tokens */
    {
        const balance = (await gameContract.balanceOf(deployer));
        console.log("balance:", balance);

        const tokenId = (await gameContract.tokenOfOwnerByIndex(deployer, salt)).toString();
        console.log("tokenId:", tokenId);

        const metas = (await gameContract.metas(tokenId));
        console.log("metas:", metas);
    }

    /* Wallet */
    {
        const tokenId = "0x" + (await gameContract.tokenOfOwnerByIndex(deployer, salt)).toString(16);
        console.log("tokenId:", tokenId);

        const wallet = await ethers.getContractAt("Wallet", tokenId);
        const balance = await awardContract.balanceOf(await wallet.getAddress());
        console.log("awards:", ethers.formatUnits(balance, 18));

        const owner = await wallet.owner();
        console.log("owner:", owner);
    }

    // /* Case 1: Winner */
    // {
    //     const tokenId = (await gameContract.tokenOfOwnerByIndex(deployer, salt)).toString();
    //     console.log("tokenId:", tokenId);

    //     const txSolved = await gameContract.solved(tokenId, "0x71BB92C4e6B6bb179cB99a6866f53C36550c3698");
    //     await txSolved.wait();
    //     console.log("solved:", txSolved.hash);
    // }
    // {
    //     const tokenId = "0x" + (await gameContract.tokenOfOwnerByIndex(deployer, salt)).toString(16);
    //     console.log("tokenId:", tokenId);

    //     const wallet = await ethers.getContractAt("Wallet", tokenId);
    //     const balance = await awardContract.balanceOf(await wallet.getAddress());
    //     console.log("awards:", ethers.formatUnits(balance, 18));

    //     const owner = await wallet.owner();
    //     console.log("owner:", owner);
    // }
    // {
    //     const tokenId = (await gameContract.tokenOfOwnerByIndex(deployer, salt)).toString();
    //     console.log("tokenId:", tokenId);

    //     const isSolved = await gameContract.isSolved(tokenId);
    //     console.log("isSolved:", isSolved);
    // }

    /* Case 2: Badge */
    {
        const tokenId = "0x" + (await gameContract.tokenOfOwnerByIndex(deployer, salt)).toString(16);
        console.log("tokenId:", tokenId);

        const txMint = await badgeContract.mint(tokenId);
        await txMint.wait();
        console.log("Badge mint:", txMint.hash);

        const owner = await badgeContract.ownerOf(((await badgeContract.totalSupply()) - 1n).toString());
        console.log("owner:", owner);
    }
    {
        const tokenId = (await gameContract.tokenOfOwnerByIndex(deployer, salt)).toString();
        console.log("tokenId:", tokenId);

        const hasBadge = await gameContract.hasBadge(tokenId, await badgeContract.getAddress());
        console.log("hasBadge:", hasBadge);
    }
}

// Error handling for async/await
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
