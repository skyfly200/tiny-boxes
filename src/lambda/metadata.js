import dotenv from 'dotenv'
import Web3 from 'web3'
import Readable from 'stream'
import pinataSDK from '@pinata/sdk'
import axios from 'axios'
import FormData, { Stream } from 'form-data'
import { tinyboxesABI } from '../tinyboxes-contract'
import { resolve } from 'path'
import fs from 'fs'
dotenv.config()

const {
  PINATA_API_KEY,
  PINATA_API_SECRET,
  WALLET_PRIVATE_KEY,
  WEBSITE,
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
  const idHash = '0x' + ((id > 2222) ? BigInt(id) : parseInt(id, 10) ).toString(16).padStart(64, '0');
  console.log("Finding Token with id hash: ", idHash);
  return new Promise((resolve, reject) => {
    web3.eth
      .subscribe('logs', {
        address: CONTRACT_ADDRESS,
        topics: [
          '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
          '0x0000000000000000000000000000000000000000000000000000000000000000',
          null,
          idHash,
        ],
      })
      .on("data", async (log) => {
        console.log('...Minted Block...')
        web3.eth.getBlock(log.blockNumber, (err, response) => {
          if (err) reject(err);
          else resolve(response);
        })
      })
      .on("error", function(log) {
        console.error(log);
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
    console.log('Looking Up Token Data...')
    const dataPromise = tinyboxesContract.methods.tokenData(id).call()
    const artPromise = tinyboxesContract.methods.tokenArt(id).call()
    //const blockPromise = lookupMintedBlock(id);
    

    // await token data
    console.log("Awaiting requests...");
    let [data, art, block] = ['', '', '']
    data = await dataPromise
      .catch((err) => console.error(err))
    if (data.animation == 14)
      art = await tinyboxesContract.methods.tokenArt(id,0,10,0,'').call()
        .catch((err) => console.error(err))
    else art = await artPromise
      .catch((err) => console.error(err))
    if (data === undefined || art === undefined) return generateResponse('Server Error', 500)
    
    console.log('Lookup Complete!')

    // convert static art from SVG to PNG

    // capture MP4 video of SVG animation

    // console.log('Creating ReadableStrings')
    // // needs to be converted to a file without writing to fs
    // const artStream = new File(art, ("TinyBox#"+id+"-art.svg"))
    // //Blob(art, {type : 'image/svg+xml'})
    // const animationStream = new ReadableString(animation)

    // load Pinata SDK
    // console.log('Connecting to Pinata SDK...')
    // const pinata = pinataSDK(PINATA_API_KEY, PINATA_API_SECRET)

    // const imageHash = (await pinata.pinFileToIPFS(artStream)).IpfsHash
    // const animationHash = (await pinata.pinFileToIPFS(animationStream)).IpfsHash
    // console.log('IPFS Hashes: ')
    // console.log(imageHash)
    // console.log(animationHash)

    const leDefaultArt = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2440 2440"><g id="Layer_2" data-name="Layer 2"><g id="Layer_1-2" data-name="Layer 1"><rect x="20" y="20" width="2400" height="2400" style="fill:#231f20;stroke:#231f20;stroke-miterlimit:10"/><path d="M196.11,368.23h34.8v240.4h115.2v29.2h-150Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M543.87,368.23v269.6h-34.8V368.23Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M956,519.43c-2-37.6-4.4-82.8-4-116.4h-1.2c-9.2,31.6-20.4,65.2-34,102.4l-47.6,130.8h-26.4l-43.6-128.4c-12.8-38-23.6-72.8-31.2-104.8h-.8c-.8,33.6-2.8,78.8-5.2,119.2l-7.2,115.6h-33.2l18.8-269.6h44.4l46,130.4c11.2,33.2,20.4,62.8,27.2,90.8h1.2c6.8-27.2,16.4-56.8,28.4-90.8l48-130.4H980l16.8,269.6h-34Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1209.4,368.23v269.6h-34.8V368.23Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1445.56,397.83h-82v-29.6h199.59v29.6h-82.4v240h-35.2Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1856.93,511.43h-104.8v97.2h116.8v29.2h-151.6V368.23h145.6v29.2h-110.8v85.2h104.8Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M2038.29,371.83a498.46,498.46,0,0,1,74-5.6c50,0,85.6,11.6,109.2,33.6,24,22,38,53.2,38,96.8,0,44-13.6,80-38.8,104.8-25.2,25.2-66.8,38.8-119.2,38.8a561.7,561.7,0,0,1-63.2-3.2Zm34.8,238.4c8.8,1.6,21.6,2,35.2,2,74.4,0,114.8-41.6,114.8-114.4.4-63.6-35.6-104-109.2-104-18,0-31.6,1.6-40.8,3.6Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M335.71,991.43H230.91v97.2h116.8v29.2H196.11V848.23h145.6v29.2H230.91v85.2h104.8Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M512.34,851.83a498.46,498.46,0,0,1,74-5.6c50,0,85.6,11.6,109.2,33.6,24,22,38,53.2,38,96.8,0,44-13.6,80-38.8,104.8-25.2,25.2-66.8,38.8-119.2,38.8a561.7,561.7,0,0,1-63.2-3.2Zm34.8,238.4c8.8,1.6,21.6,2,35.2,2,74.4,0,114.8-41.6,114.8-114.4.4-63.6-35.6-104-109.2-104-18,0-31.6,1.6-40.8,3.6Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M933,848.23v269.6h-34.8V848.23Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1164.4,877.83h-82v-29.6H1282v29.6h-82.4v240h-35.2Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1466.23,848.23v269.6h-34.8V848.23Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1876.86,980.23c0,92.8-56.4,142-125.2,142-71.2,0-121.2-55.2-121.2-136.8,0-85.6,53.2-141.6,125.2-141.6C1829.26,843.83,1876.86,900.23,1876.86,980.23Zm-209.2,4.4c0,57.6,31.2,109.2,86,109.2,55.2,0,86.4-50.8,86.4-112,0-53.6-28-109.6-86-109.6C1696.46,872.23,1667.66,925.43,1667.66,984.63Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M2041.49,1117.83V848.23h38l86.4,136.4c20,31.6,35.6,60,48.4,87.6l.8-.4c-3.2-36-4-68.8-4-110.8V848.23h32.8v269.6h-35.2L2123.09,981c-18.8-30-36.8-60.8-50.4-90l-1.2.4c2,34,2.8,66.4,2.8,111.2v115.2Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M247.31,1357.83h-82v-29.6h199.6v29.6h-82.4v240h-35.2Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M534.74,1328.23v269.6h-34.8v-269.6Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M700.57,1597.83v-269.6h38l86.4,136.4c20,31.6,35.6,60,48.4,87.6l.8-.4c-3.2-36-4-68.8-4-110.8v-112.8H903v269.6h-35.2L782.17,1461c-18.8-30-36.8-60.8-50.4-90l-1.2.4c2,34,2.8,66.4,2.8,111.2v115.2Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1126,1597.83v-114.4l-85.2-155.2h39.6l38,74.4c10.4,20.4,18.4,36.8,26.8,55.6h.8c7.6-17.6,16.8-35.2,27.2-55.6l38.8-74.4h39.6L1161.2,1483v114.8Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1384.63,1331.83c15.2-3.2,39.2-5.6,63.6-5.6,34.8,0,57.2,6,74,19.6,14,10.4,22.4,26.4,22.4,47.6,0,26-17.2,48.8-45.6,59.2v.8c25.6,6.4,55.6,27.6,55.6,67.6,0,23.2-9.2,40.8-22.8,54-18.8,17.2-49.2,25.2-93.2,25.2a406.83,406.83,0,0,1-54-3.2Zm34.8,110.4H1451c36.8,0,58.4-19.2,58.4-45.2,0-31.6-24-44-59.2-44-16,0-25.2,1.2-30.8,2.4Zm0,129.2c6.8,1.2,16.8,1.6,29.2,1.6,36,0,69.2-13.2,69.2-52.4,0-36.8-31.6-52-69.6-52h-28.8Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1936.85,1460.23c0,92.8-56.4,142-125.2,142-71.19,0-121.19-55.2-121.19-136.8,0-85.6,53.19-141.6,125.19-141.6C1889.25,1323.83,1936.85,1380.23,1936.85,1460.23Zm-209.19,4.4c0,57.6,31.19,109.2,86,109.2,55.2,0,86.4-50.8,86.4-112,0-53.6-28-109.6-86-109.6C1756.45,1352.23,1727.66,1405.43,1727.66,1464.63Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M2223.88,1597.83l-34.4-59.6c-14-22.8-22.8-37.6-31.19-53.2h-.8c-7.61,15.6-15.2,30-29.2,53.6l-32.4,59.2h-40l82.4-136.4-79.2-133.2h40.4l35.59,63.2c10,17.6,17.61,31.2,24.8,45.6h1.2c7.6-16,14.4-28.4,24.4-45.6l36.8-63.2h40l-82,131.2,84,138.4Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M247.31,1837.83h-82v-29.6h199.6v29.6h-82.4v240h-35.2Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M856.56,1940.23c0,92.8-56.4,142-125.2,142-71.2,0-121.2-55.2-121.2-136.8,0-85.6,53.2-141.6,125.2-141.6C809,1803.83,856.56,1860.23,856.56,1940.23Zm-209.2,4.4c0,57.6,31.2,109.2,86,109.2,55.2,0,86.4-50.8,86.4-112,0-53.6-28-109.6-86-109.6C676.16,1832.23,647.36,1885.43,647.36,1944.63Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1143.8,1808.23h34.8v130h1.2c7.2-10.4,14.4-20,21.2-28.8l82.4-101.2h43.2l-97.6,114.4,105.2,155.2H1293l-88.8-132.4-25.6,29.6v102.8h-34.8Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M1742.25,1951.43h-104.8v97.2h116.8v29.2h-151.6v-269.6h145.6v29.2h-110.8v85.2h104.8Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><path d="M2041.49,2077.83v-269.6h38l86.4,136.4c20,31.6,35.6,60,48.4,87.6l.8-.4c-3.2-36-4-68.8-4-110.8v-112.8h32.8v269.6h-35.2l-85.6-136.8c-18.8-30-36.8-60.8-50.4-90l-1.2.4c2,34,2.8,66.4,2.8,111.2v115.2Z" style="fill:#fff;stroke:#231f20;stroke-miterlimit:10"/><rect x="20" y="20" width="2400" height="2400" style="fill:none;stroke:#fff;stroke-miterlimit:10;stroke-width:40px"/><rect x="65.86" y="72.71" width="2301.43" height="2301.43" style="fill:none;stroke:#fff;stroke-miterlimit:10;stroke-width:12px"/><rect x="1324.78" y="127.71" width="110" height="110" style="fill:#414042"/><rect x="1504.19" y="147.34" width="70.76" height="70.76" transform="translate(321.73 1142.15) rotate(-45)" style="fill:#414042"/><rect x="1184.62" y="147.34" width="70.76" height="70.76" transform="translate(2211.87 -550.76) rotate(135)" style="fill:#414042"/><rect x="685.65" y="127.71" width="110" height="110" style="fill:#414042"/><rect x="865.06" y="147.34" width="70.76" height="70.76" transform="translate(134.53 690.22) rotate(-45)" style="fill:#414042"/><rect x="545.49" y="147.34" width="70.76" height="70.76" transform="translate(1120.8 -98.82) rotate(135)" style="fill:#414042"/><rect x="1005.22" y="127.71" width="110" height="110" style="fill:#414042"/><rect x="1963.91" y="127.71" width="110" height="110" style="fill:#414042"/><rect x="2143.32" y="147.34" width="70.76" height="70.76" transform="translate(508.93 1594.09) rotate(-45)" style="fill:#414042"/><rect x="1823.75" y="147.34" width="70.76" height="70.76" transform="translate(3302.93 -1002.69) rotate(135)" style="fill:#414042"/><rect x="1644.35" y="127.71" width="110" height="110" style="fill:#414042"/><rect x="366.09" y="127.71" width="110" height="110" style="fill:#414042"/><rect x="225.92" y="147.34" width="70.76" height="70.76" transform="translate(575.27 127.14) rotate(135)" style="fill:#414042"/><rect x="1321.35" y="2203.23" width="110" height="110" style="fill:#414042"/><rect x="1500.76" y="2222.85" width="70.76" height="70.76" transform="translate(-1146.89 1747.63) rotate(-45)" style="fill:#414042"/><rect x="1181.19" y="2222.85" width="70.76" height="70.76" transform="translate(3673.63 2994.79) rotate(135)" style="fill:#414042"/><rect x="682.22" y="2203.23" width="110" height="110" style="fill:#414042"/><rect x="861.63" y="2222.85" width="70.76" height="70.76" transform="translate(-1334.08 1295.7) rotate(-45)" style="fill:#414042"/><rect x="542.06" y="2222.85" width="70.76" height="70.76" transform="translate(2582.56 3446.73) rotate(135)" style="fill:#414042"/><rect x="1001.79" y="2203.23" width="110" height="110" style="fill:#414042"/><rect x="1960.48" y="2203.23" width="110" height="110" style="fill:#414042"/><rect x="2139.89" y="2222.85" width="70.76" height="70.76" transform="translate(-959.69 2199.57) rotate(-45)" style="fill:#414042"/><rect x="1820.32" y="2222.85" width="70.76" height="70.76" transform="translate(4764.69 2542.86) rotate(135)" style="fill:#414042"/><rect x="1640.92" y="2203.23" width="110" height="110" style="fill:#414042"/><rect x="362.66" y="2203.23" width="110" height="110" style="fill:#414042"/><rect x="222.5" y="2222.85" width="70.76" height="70.76" transform="translate(2037.03 3672.69) rotate(135)" style="fill:#414042"/></g></g></svg>';

    // build the metadata object from the token data and IPFS hashes
    console.log("Building Metadata");
    const animationTitles = [
      "Snap Spin 90",
      "Snap Spin 180",
      "Snap Spin 270",
      "Snap Spin Tri",
      "Snap Spin Quad",
      "Snap Spin Tetra",
      "Spin",
      "Slow Mo",
      "Clockwork",
      "Spread",
      "Unfurl",
      "Jitter",
      "Jiggle",
      "Jolt",
      "Grow n Shrink",
      "Squash n Stretch",
      "Round",
      "Glide",
      "Wave",
      "Fade",
      "Skew X",
      "Skew Y",
      "Stretch",
      "Jello"
    ];
    const schemeTitles = [
      "Analogous",
      "Triadic",
      "Complimentary",
      "Tetradic",
      "Analogous and Complimentary",
      "Split Complimentary",
      "Complimentary and Analogous",
      "Series",
      "Square",
      "Mono",
      "Random"
    ];
    const isLE = BigInt(id) > 2222;
    const max256Int = 115792089237316195423570985008687907853269984665640564039457584007913129639936n;
    const description = (
      (isLE ? "Limited Edition " : "") +
      "TinyBox " + 
      (isLE ?
        (max256Int - BigInt(id)).toString(10) + " of 100 Limited Editions Max" :
        (id % 202) + " of 202 in Phase " + (parseInt(data.scheme) + 1).toString(10)) +
      " " +
      "TinyBoxes is to Autoglyphs as Avastars is to CryptoPunks. " +
      "TinyBoxes are animated patterns of shapes and colors generated and rendered 100% on-chain. Innovative features of TinyBoxes include dynamic rendering settings, 24 animations, and 11 exclusive color schemes released in phases. \n" +
      "Our contract has been designed as efficiently as possible, with a minting fee of just 260k gas. TinyBoxes gives back to its community; giving back 50% of gas spent as referral rewards, prizes and giveaways."
    );
    const metadata = {
      platform: "TinyBoxes",
      name: isLE ? 'LE TinyBox #-' + (max256Int - BigInt(id)).toString(10) : 'TinyBox #' + id,
      tokenID: id,
      description: description,
      website: WEBSITE,
      external_url: EXTERNAL_URL_BASE + id,
      image_data: isLE && parseInt(data.shapes) === 0 ? leDefaultArt : art,
      background_color: '121212',
      artist: "NonFungibleTeam",
      license: "NFT License",
      royaltyInfo:{
        artistAddress: CONTRACT_ADDRESS,
        royaltyFeeByID: 5
      },
      attributes: [
        {
          trait_type: 'Shapes',
          value: parseInt(data.shapes),
          max_value: 30
        },
        {
          trait_type: 'Hatching',
          value: parseInt(data.hatching),
          max_value: 30
        },
        {
          trait_type: 'Min Width',
          value: parseInt(data.size[0]),
          max_value: 255
        },
        {
          trait_type: 'Max Width',
          value: parseInt(data.size[1]),
          max_value: 255
        },
        {
          trait_type: 'Min Height',
          value: parseInt(data.size[2]),
          max_value: 255
        },
        {
          trait_type: 'Max Height',
          value: parseInt(data.size[3]),
          max_value: 255
        },
        {
          trait_type: 'Spread',
          value: data.spacing[0] + "%",
          max_value: 100
        },
        {
          trait_type: 'Rows',
          value: (data.spacing[1] % 16) + 1,
          max_value: 16
        },
        {
          trait_type: 'Columns',
          value: Math.floor(data.spacing[1] / 16) + 1,
          max_value: 16
        },
        {
          trait_type: 'Hue',
          value: parseInt(data.color[0]),
          max_value: 360
        },
        {
          trait_type: 'Saturation',
          value: parseInt(data.color[1]),
          max_value: 100
        },
        {
          trait_type: 'Lightness',
          value: parseInt(data.color[2]),
          max_value: 100
        },
        {
          trait_type: 'Contrast',
          value: data.contrast + '%',
          max_value: 100
        },
        {
          trait_type: 'Shades',
          value: data.shades,
          max_value: 7
        },
        {
          trait_type: 'Scheme',
          value:  parseInt(data.color[1]) === 0 ? "Grayscale" : schemeTitles[data.scheme],
        },
        {
          display_type: "number",
          trait_type: 'Phase',
          value: isLE ? -1 : parseInt(data.scheme) + 1,
          max_value: 11
        },
        {
          trait_type: 'Animation',
          value: animationTitles[data.animation],
        },
        {
          trait_type: 'Mirroring',
          value: data.mirroring % 4 + "," + Math.floor(data.mirroring / 4) % 4 + "," + Math.floor(data.mirroring / 16) % 4 
        },
        {
          display_type: "date",
          trait_type: 'Rendered',
          value: Date.now(),
        },
      ],
    }

    // log metadata to console
    console.log('Metadata of token ' + id)
    console.log(metadata)

    // upload metadata JSON object to IPFS
    // console.log('Writing metadata to IPFS')
    // const options = {
    //   pinataMetadata: {
    //       name: "TinyBox #"+id+" Metadata"
    //   }
    // };

    // const metadataHash = (await pinata.pinJSONToIPFS(metadata, options)).IpfsHash
    // console.log(metadataHash)

    // update token with the metadataHash
    // can happen after response

    return generateResponse(metadata, 200)
  } catch (err) {
    console.log(err)
    return generateResponse('Server Error', 500)
  }
}
