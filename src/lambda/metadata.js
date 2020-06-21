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

var web3 = new Web3(WEB3_PROVIDER_ENDPOINT)
const tinyboxesContract = new web3.eth.Contract(tinyboxesABI, CONTRACT_ADDRESS)

const generateResponse = (body, statusCode) => {
  return {
    statusCode: statusCode,
    body: JSON.stringify(body),
  }
}

exports.handler = async function (event, context, callback) {
  const id = event.queryStringParameters.id

  if (event.httpMethod !== 'GET') {
    // Only GET requests allowed
    console.log('Bad method:', event.httpMethod)
    return callback(null, generateResponse('Method Not Allowed', 405))
  } else if (id === undefined) {
    // complain if id is missing
    console.log('Undefined ID parameter is required')
    return callback(null, generateResponse('Invalid Request', 204))
  }

  // build the metadata object from the token data
  const image = ''
  const animationHash = ''
  let metadata = {
    description:
      'A scattering of tiny boxes, Aranged in patterns ranging from mundane to magnificent.',
    external_url: EXTERNAL_URL_BASE + id,
    image: image,
    name: 'Token ' + id,
    attributes: [],
    background_color: '121212',
    animation_url: animationHash,
  }

  // on internal error return this
  //generateResponse('Server Error', 500)

  return callback(null, generateResponse({ metadata }, 200))

  // lookup token data
  const data = await tinyboxesContract.methods.tokenSeed(id).call()
}
