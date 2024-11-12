const path = require('path')

module.exports = {
  devServer: {
    hot: true,
    watchOptions: {
      poll: 1000, // Check for changes every second
      aggregateTimeout: 300, // Delay rebuild after the first change
    },
  },
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
