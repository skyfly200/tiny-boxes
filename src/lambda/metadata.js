require('dotenv').config()
import querystring from 'querystring'
const domain = process.env.DOMAIN
const { PINATA_API_KEY, PINATA_API_SECRET, WALLET_PRIVATE_KEY } = process.env

const generateResponse = (body, statusCode) => {
  return {
    statusCode: statusCode,
    body: JSON.stringify(body),
  }
}

exports.handler = function (event, context, callback) {
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
  let metadata = {
    description:
      'Friendly OpenSea Creature that enjoys long swims in the ocean.',
    external_url: 'https://openseacreatures.io/3',
    image:
      'https://storage.googleapis.com/opensea-prod.appspot.com/puffs/3.png',
    name: 'Dave Starbelly',
    attributes: [],
  }

  //let resp = generateResponse('Server Error', 500)
  let resp = generateResponse({ metadata }, 200)
  return callback(null, resp)
  return {
    statusCode: 200,
    body: `Token: ${id}`,
  }
}
