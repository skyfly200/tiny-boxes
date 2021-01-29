module.exports = {
  base: "/docs/",
  title: 'TinyBoxes Docs',
  description: 'Learn everything from the basic to inner workings of the TinyBoxes DAPP and Smart Contracts.',
  port: 8081,
  dest: "public/docs",
  themeConfig: {
    smoothScroll: true,
    logo: '../img/logo.png',
    nav: [
      { text: 'DAPP', link: 'https://tinybox.shop/' },
    ],
    repo: 'skyfly200/tiny-boxes',
    docsDir: 'src/docs',
    editLinks: false,
    sidebar: [
      ['/', 'Home'],
      ['/art', 'Art'],
      ['/dapp', 'DApp'],
      ['/metadata', 'Metadata'],
      ['/contract', 'Contract'],
      ['/faq', 'FAQ'],
    ],
    sidebarDepth: 2,
  },
}