//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;

// needed for upgradability
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

import "./TinyBoxesBase.sol";
import "./TinyBoxesPricing.sol";

abstract contract TinyBoxesStore is TinyBoxesBase, TinyBoxesPricing {
    /**
     * @notice Modifier to check if tokens are sold out
     */
    modifier notSoldOut {
        // ensure we still have not reached the cap
        require(
            _tokenIds.current() < TOKEN_LIMIT,
            "ART SALE IS OVER. Tinyboxes are now only available on the secondary market."
        );
        _;
    }

    /**
     * @dev handle the payment for tokens
     * @param withLink boolean flag for paying with LINK instead of ETH
     * @param amount payed
     * @param from address
     */
    function handlePayment(bool withLink, uint256 amount, address from) internal {
        // check if still minting the artist tokens
        if (_tokenIds.current() < ARTIST_PRINTS) {
            // Check that the calling account has the artist role
            require(hasRole(ARTIST_ROLE, from), "Only the admin can mint the alpha tokens. Wait your turn FFS");
        } else {
            // TODO: setup beta sale auction and pricing
            // if still minting the beta sale
            // else minting public release
            uint256 price = withLink ? currentLinkPrice() : currentPrice();
            require(amount >= price, "insuficient payment"); // return if they dont pay enough
            // give change if they over pay
            if (amount > price) { 
                if (withLink) LINK_TOKEN.transfer(from, amount - price); // change in LINK
                else msg.sender.transfer(amount - price); // change in ETH
            }
        }
    }

    /**
     * @dev Get the current price of a token
     * @return price in wei of a token currently
     */
    function currentPrice() public view returns (uint256 price) {
        price = priceAt(_tokenIds.current());
    }

    /**
     * @dev Get the current price of a token in LINK (Chainlink Token)
     * @return price in LINK of a token currently
     */
    function currentLinkPrice() public view returns (uint256 price) {
        price = linkPriceAt(_tokenIds.current());
    }

    /**
     * @dev Approve an address for LINK withdraws
     * @param account address to approve
     */
    function aproveLINKWithdraws(address account) external onlyRole(ADMIN_ROLE) {
        // set account address to true in witdraw aproval mapping
        _setupRole(TREASURER_ROLE, account);
    }

    /**
     * @dev Withdraw LINK tokens from the contract balance to contract owner
     * @param amount of link to withdraw (in smallest divisions of 10**18)
     */
    // TODO: make a version that checks to see we have enough link to fullfill randomness for remaining unminted tokens
    function withdrawLINK(uint256 amount) external onlyRole(TREASURER_ROLE) returns (bool) {
        // ensure we have at least that much LINK
        require(
            LINK_TOKEN.balanceOf(address(this)) >= amount,
            "Not enough LINK for requested withdraw"
        );
        // send amount of LINK tokens to the transaction sender
        return LINK_TOKEN.transfer(msg.sender, amount);
    }
}
