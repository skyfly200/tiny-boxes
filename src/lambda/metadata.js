require('dotenv').config()
import querystring from 'querystring'
import Web3 from 'web3'

const {
  PINATA_API_KEY,
  PINATA_API_SECRET,
  WALLET_PRIVATE_KEY,
  EXTERNAL_URL_BASE,
  WEB3_PROVIDER_ENDPOINT,
  CONTRACT_ADDRESS,
} = process.env

import { tinyboxesABI } from '../tinyboxes-contract'

const generateResponse = (body, statusCode) => {
  return {
    statusCode: statusCode,
    body: JSON.stringify(body),
  }
}

exports.handler = async (event, context) => {
  const id = event.queryStringParameters.id

  if (event.httpMethod !== 'GET') {
    // Only GET requests allowed
    console.log('Bad method:', event.httpMethod)
    return generateResponse('Bad method:' + event.httpMethod, 405)
  } else if (id === undefined) {
    // complain if id is missing
    console.log('Undefined ID parameter is required')
    return generateResponse('Undefined ID parameter is required', 204)
  }
  console.log('Loading Web3')

  // init web3 provider
  var web3 = new Web3(WEB3_PROVIDER_ENDPOINT)
  const tinyboxesContract = new web3.eth.Contract(
    tinyboxesABI,
    CONTRACT_ADDRESS,
  )

  // check token exists and get owner
  const owner = await tinyboxesContract.methods.ownerOf(id).call()
  if (owner === '0x0000000000000000000000000000000000000000') {
    // complain if token is missing
    console.log('Token ' + id + " dosn't exist")
    return generateResponse('Token ' + id + " dosn't exist", 204)
  }

  // lookup token data and art
  const data = await tinyboxesContract.methods.tokenData(id).call()
  const art = await tinyboxesContract.methods.tokenArt(id).call()

  // lookup token minted timestamp
  const minted = 1546360800
  await web3.eth
    .subscribe('logs', {
      address: CONTRACT_ADDRESS,
      fromBlock: 0,
      topics: [
        '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
        '0x0000000000000000000000000000000000000000000000000000000000000000',
        null,
        '0x' + id.toString(16).padStart(64, '0'),
      ],
    })
    .on('data', async (result) => {
      const block = await web3.eth.getBlock(result.blockNumber)
      minted = block.timestamp
    })

  // build the metadata object from the token data
  const image = art // upload to IPFS and use hash
  const animationHash = ''
  let metadata = {
    description:
      'A scattering of tiny boxes, Aranged in patterns ranging from mundane to magnificent.',
    external_url: EXTERNAL_URL_BASE + id,
    image_data: image,
    name: 'Token ' + id,
    attributes: [
      {
        display_type: 'number',
        trait_type: 'Colors',
        value: parseInt(data.counts[0]),
      },
      {
        display_type: 'number',
        trait_type: 'Shapes',
        value: parseInt(data.counts[1]),
      },
      {
        display_type: 'number',
        trait_type: 'Animation',
        value: parseInt(data.animation),
      },
      {
        display_type: 'number',
        trait_type: 'Seed',
        value: parseInt(data.seed),
      },
      {
        trait_type: 'Hatching',
        value: data.dials[8],
      },
      {
        trait_type: 'Mirror Level 1',
        value: data.switches[0] ? 'On' : 'Off',
      },
      {
        trait_type: 'Mirror Level 2',
        value: data.switches[1] ? 'On' : 'Off',
      },
      {
        trait_type: 'Mirror Level 3',
        value: data.switches[2] ? 'On' : 'Off',
      },
      {
        display_type: 'date',
        trait_type: 'Created',
        value: minted,
      },
    ],
    background_color: '121212',
    animation_url: animationHash,
  }

  // log metadata to console
  console.log('Metadata of token ' + id)
  console.log(metadata)

  // load Pinata SDK
  const pinataSDK = require('@pinata/sdk')
  const pinata = pinataSDK(PINATA_API_KEY, PINATA_API_SECRET)

  // test Pinata SDK auth
  console.log(await pinata.testAuthentication())

  // on internal error return this
  //generateResponse('Server Error', 500)

  return generateResponse(metadata, 200)
}
