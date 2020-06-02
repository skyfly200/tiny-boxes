// src/index.js
const Web3 = require('web3')
const { setupLoader } = require('@openzeppelin/contract-loader')

async function main() {
  // Set up web3 object, connected to the local development network
  const web3 = new Web3('http://localhost:7545')

  // Retrieve accounts from the local node
  const accounts = await web3.eth.getAccounts()
  console.log(accounts)
}

main()
