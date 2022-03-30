# tiny-boxes rarity indexing scripts

[![built-with openzeppelin](https://img.shields.io/badge/built%20with-OpenZeppelin-3677FF)](https://docs.openzeppelin.com/)
[![Netlify Status](https://api.netlify.com/api/v1/badges/40655e36-a4fd-4744-bfca-13d208c2987b/deploy-status)](https://app.netlify.com/sites/tiny-boxes/deploys)

The toolchain described below shows how three pythin scripts and a bot scripts are used to query data from opensea or tinybox api, and generate a file traits.json which is used to generate an index for determining rarity of each trait. The third script consumes the first two data files ( traits and rarity ) to produce individual rarity files for each (NFT) box.

Discord bot is used to provide a query service by consuming rarity_by_box.json to provide reporting data upon request for each NFT properety..


# Toolchain

generateTraits.py   - this script is run via "python3 generatetraits.py > traits.json"  it makes its request to the Tinybox NFT API directly
                    - ( install dependencies ) -  pip3 install requests


traitsToRarity.py   - this script is run via "python3 traitsToRarity.py > rarity.json"  it generates a rarity index for each trait



rarityAndTraitsToIndex.py   - this script is run via "python3 rarityAndTraitsToIndex.py > rarity_by_box.json" it generates a queryable api for each NFT's trait rarity


# run discord bot

tinyboxbot.py   - this script is run via "python3 tinyboxbot.py" 
                - install dependencies - pip3 install datetime requests discord
                
                
