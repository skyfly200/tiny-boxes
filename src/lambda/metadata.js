require('dotenv').config()
import querystring from 'querystring'
const domain = process.env.DOMAIN
const { PINATA_API_KEY, PINATA_API_SECRET, WALLET_PRIVATE_KEY } = process.env

exports.handler = function (event, context, callback) {
  const id = event.queryStringParameters.id

  return {
    statusCode: 200,
    body: `Token: ${id}`,
  }
}
