/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 require("@nomiclabs/hardhat-waffle");
 const { projectId, mnemonic } = require('./secrets.json')

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more


module.exports = {
  defaultNetwork: "rinkeby",
  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${projectId}`,
      accounts: mnemonic
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
