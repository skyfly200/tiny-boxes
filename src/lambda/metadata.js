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
      'A modge podge of TinyBoxes, Aranged in patterns ranging from mundane to magnificent.',
    external_url: 'https://tiny-boxes.netlify.app/token/' + id,
    image:
      'https://storage.googleapis.com/opensea-prod.appspot.com/puffs/3.png',
    name: 'Token Number ' + id,
    attributes: [],
  }

  // on internal error return this
  //generateResponse('Server Error', 500)

  return callback(null, generateResponse({ metadata }, 200))
}
