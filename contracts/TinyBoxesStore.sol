// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/EnumerableMap.sol";

import "./TinyBoxesBase.sol";

contract TinyBoxesStore is TinyBoxesBase {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Utils for *;

    event RedeemedLE(address by, uint256 id);

    /**
     * @dev Contract constructor.
     */
    constructor(address entropySourceAddress)
        public
        TinyBoxesBase(entropySourceAddress)
    {}

    // Payment Functions

    /**
     * @dev receive direct ETH transfers
     * @notice for splitting royalties
     */
    receive() external payable {
        _splitFunds(msg.value); 
    }

    /**
     * @dev withdraw any funds leftover in contract
     */
    function withdraw() external {
        onlyRole(ADMIN_ROLE);
        msg.sender.transfer(address(this).balance);
    }

    /**
     * @dev Split payments
     */
    function _splitFunds(uint256 amount) internal {
        if (amount > 0) {
            uint256 partA = amount.mul(60).div(100);
            skyfly.transfer(partA);
            natealex.transfer(amount.sub(partA));
        }
    }

    /**
     * @dev handle the payment for tokens
     */
    function handlePayment(uint256 referalID, address recipient) internal {
        // check for suficient payment
        require(msg.value >= price, "insuficient payment");
        // give the buyer change
        if (msg.value > price) msg.sender.transfer(msg.value.sub(price));
        // lookup the referer by the referal token id owner
        address payable referer = _exists(referalID) ? payable(ownerOf(referalID)) : tx.origin;
        // give a higher percent for refering a new user
        uint256 percent = (balanceOf(tx.origin) == 0) ? referalNewPercent : referalPercent;
        // referer can't be sender or reciever - no self referals
        uint256 referal = (referer != msg.sender && referer != tx.origin && referer != recipient) ? 
            price.mul(percent).div(100) : 0; 
        // pay referal percentage
        if (referal > 0) referer.transfer(referal);
        // split remaining payment
        _splitFunds(price.sub(referal));
    }

    /**
     * @dev Check if a TinyBox Promo Token is unredeemed
     * @param id of the token to check
     */
    function unredeemed(uint256 id) public view returns (bool) {
        return boxes[id].shapes == 0;
    }

    // Token Creation Functions

    /**
     * @dev Create a new LimitedEdition TinyBox Token
     * @param recipient of the new LE TinyBox token
     */
    function mintLE(address recipient) external {
        onlyRole(ADMIN_ROLE);
        require(_tokenPromoIds.current() < MAX_PROMOS, "NO MORE");
        uint256 id = UINT_MAX - _tokenPromoIds.current();
        _safeMint(recipient, id); // mint the new token to the recipient address
        _tokenPromoIds.increment();
    }

    /**
     * @dev Create a new TinyBox Token
     * @param _seed of token
     * @param shapes count and hatching mod value
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size range for boxes
     * @param spacing grid and spread params
     * @param recipient of the token
     * @return id of the new token
     */
    function create(
        string calldata _seed,
        uint8[2] calldata shapes,
        uint16[3] calldata color,
        uint8[4] calldata size,
        uint8[2] calldata spacing,
        uint8 mirroring,
        address recipient,
        uint256 referalID
    ) external payable returns (uint256) {
        notSoldOut();
        notPaused();
        notCountdown();
        handlePayment(referalID, recipient);
        // check box parameters
        validateParams(shapes[0], shapes[1], color, size, spacing, false);
        // make sure caller is never the 0 address
        require(recipient != address(0), "0x00 Recipient Invalid");
        // check payment and give change
        (referalID, recipient);
        // get next id & increment the counter for the next callhandlePayment
        uint256 id = _tokenIds.current();
        _tokenIds.increment();
        // check if its time to pause for next phase countdown
        if (_tokenIds.current().mod(phaseLen) == 0)
            blockStart = block.number.add(phaseCountdown.mul(currentPhase()));
        // add block number and new token id to the seed value
        uint256 seed = _seed.stringToUint();
        // request randomness
        uint128 rand = getRandomness(id, seed);
        // create a new box object in storage
        boxes[id] = TinyBox({
            randomness: rand,
            hue: color[0],
            saturation: (rand % 200 == 0) ? uint8(0) : uint8(color[1]), // 0.5% chance of grayscale
            lightness: uint8(color[2]),
            shapes: shapes[0],
            hatching: shapes[1],
            widthMin: size[0],
            widthMax: size[1],
            heightMin: size[2],
            heightMax: size[3],
            spread: spacing[0],
            grid: spacing[1],
            mirroring: mirroring,
            bkg: 0,
            duration: 10,
            options: 1
        });
        _safeMint(recipient, id); // mint the new token to the recipient address
    }

    /**
     * @dev Create a Limited Edition TinyBox Token from a Promo token
     * @param seed for the token
     * @param shapes count and hatching mod value
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size range for boxes
     * @param spacing grid and spread params
     */
    function redeemLE(
        uint128 seed,
        uint8[2] calldata shapes,
        uint16[3] calldata color,
        uint8[4] calldata size,
        uint8[2] calldata spacing,
        uint8 mirroring,
        uint256 id
    ) external {
        notPaused();
        //  check owner is caller
        require(ownerOf(id) == msg.sender, "NOPE");
        // check token is unredeemed
        require(unredeemed(id), "USED");
        // check box parameters are valid
        validateParams(shapes[0], shapes[1], color, size, spacing, true);
        // create a new box object
        boxes[id] = TinyBox({
            randomness: uint128(seed),
            hue: color[0],
            saturation: uint8(color[1]),
            lightness: uint8(color[2]),
            shapes: shapes[0],
            hatching: shapes[1],
            widthMin: size[0],
            widthMax: size[1],
            heightMin: size[2],
            heightMax: size[3],
            spread: spacing[0],
            grid: spacing[1],
            mirroring: mirroring,
            bkg: 0,
            duration: 10,
            options: 1
        });
        emit RedeemedLE(msg.sender, id);
    }
}
