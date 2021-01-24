/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-web3");

const { projectId, mnemonic } = require('./secrets.json')

task("balance", "Prints an account's balance")
  .addParam("account", "The account's address")
  .setAction(async taskArgs => {
    const account = web3.utils.toChecksumAddress(taskArgs.account);
    const balance = await web3.eth.getBalance(account);

    console.log(web3.utils.fromWei(balance, "ether"), "ETH");
  });

task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("unpause", "Unpause minting", async () => {
  
});

task("set-countdown", "Set the block countdown", async () => {
  
});

task("mint", "Mints a token", async () => {
  
});

task("promo", "Mints a new promo token", async () => {
  
});

task("redeem", "Redeems a promo token", async () => {
  
});

task("settings", "Update a tokens settings", async () => {
  
});

task("base-uri", "Set the base URI", async () => {
  
});

task("contract-uri", "Set the contract URI", async () => {
  
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more


module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: `https://rinkeby.infura.io/v3/${projectId}`
      },
      allowUnlimitedContractSize: true
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${projectId}`,
      accounts: {
        mnemonic: mnemonic
      }
    }
  },
  solidity: {
    version: "0.6.8",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
};
