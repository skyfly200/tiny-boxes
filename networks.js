const { projectId, mnemonic } = require('./secrets.json')
const HDWalletProvider = require('@truffle/hdwallet-provider')

module.exports = {
  networks: {
    development: {
      protocol: 'http',
      host: 'localhost',
      port: 7545,
      gas: 6721975,
      gasPrice: 2e10,
      networkId: '*',
    },
    ropsten: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://ropsten.infura.io/v3/${projectId}`,
        ),
      gasPrice: 10e9,
      gasLimit: 1000000,
      networkId: '3',
    },
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://rinkeby.infura.io/v3/${projectId}`,
        ),
      gasPrice: 1e9,
      gasLimit: 750000,
      networkId: '4',
    },
    kovan: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://kovan.infura.io/v3/${projectId}`,
        ),
      gasPrice: 10e9,
      gasLimit: 1000000,
      networkId: '42',
    },
  },
}
