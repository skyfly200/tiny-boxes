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
    rinkeby: {
      protocol: 'https',
      host: 'rinkeby.infura.io/v3/517826b8f74845aa8b16945c61780ca1',
      gas: 6721975,
      gasPrice: 5e9,
      networkId: '*',
    },
  },
}
