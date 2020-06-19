require('dotenv').config()
import querystring from 'querystring'
const domain = process.env.DOMAIN
const { PINATA_API_KEY, PINATA_API_SECRET, WALLET_PRIVATE_KEY } = process.env

exports.handler = function (event, context, callback) {
  const id = event.queryStringParameters.id

  let metadata = {
    description:
      'Friendly OpenSea Creature that enjoys long swims in the ocean.',
    external_url: 'https://openseacreatures.io/3',
    image:
      'https://storage.googleapis.com/opensea-prod.appspot.com/puffs/3.png',
    name: 'Dave Starbelly',
    attributes: [],
  }

  return {
    statusCode: 200,
    body: `Token: ${id}`,
  }
}
