//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

library Random {
    /**
     * Initialize the pool with the entropy of the blockhashes of the blocks in the closed interval [earliestBlock, latestBlock]
     * The argument "seed" is optional and can be left zero in most cases.
     * This extra seed allows you to select a different sequence of random numbers for the same block range.
     */
    function init(
        uint256 earliestBlock,
        uint256 latestBlock,
        uint256 seed
    ) internal view returns (bytes32[] memory) {
        //require(block.number-1 >= latestBlock && latestBlock >= earliestBlock && earliestBlock >= block.number-256, "Random.init: invalid block interval");
        require(
            block.number - 1 >= latestBlock && latestBlock >= earliestBlock,
            "Random.init: invalid block interval"
        );
        bytes32[] memory pool = new bytes32[](latestBlock - earliestBlock + 2);
        bytes32 salt = keccak256(abi.encodePacked(earliestBlock, seed));
        for (uint256 i = 0; i <= latestBlock - earliestBlock; i++) {
            // Add some salt to each blockhash so that we don't reuse those hash chains
            // when this function gets called again in another block.
            pool[i + 1] = keccak256(
                abi.encodePacked(blockhash(earliestBlock + i), salt)
            );
        }
        return pool;
    }

    /**
     * Initialize the pool from the latest "num" blocks.
     */
    function initLatest(uint256 num, uint256 seed)
        internal
        view
        returns (bytes32[] memory)
    {
        return init(block.number - num, block.number - 1, seed);
    }

    /**
     * Advances to the next 256-bit random number in the pool of hash chains.
     */
    function next(bytes32[] memory pool) internal pure returns (uint256) {
        require(pool.length > 1, "Random.next: invalid pool");
        uint256 roundRobinIdx = (uint256(pool[0]) % (pool.length - 1)) + 1;
        bytes32 hash = keccak256(abi.encodePacked(pool[roundRobinIdx]));
        pool[0] = bytes32(uint256(pool[0]) + 1);
        pool[roundRobinIdx] = hash;
        return uint256(hash);
    }

    function stringToUint(string memory s)
        internal
        pure
        returns (uint256 result)
    {
        bytes memory b = bytes(s);
        uint256 i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    /**
     * Produces random integer values, uniformly distributed on the closed interval [a, b]
     */
    function uniform(
        bytes32[] memory pool,
        int256 a,
        int256 b
    ) internal pure returns (int256) {
        require(a <= b, "Random.uniform: invalid interval");
        return int256(next(pool) % uint256(b - a + 1)) + a;
    }
}
