const path = require('path')

module.exports = {
  parallel: true, // Leverages multi-core CPUs for faster builds
  devServer: {
    hot: true,
    watchOptions: {
      poll: 1000, // Check for changes every second
      aggregateTimeout: 300, // Delay rebuild after the first change
    },
  },
  configureWebpack: {
    cache: {
      type: 'filesystem', // Caches webpack builds on the file system
    },
    resolve: {
      alias: {
        Contracts: path.resolve(__dirname, 'contracts/'),
      },
    },
  },
  transpileDependencies: ['vuetify'],
  chainWebpack: (config) => {
    // Enable cache for Babel
    config.module
      .rule('js')
      .use('babel-loader')
      .tap((options) => {
        options.cacheDirectory = true;
        return options;
      });
    // Configure Solidity loader for .sol files
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
