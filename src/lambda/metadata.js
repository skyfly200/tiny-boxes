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
    return generateResponse('Method Not Allowed', 405)
  } else if (id === undefined) {
    // complain if id is missing
    console.log('Undefined ID parameter is required')
    return generateResponse('Invalid Request', 204)
  }
  console.log('Loading Web3')

  // init web3 provider
  var web3 = new Web3(WEB3_PROVIDER_ENDPOINT)
  const tinyboxesContract = new web3.eth.Contract(
    tinyboxesABI,
    CONTRACT_ADDRESS,
  )

  console.log('Loaded Web3, loading token data')

  // lookup token data and art
  const data = await tinyboxesContract.methods.tokenData(id).call()
  const art = await tinyboxesContract.methods.tokenArt(id).call()

  console.log('Loaded token data')
  console.log(data)
  console.log(art)

  // build the metadata object from the token data
  const image = ''
  const animationHash = ''
  let metadata = {
    description:
      'A scattering of tiny boxes, Aranged in patterns ranging from mundane to magnificent.',
    external_url: EXTERNAL_URL_BASE + id,
    image_data: art,
    name: 'Token ' + id,
    attributes: [],
    background_color: '121212',
    animation_url: animationHash,
  }

  console.log(metadata)

  // on internal error return this
  //generateResponse('Server Error', 500)

  return generateResponse({ metadata }, 200)
}
