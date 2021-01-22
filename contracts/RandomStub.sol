//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.0;

contract Randomizer {
    // stub the core RNG service function
    function returnValue() external view returns (bytes32){
        return keccak256(abi.encodePacked(
            block.number,
            block.coinbase,
            block.difficulty,
            blockhash(block.number - 1),
            tx.origin
        ));
    }
}
