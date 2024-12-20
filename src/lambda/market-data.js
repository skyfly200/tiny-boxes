import dotenv from 'dotenv'
import fetch from "node-fetch"
dotenv.config()

const {
    ALCHEMY_API_KEY,
    CONTRACT_ADDRESS,
} = process.env

exports.handler = async (event, context) => {
    console.log(event)
    // wrap things with error catching
    try {
        const options = {method: 'GET', headers: {accept: 'application/json'}};

        const urlFloor = 
            'https://eth-mainnet.g.alchemy.com/nft/v3/' +
            ALCHEMY_API_KEY +
            '/getFloorPrice?contractAddress=' +
            CONTRACT_ADDRESS
            
        const resFloor = await fetch(urlFloor, options)
        const floor = await resFloor.json();

        console.log(floor);
        
        return {
            statusCode: 200,
            body: JSON.stringify(floor),
        }
        
    } catch (err) {
        console.log(err)
        return {
            statusCode: 500,
            body: JSON.stringify('Server Error'),
        }
    }
}