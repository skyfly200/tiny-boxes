module.exports = {
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
        options.network = 'development',;
        options.disabled = false;
        return options;
      })
  },
}
