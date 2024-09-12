require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");

require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        // runs: 2 ** 32 - 1,
        runs: 200,
      },
      // viaIR: true,
    },
  },

  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      forking: {
        enabled: true,
        url: 'https://sepolia.base.org',
      },
      chainId: 84532,
      // allowUnlimitedContractSize: true,
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },

    base: {
      // url: 'https://base.llamarpc.com',
      url: 'https://mainnet.base.org',
      chainId: 8453,
      accounts: [process.env.PRIVATE_KEY],
    },
    baseSepolia: {
      url: 'https://sepolia.base.org',
      chainId: 84532,
      accounts: [process.env.PRIVATE_KEY],
    },

    // testnet
    root: {
      url: 'https://public-node.testnet.rsk.co',
      chainId: 31,
      accounts: [process.env.PRIVATE_KEY],
      // https://explorer.testnet.rootstock.io/
    },
    morpy: {
      url: 'https://rpc-quicknode-holesky.morphl2.io',
      chainId: 2810,
      accounts: [process.env.PRIVATE_KEY],
      // https://explorer-holesky.morphl2.io/
    },
  },
};
