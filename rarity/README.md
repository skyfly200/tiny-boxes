# tiny-boxes rarity indexing scripts

[![built-with openzeppelin](https://img.shields.io/badge/built%20with-OpenZeppelin-3677FF)](https://docs.openzeppelin.com/)
[![Netlify Status](https://api.netlify.com/api/v1/badges/40655e36-a4fd-4744-bfca-13d208c2987b/deploy-status)](https://app.netlify.com/sites/tiny-boxes/deploys)


# Toolchain

generateTraits.py   - this script is run via "python3 generatetraits.py > traits.json"  it makes its request from the Tinybox NFT API directly
                    - ( install dependencies ) -  pip3 install requests


traitsToRarity.py   - this script is run via "python3 traitsToRarity.py > rarity.json"  it generates a rarity index for each trait



rarityAndTraitsToIndex.py   - this script is run via "rarityAndTraitsToIndex.py > rarity_by_box.json" it generates a queryable api for each NFT's trait rarity


