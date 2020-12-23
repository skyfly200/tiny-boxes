module.exports = {
  base: "/docs/",
  title: 'TinyBoxes Docs',
  description: 'Learn everything from the basic to inner workings of the TinyBoxes DAPP and Smart Contracts.',
  port: 8081,
  dest: "public/docs",
  themeConfig: {
    logo: '../img/logo.png',
    nav: [
      { text: 'DAPP', link: 'https://tinybox.shop/' },
    ],
    sidebar: 'auto',
  },
}