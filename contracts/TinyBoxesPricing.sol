//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;

// Chainlink Contracts
import "./chainlink/ChainlinkClient.sol";  // includes SafeMath
import "./chainlink/interfaces/AggregatorInterface.sol";

import "./TinyBoxesBase.sol";

contract TinyBoxesPricing is TinyBoxesBase, ChainlinkClient {
    using SafeMath for uint256;

    AggregatorInterface internal refFeed;

    address constant DEFAULT_FEED_ADDRESS = 0xb8c99b98913bE2ca4899CdcaF33a3e519C20EeEc; // Ropsten
    //address constant DEFAULT_FEED_ADDRESS = 0xeCfA53A8bdA4F0c4dd39c55CC8deF3757aCFDD07; // Mainnet

    uint256 public linkPremium = 2000; // in percent * 1000
    uint256 public startPrice = 160000000000000000; // in wei
    uint256 public priceIncrease = 1000000000000000; // in wei

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits ChainlinkClient
     */
    constructor(address _link, address _feed) public {
        // Set the address for the LINK token to the public network address
        // or use an address provided as a parameter if set
        if (_link == address(0)) setPublicChainlinkToken();
        else setChainlinkToken(_link);
        
        // set the feed address and init the interface
        if (_feed == address(0))
            refFeed = AggregatorInterface(DEFAULT_FEED_ADDRESS); // init LINK/ETH with default aggrigator contract address
        else refFeed = AggregatorInterface(_feed); // init LINK/ETH with custom aggrigator contract address
    }

    /**
     * @dev Get the price of token number _id in LINK (Chainlink Token) including the premium
     * @return price in LINK of a token currently
     */
    function linkPriceAt(uint256 _id) public view returns (uint256 price) {
        price = (ethToLink(priceAt(_id)) * (10**5 + linkPremium)) / 10**5;
    }

    /**
     * @dev Convert a value in Eth to one in LINK (Chainlink Token)
     * @return value in LINK eqivalent to the provided Eth value
     */
    function ethToLink(uint256 priceEth) internal view returns (uint256 value) {
        value = ((priceEth * ONE_LINK) / uint256(refFeed.latestAnswer()));
    }

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

    /**
     * @dev Set the link premium
     */
    function setLINKPremium(uint256 amount) external onlyRole(ADMIN_ROLE) {
        linkPremium = amount;
    }

    /**
     * @dev Get the current price of a token in LINK (Chainlink Token)
     * @return price in LINK of a token currently
     */
    function currentLinkPrice() public view returns (uint256 price) {
        price = linkPriceAt(_tokenIds.current());
    }
}
