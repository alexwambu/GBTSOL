require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { RPC_URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.21",
  networks: {
    gbtnetwork: {
      url: RPC_URL || "https://gbtnetwork-render.onrender.com",
      chainId: 999,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : []
    }
  }
};
