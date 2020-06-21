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

  // check token exists
  if (id === undefined) {
    // complain if id is missing
    console.log('Token ' + id + " dosn't exist")
    return generateResponse('Token ' + id + " dosn't exist", 204)
  }

  // lookup token data and art
  const data = await tinyboxesContract.methods.tokenData(id).call()
  const art = await tinyboxesContract.methods.tokenArt(id).call()

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
        trait_type: 'Animation',
        value: data.animation,
      },
      {
        display_type: 'number',
        trait_type: 'Seed',
        value: data.seed,
      },
      {
        trait_type: 'Colors',
        value: data.counts[0],
      },
      {
        trait_type: 'Shapes',
        value: data.counts[1],
      },
      {
        trait_type: 'Hatching',
        value: data.dials[8],
      },
    ],
    background_color: '121212',
    animation_url: animationHash,
  }

  // log metadata to console
  console.log('Metadata of token ' + id)
  console.log(metadata)

  // on internal error return this
  //generateResponse('Server Error', 500)

  return generateResponse(metadata, 200)
}
