//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

// needed for upgradability
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TinyBoxesLE is ERC721, AccessControl  {
    using Counters for Counters.Counter;

    Counters.Counter internal _tokenIds;

    // set contract config constants
    uint16 public constant TOKEN_LIMIT = 100;

    // Create role identifiers
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits ERC721
     */
    constructor() public ERC721("TinyBoxes LE", "[TB][LE]") {
        // Grant all roles to the account deploying this contract for testing
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Modifier to only allow acounts of a specified role to call a function
     */
    modifier onlyRole(bytes32 _role) {
        // Check that the calling account has the required role
        require(hasRole(_role, msg.sender), "Caller dosn't have permission to use this function");
        _;
    }

}
