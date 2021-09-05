import Vue from "vue";
import Vuex from "vuex";
import Web3 from "web3";
import VuexPersist from "vuex-persist";

//import TinyBoxes from 'Contracts/TinyBoxes.sol'
//import { tinyboxesAddress, tinyboxesABI } from "@/tinyboxes-contract";

const tinyboxesABI = [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "rand",
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
      "name": "ANIMATOR_ROLE",
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
      "name": "ARTIST_ROLE",
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
          "internalType": "string",
          "name": "_seed",
          "type": "string"
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
        }
      ],
      "name": "buyFor",
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
      "name": "phaseLen",
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
      "name": "startCoundown",
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
          "internalType": "string",
          "name": "seed",
          "type": "string"
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
          "internalType": "uint8[4]",
          "name": "traits",
          "type": "uint8[4]"
        },
        {
          "internalType": "uint8[3]",
          "name": "settings",
          "type": "uint8[3]"
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
      "name": "tokenPreview",
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
      "inputs": [],
      "name": "adtokentoCart",
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
    }
  ]

Vue.use(Vuex);

const vuexLocalStorage = new VuexPersist({
  key: "tinyboxes",
  storage: window.localStorage,
  reducer: (state: any) => ({
    count: state.count,
    cart: state.cart,
    itemsPerPage: state.itemsPerPage,
    tokenIDs: state.tokenIDs,
    cachedTokens: state.cachedCells,
  }),
});

const store = new Vuex.Store({
  plugins: [vuexLocalStorage.plugin],
  state: {
    animationTitles: [
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
      "Staggered Spread",
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
    ],
    schemeTitles: [
      "Triadic",
      "Complimentary",
      "Tetradic",
      "Analogous",
      "Analogous and Complimentary",
      "Split Complimentary",
      "Complimentary and Analogous",
      "Series",
      "Square",
      "Mono",
    ],
    tinyboxesAddress: '0x3b829CFD48e2C7df548Cab8AF0E42eC788869134',
    openseaStoreURL: 'https://testnets.opensea.io/assets/tinyboxes-lvupeos4gn',
    openseaTokenURL: 'https://testnets.opensea.io/assets/0x3b829CFD48e2C7df548Cab8AF0E42eC788869134/',
    currentAccount: "",
    web3Status: "loading",
    web3: null,
    network: null,
    targetNetwork: "rinkeby",
    count: null,
    cart: null,
    itemsPerPage: 12,
    tokenIDs: { null: null },
    cachedTokens: { null: null },
    contracts: { null: null },
  },
  mutations: {
    setCount(state, count) {
      state.count = count;
    },
    setCart(state, cart) {
      state.cart = cart;
    },
    setItemsPerPage(state, n) {
      state.itemsPerPage = n;
    },
    setToken(state, payload) {
      const id: keyof typeof state.cachedTokens = payload.id;
      state.cachedTokens[id] = payload.data;
    },
    setContract(state, payload) {
      const id: keyof typeof state.contracts = payload.id;
      state.contracts[id] = payload.contract;
    },
    setWeb3(state, instance) {
      state.web3 = instance;
    },
    setWeb3Status(state, status) {
      state.web3Status = status;
    },
    setAccount(state, address) {
      state.currentAccount = address;
    },
    setNetwork(state, network) {
      state.network = network;
    },
  },
  actions: {
    async initialize(context) {
      await context.dispatch("loadWeb3");
      await context.dispatch("loadAccount");
      await context.dispatch("registerContracts");
    },
    loadWeb3(context) {
      return new Promise((resolve, reject) => {
        if ((window as any).ethereum) {
          context.commit("setWeb3", new Web3((window as any).ethereum));
          try {
            // Request account access if needed
            (window as any).ethereum.enable().then(() => {
              context.commit("setWeb3Status", "active");
              resolve(true);
            });
          } catch (error) {
            context.commit("setWeb3Status", "denied");
            reject("denied");
          }
        } else if ((window as any).web3) {
          // Legacy dapp browsers...
          context.commit(
            "setWeb3",
            new Web3((window as any).web3.currentProvider)
          );
          context.commit("setWeb3Status", "active");
          resolve(true);
        } else {
          // Non-dapp browsers...
          context.commit("setWeb3Status", "inactive");
          resolve(true);
        }
      });
    },
    loadAccount(context) {
      return new Promise((resolve, reject) => {
        const web3: any = context.state.web3;
        if (web3 !== null) {
          web3.eth.getAccounts((err: any, resp: any) => {
            if (err) reject(err);
            else {
              context.commit("setAccount", resp[0]);
              web3.eth.net.getNetworkType((err: any, network: any)=> {
                context.commit("setNetwork", network);
                resolve(resp[0]);
              });
            }
          });
        } else reject();
      });
    },
    registerContracts(context) {
      return new Promise((resolve, reject) => {
        const web3: any = context.state.web3;
        if (web3 !== null) {
          context.commit("setContract", {
            id: "tinyboxes",
            contract: new web3.eth.Contract(tinyboxesABI, context.state.tinyboxesAddress),
          });
          resolve(true);
        } else reject();
      });
    },
  },
  getters: {
    itemsPerPage: (state) => {
      return state.itemsPerPage;
    },
    currentAccount: (state) => {
      return state.currentAccount;
    },
    web3Status: (state) => {
      return state.web3Status;
    },
    wrongNetwork: (state) => {
      return state.network !== null && state.network !== state.targetNetwork;
    },
  },
});

export default store;
