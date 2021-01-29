// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface Entropy {
    function returnValue() external view returns(bytes32);
    function clear() external;
}

contract Randomizer is AccessControl {
    using EnumerableSet for *;

    Counters.Counter private _calls;
    
    uint256 private defaultLevels = 2;

    EnumerableSet.AddressSet private moduleAddresses;
    
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant CALLER_ROLE = keccak256("CALLER_ROLE");
    
    constructor() public {
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(CALLER_ROLE, ADMIN_ROLE);
    }
    
    function checkForRole(bytes32 _role) view internal {
        // Check that the calling account has the required role
        require(hasRole(_role, msg.sender), "NOPE");
    }
    
    // ADMIN functions
    function setLevels(uint256 levels) external {
        checkForRole(ADMIN_ROLE);
        require(levels > 0, "lvl!>0");
        defaultLevels = levels;
    }
    
    function deployModule(bytes memory code) public {
        checkForRole(ADMIN_ROLE);
        address addr;
        assembly {
          addr := create2(0, add(code, 0x20), mload(code), 0)
          if iszero(extcodesize(addr)) { revert(0, 0) }
        }
        require(moduleAddresses.add(addr));
    }
    
    function removeModule(address _module) public {
        checkForRole(ADMIN_ROLE);
        Entropy(_module).clear(); // delfdetruct the contract for gas savings
        require(moduleAddresses.remove(_module));
    }
    
    // save gas here if you need to change up the pool often without need of growing it
    function replaceModule(bytes calldata code, address target) external {
        removeModule(target);
        deployModule(code);
    }
    
    // RNG service functions
    function returnValue() external view returns (bytes32){
        return chainedEntropy(0, defaultLevels);
    }
    
    function chainedEntropy(uint256 salt, uint256 e) public view returns (bytes32 entropy) {
        checkForRole(CALLER_ROLE);
        require(moduleAddresses.length() > 0, "EMPTY");
        require(e > 0, "E!>0");
        entropy =  keccak256(abi.encodePacked(  // this hashed data decides the first module to call in the chain
            block.number,
            block.coinbase,
            block.difficulty,
            blockhash(block.number - 1),
            tx.origin,
            tx.gasprice,
            now,
            salt
        ));
        for (uint256 i=0; i<e; i++) { // compound e layers of chained entropy modules
            Entropy module = Entropy(moduleAddresses.at( uint256(entropy) % moduleAddresses.length() )); 
            entropy = keccak256(abi.encodePacked(
                entropy, // chain with last entropy
                i, // use the entropy chain index
                now, // change every level in sync with the timestamp
                module.returnValue() // lookup entropy from the module
            ));
        }
    }
}
