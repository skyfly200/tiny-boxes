import dotenv from 'dotenv'
dotenv.config()

const {
    ALCHEMY_API_KEY,
    CONTRACT_ADDRESS,
} = process.env

exports.handler = async (event, context) => {
    // wrap things with error catching
    try {
        const options = {method: 'GET', headers: {accept: 'application/json'}};

        const urlFloor = 'https://eth-mainnet.g.alchemy.com/nft/v3/' + ALCHEMY_API_KEY + '/getFloorPrice?contractAddress=' + CONTRACT_ADDRESS
        resFloor = await fetch(urlFloor, options)

        const urlSales = 'https://eth-mainnet.g.alchemy.com/nft/v3/' + ALCHEMY_API_KEY + '/getNFTSales?contractAddress=' + CONTRACT_ADDRESS
        resSales = await fetch(urlSales, options)

        return generateResponse({floor: resFloor.json(), sales: resSales.json()}, 200)
        
    } catch (err) {
      console.log(err)
      return generateResponse('Server Error', 500)
    }
}