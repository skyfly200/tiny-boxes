require('dotenv').config()
require('querystring')
const {
  PINATA_API_KEY,
  PINATA_API_SECRET,
  WALLET_PRIVATE_KEY,
  EXTERNAL_URL_BASE,
} = process.env

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
}
