//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;

import "./TinyBoxesBase.sol";

contract TinyBoxesPricing is TinyBoxesBase {
    using SafeMath for uint256;

    uint256 public startPrice = 35000000000000000; // in wei
    uint256 public priceIncrease = 1000000000000000; // in wei

    /**
     * @dev Get the price of a specific token id
     * @param _id of the token
     * @return price in wei of token id
     */
    function priceAt(uint256 _id) public view returns (uint256 price) {
        //uint256 tokeninflation = (_id / 2) * priceIncrease; // add .001 eth to price per 2 tokens minted
        price = startPrice; //+ tokeninflation;
    }

    /**
     * @dev Get the current price of a token
     * @return price in wei of a token currently
     */
    function currentPrice() public view returns (uint256 price) {
        price = priceAt(_tokenIds.current());
    }
}
