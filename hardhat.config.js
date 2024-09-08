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
        runs: 2 ** 32 - 1,
      },
      viaIR: true,
    },
  },

  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      forking: {
        enabled: true,
        url: "https://api.wemix.com",
        // url: "https://84532.rpc.thirdweb.com",
        // url: 'https://base.llamarpc.com	',
      },
      chainId: 1111,
      chainId: 84532,
      // chainId: 8453,
      allowUnlimitedContractSize: true,
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },

    wemix: {
      url: "https://api.wemix.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1111,
    },
    wemixtestnet: {
      url: "https://api.test.wemix.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1112,
    },

    base: {
      url: 'https://base.llamarpc.com	',
      chainId: 8453,
      accounts: [process.env.PRIVATE_KEY],
    },
    baseSepolia: {
      url: 'https://84532.rpc.thirdweb.com',
      chainId: 84532,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
