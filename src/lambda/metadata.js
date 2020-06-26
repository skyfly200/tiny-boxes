import dotenv from 'dotenv'
import querystring from 'querystring'
import fs from 'fs'
import { Readable } from 'stream'
import streamifier from 'streamifier'
import Web3 from 'web3'
import pinataSDK from '@pinata/sdk'
import axios from 'axios'
import FormData from 'form-data'
import { tinyboxesABI } from '../tinyboxes-contract'
//import ffmpegExec from '@ffmpeg-installer/ffmpeg'
//import ffmpeg from 'fluent-ffmpeg'

//console.log('FFMPEG Path: ')
//console.log(ffmpegExec.path)
//ffmpeg.setFfmpegPath(ffmpegExec.path)
dotenv.config()

const {
  PINATA_API_KEY,
  PINATA_API_SECRET,
  WALLET_PRIVATE_KEY,
  EXTERNAL_URL_BASE,
  WEB3_PROVIDER_ENDPOINT,
  CONTRACT_ADDRESS,
} = process.env

const generateResponse = (body, statusCode) => {
  return {
    statusCode: statusCode,
    body: JSON.stringify(body),
  }
}

exports.handler = async (event, context) => {
  // wrap things with error catching
  try {
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

    // concurently lookup token data and art
    const dataPromise = tinyboxesContract.methods.tokenData(id).call()
    const artPromise = tinyboxesContract.methods.tokenArt(id).call()

    // await token data
    const data = await dataPromise
    const art = await artPromise

    // generate readable stream of the SVG art markup
    const artStream = streamifier.createReadStream(new Buffer([art]))

    // convert art stream from SVG to PNG

    // build MP4 stream of animation from frames

    // load Pinata SDK
    const pinata = pinataSDK(PINATA_API_KEY, PINATA_API_SECRET)

    // upload image and video to IPFS
    console.log('Uploading art to IPFS...')

    // direct appreach
    const url = `https://api.pinata.cloud/pinning/pinFileToIPFS`

    // build form data with any valid readStream source
    let formData = new FormData()
    formData.append('file', artStream)

    const ipfsResp = await axios.post(url, formData, {
      maxContentLength: 'Infinity', //this is needed to prevent axios from erroring out with large files
      headers: {
        'Content-Type': `multipart/form-data; boundary=${formData._boundary}`,
        pinata_api_key: PINATA_API_KEY,
        pinata_secret_api_key: PINATA_API_SECRET,
      },
    })

    //const imageHash = (await pinata.pinFileToIPFS(artStream)).IpfsHash
    const imageHash = ''
    const animationHash = ''
    //const animationHash = await pinata.pinFileToIPFS(mp4Stream)
    // console.log('IPFS Hash: ')
    // console.log(imageHash)

    // lookup token minted timestamp
    let minted = 1546360800
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

    // build the metadata object from the token data and IPFS hashes
    let metadata = {
      name: 'Token ' + id,
      description:
        'A scattering of tiny boxes, Aranged in patterns ranging from mundane to magnificent.',
      external_url: EXTERNAL_URL_BASE + id,
      image: imageHash,
      image_data: art,
      background_color: '121212',
      animation_url: animationHash,
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
          trait_type: 'Scale',
          value: data.dials[12] + '%',
        },
        {
          display_type: 'date',
          trait_type: 'Created',
          value: minted,
        },
      ],
    }

    // log metadata to console
    console.log('Metadata of token ' + id)
    //console.log(metadata)

    // upload metadata JSON object to IPFS
    console.log('Writing metadata to IPFS')
    const metadataHash = (await pinata.pinJSONToIPFS(metadata)).IpfsHash
    console.log(metadataHash)

    return generateResponse(metadata, 200)
  } catch (err) {
    console.log(err)
    return generateResponse('Server Error', 500)
  }
}
