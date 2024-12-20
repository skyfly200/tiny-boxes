import dotenv from 'dotenv'
import Web3 from 'web3'
// import { Octokit } from '@octokit/rest'
const { Octokit } = require('@octokit/rest')
import { tinyboxesABI } from '../tinyboxes-contract'
import fetch from "node-fetch"

dotenv.config()

const {
  NODE_APP_WEB3_PROVIDER_ENDPOINT,
  CONTRACT_ADDRESS,
  GITHUB_TOKEN,
  REPO_OWNER,
  REPO_NAME,
  BRANCH_NAME,
} = process.env

const infuraEndpoint = NODE_APP_WEB3_PROVIDER_ENDPOINT;

// console.log(NODE_APP_WEB3_PROVIDER_ENDPOINT)

if (!infuraEndpoint) console.error('Infura endpoint URL is not set in the environment variable NODE_APP_WEB3_PROVIDER_ENDPOINT.');

// ABI of the TinyBox contract (provided)
const contractABI = [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "rand",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "_renderer",
          "type": "address"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "approved",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "Approval",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "operator",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "bool",
          "name": "approved",
          "type": "bool"
        }
      ],
      "name": "ApprovalForAll",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "by",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        }
      ],
      "name": "RedeemedLE",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "previousAdminRole",
          "type": "bytes32"
        },
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "newAdminRole",
          "type": "bytes32"
        }
      ],
      "name": "RoleAdminChanged",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "account",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "sender",
          "type": "address"
        }
      ],
      "name": "RoleGranted",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "account",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "sender",
          "type": "address"
        }
      ],
      "name": "RoleRevoked",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint8[3]",
          "name": "settings",
          "type": "uint8[3]"
        }
      ],
      "name": "SettingsChanged",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "Transfer",
      "type": "event"
    },
    {
      "inputs": [],
      "name": "ADMIN_ROLE",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "",
          "type": "bytes32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "ANIMATION_COUNT",
      "outputs": [
        {
          "internalType": "uint8",
          "name": "",
          "type": "uint8"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "DEFAULT_ADMIN_ROLE",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "",
          "type": "bytes32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "SCHEME_COUNT",
      "outputs": [
        {
          "internalType": "uint8",
          "name": "",
          "type": "uint8"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "TOKEN_LIMIT",
      "outputs": [
        {
          "internalType": "uint16",
          "name": "",
          "type": "uint16"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "_tokenIds",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "_value",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "_tokenPromoIds",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "_value",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "approve",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "avgBlockTime",
      "outputs": [
        {
          "internalType": "uint8",
          "name": "",
          "type": "uint8"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        }
      ],
      "name": "balanceOf",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "baseURI",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "blockStart",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        },
        {
          "internalType": "uint8[3]",
          "name": "settings",
          "type": "uint8[3]"
        }
      ],
      "name": "changeSettings",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "contractURI",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "_seed",
          "type": "string"
        },
        {
          "internalType": "uint8[2]",
          "name": "shapes",
          "type": "uint8[2]"
        },
        {
          "internalType": "uint16[3]",
          "name": "color",
          "type": "uint16[3]"
        },
        {
          "internalType": "uint8[4]",
          "name": "size",
          "type": "uint8[4]"
        },
        {
          "internalType": "uint8[2]",
          "name": "spacing",
          "type": "uint8[2]"
        },
        {
          "internalType": "uint8",
          "name": "mirroring",
          "type": "uint8"
        },
        {
          "internalType": "address",
          "name": "recipient",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "referalID",
          "type": "uint256"
        }
      ],
      "name": "create",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "currentPhase",
      "outputs": [
        {
          "internalType": "uint8",
          "name": "",
          "type": "uint8"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "getApproved",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        }
      ],
      "name": "getRoleAdmin",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "",
          "type": "bytes32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "internalType": "uint256",
          "name": "index",
          "type": "uint256"
        }
      ],
      "name": "getRoleMember",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        }
      ],
      "name": "getRoleMemberCount",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "grantRole",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "hasRole",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        }
      ],
      "name": "isApprovedForAll",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        }
      ],
      "name": "isTokenLE",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "recipient",
          "type": "address"
        }
      ],
      "name": "mintLE",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "name",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "ownerOf",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "paused",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "phaseCountdown",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "phaseCountdownTime",
      "outputs": [
        {
          "internalType": "uint32",
          "name": "",
          "type": "uint32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "phaseLen",
      "outputs": [
        {
          "internalType": "uint16",
          "name": "",
          "type": "uint16"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "price",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        }
      ],
      "name": "readSettings",
      "outputs": [
        {
          "internalType": "uint8",
          "name": "bkg",
          "type": "uint8"
        },
        {
          "internalType": "uint8",
          "name": "duration",
          "type": "uint8"
        },
        {
          "internalType": "uint8",
          "name": "options",
          "type": "uint8"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint128",
          "name": "seed",
          "type": "uint128"
        },
        {
          "internalType": "uint8[2]",
          "name": "shapes",
          "type": "uint8[2]"
        },
        {
          "internalType": "uint16[3]",
          "name": "color",
          "type": "uint16[3]"
        },
        {
          "internalType": "uint8[4]",
          "name": "size",
          "type": "uint8[4]"
        },
        {
          "internalType": "uint8[2]",
          "name": "spacing",
          "type": "uint8[2]"
        },
        {
          "internalType": "uint8",
          "name": "mirroring",
          "type": "uint8"
        },
        {
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        }
      ],
      "name": "redeemLE",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "referalNewPercent",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "referalPercent",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "seed",
          "type": "string"
        },
        {
          "internalType": "uint16[3]",
          "name": "color",
          "type": "uint16[3]"
        },
        {
          "internalType": "uint8[2]",
          "name": "shapes",
          "type": "uint8[2]"
        },
        {
          "internalType": "uint8[4]",
          "name": "size",
          "type": "uint8[4]"
        },
        {
          "internalType": "uint8[2]",
          "name": "spacing",
          "type": "uint8[2]"
        },
        {
          "internalType": "uint8",
          "name": "mirroring",
          "type": "uint8"
        },
        {
          "internalType": "uint8[3]",
          "name": "settings",
          "type": "uint8[3]"
        },
        {
          "internalType": "uint8[4]",
          "name": "traits",
          "type": "uint8[4]"
        },
        {
          "internalType": "string",
          "name": "slot",
          "type": "string"
        }
      ],
      "name": "renderPreview",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "renounceRole",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "revokeRole",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "safeTransferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "internalType": "bytes",
          "name": "_data",
          "type": "bytes"
        }
      ],
      "name": "safeTransferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        },
        {
          "internalType": "bool",
          "name": "approved",
          "type": "bool"
        }
      ],
      "name": "setApprovalForAll",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "_uri",
          "type": "string"
        }
      ],
      "name": "setBaseURI",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "_uri",
          "type": "string"
        }
      ],
      "name": "setContractURI",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bool",
          "name": "state",
          "type": "bool"
        }
      ],
      "name": "setPause",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "rand",
          "type": "address"
        }
      ],
      "name": "setRandom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_id",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "_uri",
          "type": "string"
        }
      ],
      "name": "setTokenURI",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "startBlock",
          "type": "uint256"
        }
      ],
      "name": "startCountdown",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes4",
          "name": "interfaceId",
          "type": "bytes4"
        }
      ],
      "name": "supportsInterface",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "symbol",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "testRandom",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "",
          "type": "bytes32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_id",
          "type": "uint256"
        },
        {
          "internalType": "uint8",
          "name": "bkg",
          "type": "uint8"
        },
        {
          "internalType": "uint8",
          "name": "duration",
          "type": "uint8"
        },
        {
          "internalType": "uint8",
          "name": "options",
          "type": "uint8"
        },
        {
          "internalType": "string",
          "name": "slot",
          "type": "string"
        }
      ],
      "name": "tokenArt",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_id",
          "type": "uint256"
        }
      ],
      "name": "tokenArt",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "index",
          "type": "uint256"
        }
      ],
      "name": "tokenByIndex",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_id",
          "type": "uint256"
        }
      ],
      "name": "tokenData",
      "outputs": [
        {
          "internalType": "uint128",
          "name": "randomness",
          "type": "uint128"
        },
        {
          "internalType": "uint256",
          "name": "animation",
          "type": "uint256"
        },
        {
          "internalType": "uint8",
          "name": "shapes",
          "type": "uint8"
        },
        {
          "internalType": "uint8",
          "name": "hatching",
          "type": "uint8"
        },
        {
          "internalType": "uint8[4]",
          "name": "size",
          "type": "uint8[4]"
        },
        {
          "internalType": "uint8[2]",
          "name": "spacing",
          "type": "uint8[2]"
        },
        {
          "internalType": "uint8",
          "name": "mirroring",
          "type": "uint8"
        },
        {
          "internalType": "uint16[3]",
          "name": "color",
          "type": "uint16[3]"
        },
        {
          "internalType": "uint8",
          "name": "contrast",
          "type": "uint8"
        },
        {
          "internalType": "uint8",
          "name": "shades",
          "type": "uint8"
        },
        {
          "internalType": "uint8",
          "name": "scheme",
          "type": "uint8"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "index",
          "type": "uint256"
        }
      ],
      "name": "tokenOfOwnerByIndex",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "tokenURI",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "totalSupply",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "transferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        }
      ],
      "name": "trueID",
      "outputs": [
        {
          "internalType": "int8",
          "name": "",
          "type": "int8"
        }
      ],
      "stateMutability": "pure",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        }
      ],
      "name": "unredeemed",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_renderer",
          "type": "address"
        }
      ],
      "name": "updateRenderer",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint8",
          "name": "shapes",
          "type": "uint8"
        },
        {
          "internalType": "uint8",
          "name": "hatching",
          "type": "uint8"
        },
        {
          "internalType": "uint16[3]",
          "name": "color",
          "type": "uint16[3]"
        },
        {
          "internalType": "uint8[4]",
          "name": "size",
          "type": "uint8[4]"
        },
        {
          "internalType": "uint8[2]",
          "name": "position",
          "type": "uint8[2]"
        },
        {
          "internalType": "bool",
          "name": "exclusive",
          "type": "bool"
        }
      ],
      "name": "validateParams",
      "outputs": [],
      "stateMutability": "pure",
      "type": "function"
    },
    {
      "stateMutability": "payable",
      "type": "receive"
    }
  ]

// init web3 provider and load contract
var web3 = new Web3(infuraEndpoint)
const tinyboxesContract = new web3.eth.Contract(
  tinyboxesABI,
  CONTRACT_ADDRESS,
)

// console.log(CONTRACT_ADDRESS)

exports.handler = async (event, context) => {
  try {
    // console.log(event.body)

    if (!event.body) {
      return {
        statusCode: 400,
        body: "Request body is empty/undefined",
      };
    }

    // Parse Webhook Payload
    const payload = JSON.parse(event.body);

    // console.log(payload);
    // console.log(payload.event.data);
    // console.log(payload.event.data.block.logs);

    // Validate Webhook Event
    if (!payload || payload.webhookId !== "wh_n3qnbujh8ichzsv7") {
      return {
        statusCode: 400,
        body: "Invalid webhook event",
      };
    }

    // lookup token ID from tx input data
    const txLogs = payload.event.data.block.logs;
    const txData = [
      {
        data: '0x0000000000000000000000000000000000000000000000000000000000000064000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000000000000000001',
        topics: [
          '0xbd960691de2d71e309b1eea54deff5f167fbe6ce9c20bbea1daff6e2d16d202b'
        ],
        index: 316,
        account: { address: '0x46f9a4522666d2476a5f5cd51ea3e0b5800e7f98' },
        transaction: {
          hash: '0x45bd90eeca73cd5e0ee40114d84f16aa942a96df9f665afb1116b747143b3bd0',
          nonce: 618,
          index: 77,
          value: '0x0',
          gasPrice: '0x1c98e2cf7',
          maxFeePerGas: '0x1c98e2cf7',
          maxPriorityFeePerGas: '0x1c98e2cf7',
          gas: 57112,
          gasUsed: 37709,
          cumulativeGasUsed: 10486426,
          effectiveGasPrice: '0x1c98e2cf7',
          createdContract: null
        }
      }
    ];
    // TODO: handle multiple log events and minting
    const txHash = txData[0].transaction.hash; // logs is a list
    // console.log(txHash)
    
    const tx = await web3.eth.getTransaction(txHash)
    const rawIdData = tx.input.slice(10, 74);

    let art, fileName;
    let tokenId = parseInt(rawIdData, 16);
    const isLE = tokenId < 0 || tokenId > 2222;
    // LE token IDs start from the maximum uint256 value and decrement
    const MAX_UINT256 = web3.utils.toBN('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
    const tokenIdBN = MAX_UINT256.sub(web3.utils.toBN(tokenId));
    const tokenIdLE = tokenIdBN.toString();

    //console.log(tokenId, tokenIdLE, isLE);

    tokenId = isLE ? tokenIdLE : tokenId;

    try {
        art = await tinyboxesContract.methods.tokenArt(tokenId).call();
        // console.log(`Token ID ${tokenId} Art: ${art}`);
    } catch (error) {
        console.log(`Error fetching/saving art for token ID ${tokenId}: ${error.message}`);
    }

    // Generate SVG data in memory
    const svgs = [
        {
            filename: `token_${tokenId}.svg`,
            content: art,
        },
    ];

    // console.log(svgs);

    // Authenticate with GitHub
    const octokit = new Octokit({
      auth: GITHUB_TOKEN,
      request: {
        fetch: fetch,
      },
    });
    

    // Commit SVG data directly to GitHub
    for (const svg of svgs) {
      const encodedContent = Buffer.from(svg.content).toString("base64"); // Encode in base64 for GitHub API
      const path = `public/art/${svg.filename}`

      console.log(path)

      const response = await octokit.repos.getContent({
        owner: 'skyfly200',
        repo: 'tiny-boxes',
        path: path
      });
      
      const fileSha = response.data.sha;
      
      console.log(fileSha);
      await octokit.repos.createOrUpdateFileContents({
        owner: REPO_OWNER,
        repo: REPO_NAME,
        path: path, // Target directory and filename in repo
        message: `Add/update ${svg.filename} via Netlify Function`,
        content: encodedContent,
        branch: BRANCH_NAME,
        sha: fileSha,
      });
    }

    return {
      statusCode: 200,
      body: "Files pushed successfully to GitHub!",
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Internal Server Error", error: error.message }),
    };
  }
};
