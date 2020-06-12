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
        return {
          network: 'development',
          disabled: false,
        }
      })
  },
}
