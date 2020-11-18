import dotenv from 'dotenv'
import Web3 from 'web3'
import Readable from 'stream'
import pinataSDK from '@pinata/sdk'
import axios from 'axios'
import FormData, { Stream } from 'form-data'
import { tinyboxesABI } from '../tinyboxes-contract'
import { resolve } from 'path'
dotenv.config()

const {
  PINATA_API_KEY,
  PINATA_API_SECRET,
  WALLET_PRIVATE_KEY,
  EXTERNAL_URL_BASE,
  WEB3_PROVIDER_ENDPOINT,
  CONTRACT_ADDRESS,
} = process.env

// init web3 provider and load contract
var web3 = new Web3(WEB3_PROVIDER_ENDPOINT)
const tinyboxesContract = new web3.eth.Contract(
  tinyboxesABI,
  CONTRACT_ADDRESS,
)

const generateResponse = (body, statusCode) => {
  return {
    statusCode: statusCode,
    body: JSON.stringify(body),
  }
}

class ReadableString extends Readable {
  sent = false

  constructor(str) {
    super();
  }

  _read() {
    if (!this.sent) {
      this.push(Buffer.from(this.str));
      this.sent = true
    }
    else {
      this.push(null)
    }
  }
}

function lookupMintedBlock(id) {
  return new Promise((resolve, reject) => {
    web3.eth
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
      .on("data", async (log) => {
        console.log('...Minted Block...')
        web3.eth.getBlock(log.blockNumber, (err, response) => {
          if (err) reject(err);
          else resolve(response);
        })
      });
  })
}

exports.handler = async (event, context) => {
  // wrap things with error catching
  try {
    const id = event.queryStringParameters.id

    console.log(CONTRACT_ADDRESS);

    if (event.httpMethod !== 'GET') {
      // Only GET requests allowed
      console.log('Bad method:', event.httpMethod)
      return generateResponse('Bad method:' + event.httpMethod, 405)
    } else if (id === undefined) {
      // complain if id is missing
      console.log('Undefined ID parameter is required')
      return generateResponse('Undefined ID parameter is required', 204)
    }

    // check token exists and get owner
    console.log('Checking token of ID ', id, ' exists')
    const owner = await tinyboxesContract.methods.ownerOf(id).call()
    if (owner === '0x0000000000000000000000000000000000000000') {
      // complain if token is missing
      console.log('Token ' + id + " dosn't exist")
      return generateResponse('Token ' + id + " dosn't exist", 204)
    }

    // concurently lookup token data, palette, art & timestamp
    console.log('Looking Up Token...')
    console.log('...Data...')
    const dataPromise = tinyboxesContract.methods.tokenData(id).call()
    console.log('...Art...')
    const artPromise = tinyboxesContract.methods.tokenArt(id,false).call()
    console.log('...Animation...')
    const animatonPromise = tinyboxesContract.methods.tokenArt(id,true).call()
    console.log('...Mined Block Number...')
    const blockPromise = lookupMintedBlock(id);
    

    // await token data
    console.log("Awaiting requests...");
    let [data, art, animation, block] = ['', '', '', '']
    data = await dataPromise
      .catch((err) => console.error(err))
    art = await artPromise
      .catch((err) => console.error(err))
    animation = await animatonPromise
      .catch((err) => console.error(err))
    block = await blockPromise
      .catch((err) => console.error(err))

    if (data === undefined || art === undefined || animation === undefined) return generateResponse('Server Error', 500)
    
    console.log('Lookup Complete!')

    // convert art stream from SVG to PNG

    // capture MP4 stream of animation

    console.log('Creating Streams from Strings')
    const artStream = new ReadableString(art)
    const animationStream = new ReadableString(animation)

    // load Pinata SDK
    console.log('Connecting to Pinata SDK...')
    const pinata = pinataSDK(PINATA_API_KEY, PINATA_API_SECRET)
    console.log(pinata)

    // const url = `https://api.pinata.cloud/pinning/pinFileToIPFS`
    // const ipfsPromise = axios.post(url, formData, {
    //   maxContentLength: 'Infinity', //this is needed to prevent axios from erroring out with large files
    //   headers: {
    //     'Content-Type': `multipart/form-data; boundary=${formData._boundary}`,
    //     pinata_api_key: PINATA_API_KEY,
    //     pinata_secret_api_key: PINATA_API_SECRET,
    //   },
    // })
    // const ipfsResp = await ipfsPromise

    console.log('Uploading Streams to IPFS')
    const imageHash = (await pinata.pinFileToIPFS(artStream)).IpfsHash
    const animationHash = (await pinata.pinFileToIPFS(animationStream)).IpfsHash
    console.log('IPFS Hashes: ')
    console.log(imageHash)
    console.log(animationHash)

    // build the metadata object from the token data and IPFS hashes
    let metadata = {}
    //   name: 'TinyBox #' + id,
    //   description:
    //     'A scattering of tiny boxes, Aranged in patterns ranging from mundane to magnificent.',
    //   external_url: EXTERNAL_URL_BASE + id,
    //   image: imageHash,
    //   image_data: art,
    //   background_color: '121212',
    //   animation_url: animationHash,
    //   attributes: [
    //     {
    //       display_type: 'number',
    //       trait_type: 'Shapes',
    //       value: parseInt(data.shapes),
    //     },
    //     {
    //       display_type: 'number',
    //       trait_type: 'Color Scheme',
    //       value: parseInt(data.palette[4]),
    //     },
    //     {
    //       display_type: 'number',
    //       trait_type: 'Root Hue',
    //       value: parseInt(data.palette[0]),
    //     },
    //     {
    //       display_type: 'number',
    //       trait_type: 'Saturation',
    //       value: parseInt(data.palette[1]),
    //     },
    //     {
    //       display_type: 'number',
    //       trait_type: 'Lightness',
    //       value: parseInt(data.palette[2])+''+parseInt(data.palette[3]),
    //     },
    //     {
    //       display_type: 'number',
    //       trait_type: 'Shades',
    //       value: parseInt(data.palette[5]),
    //     },
    //     {
    //       display_type: 'number',
    //       trait_type: 'Animation',
    //       value: parseInt(data.animation),
    //     },
    //     {
    //       display_type: 'number',
    //       trait_type: 'Seed',
    //       value: parseInt(data.seed),
    //     },
    //     {
    //       trait_type: 'Hatching',
    //       value: data.hatching,
    //     },
    //     {
    //       trait_type: 'Mirror Level 1',
    //       value: data.switches[0] ? 'On' : 'Off',
    //     },
    //     {
    //       trait_type: 'Mirror Level 2',
    //       value: data.switches[1] ? 'On' : 'Off',
    //     },
    //     {
    //       trait_type: 'Mirror Level 3',
    //       value: data.switches[2] ? 'On' : 'Off',
    //     },
    //     {
    //       trait_type: 'Scale',
    //       value: data.dials[12] + '%',
    //     },
    //     {
    //       display_type: 'date',
    //       trait_type: 'Created',
    //       value: minted.timestamp,
    //     },
    //   ],
    // }

    // // log metadata to console
    // console.log('Metadata of token ' + id)
    // console.log(metadata)

    // // upload metadata JSON object to IPFS
    // console.log('Writing metadata to IPFS')
    // const metadataHash = (await pinata.pinJSONToIPFS(metadata)).IpfsHash
    // console.log(metadataHash)

    // // update token with the metadataHash
    // // can happen after response

    return generateResponse(metadata, 200)
  } catch (err) {
    console.log(err)
    return generateResponse('Server Error', 500)
  }
}
