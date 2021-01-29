const path = require('path')

module.exports = {
  configureWebpack: {
    resolve: {
      alias: {
        Contracts: path.resolve(__dirname, 'contracts/'),
      },
    },
  },
  transpileDependencies: ['vuetify'],
  chainWebpack: (config) => {
    config.module
      .rule('sol')
      .test(/\.sol$/)
      .use('json-loader')
      .loader('json-loader')
      .end()
      .use('@openzeppelin/solidity-loader')
      .loader('@openzeppelin/solidity-loader')
      .tap((options) => {
        return {
          network: 'development',
          disabled: false,
        }
      })
  },
}
