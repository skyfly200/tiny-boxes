//SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TinyBoxesLE is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter internal _tokensCounter;

    // set contract config constants
    uint16 public constant TOKEN_LIMIT = 100;
    uint256 UINT_MAX = uint256(-1); // -1 as an unsigned integer
    string public contractURI = "https://rinkeby.tinybox.shop/TinyBoxesLE.json";

    address public target;

    /**
     * @dev Contract constructor.
     * @param _target contract that the promo is for
     * @notice Constructor inherits ERC721
     */
    constructor(address _target) public ERC721("TinyBoxes LE", "[TB][LE]") {
        target = _target;
    }

    /**
     * @dev Caller must match the provided addresss param
     * @param _auth address to check against caller
     * @dev any other address will throw with "NOPE"
     */
    function onlyAddress(address _auth) internal view {
        require(msg.sender == _auth, "NOPE");
    }

    
    /**
     * @dev Update the base URI field
     * @param _uri base for all tokens 
     * @dev Only the admin can call this
     */
    function setBaseURI(string calldata _uri)
        external
    {
        onlyAddress(owner()); // must be called by the owner
        _setBaseURI(_uri);
    }

    /**
     * @dev Update the contract URI field
     * @param _uri for the contract metadata
     * @dev Only the admin can call this
     */
    function setContractURI(string calldata _uri)
        external
    {
        onlyAddress(owner()); // must be called by the owner
        contractURI = _uri;
    }

    /**
     * @dev Mint a new token as the promo admin
     * @param to recipient address of the new token
     * @dev Only the admin can call this
     */
    function adminMint(address to) external {
        onlyAddress(owner()); // must be called by the owner
        mint(to);
    }

    /**
     * @dev Mint a new token from the target
     * @param to recipient address of the new token
     * @dev Only the target can call this
     */
    function targetMint(address to) external {
        onlyAddress(target); // must be called by the target promo contract
        mint(to);
    }

    /**
     * @dev mint a new promo token
     * @param to address of the token recipient
     */
    function mint(address to) private {
        require(_tokensCounter.current() < TOKEN_LIMIT);
        uint256 id = UINT_MAX.sub(_tokensCounter.current());
        _mint(to, id);
        _tokensCounter.increment();
    }

    /**
     * @dev redeem the token of the given id
     * @param id of the token to redeem 
     * @dev Only the target can call this
     */
    function redeem(uint256 id) external {
        onlyAddress(target); // must be called by the target promo contract
        _burn(id);
    }
}
