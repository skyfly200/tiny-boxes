// src/index.js
const Web3 = require('web3')
const { setupLoader } = require('@openzeppelin/contract-loader')

async function main() {
  // Set up web3 object, connected to the local development network
  const web3 = new Web3('http://localhost:7545')

  const loader = setupLoader({ provider: web3 }).web3

  // Set up a web3 contract, representing our deployed TinyBoxes instance, using the contract loader
  const address = '0x5c81f679722fA9e60E3B15341f7340d7e6E3AcA6'
  const tinyboxes = loader.fromArtifact('TinyBoxes', address)

  // Call the currentPrice() function of the deployed TinyBoxes contract
  const price = await tinyboxes.methods.currentPrice().call()
  console.log('Mint Price: ', price)

  // Retrieve accounts from the local node, we'll use the first one to send the transaction
  const accounts = await web3.eth.getAccounts()

  // Send a transaction to create a new TinyBox
  await tinyboxes.methods
    .createBox(
      1234,
      [7, 11],
      [10, 10, 2, 2, 100, 400, 50, 55, 0, 750, 1300, 2600, 100],
      [true, true, true],
    )
    .send({ from: accounts[0], value: price, gas: 5000000, gasPrice: 2e10 })

  // lookup total supply
  const supply = await tinyboxes.methods.totalSupply().call()
  console.log('Tokens: ', supply)
  const id = supply - 1
  console.log('ID: ', id)

  // lookup token URI
  const uri = await tinyboxes.methods.tokenURI(id).call()
  console.log('URI: ', supply)

  // lookup latest tokens art
  const art = await tinyboxes.methods.tokenArt(id).call()
  console.log('Art:')
  console.log(art)
}

main()
