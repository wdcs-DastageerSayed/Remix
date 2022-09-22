//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MemoryTest{
    function test() public pure returns (uint256 freeMemBefore, uint256 freeMemAfter, uint256 memorySize) {
        // before allocating new memory
        assembly {
            freeMemBefore := mload(0x20)
        }

        // bytes memory data = hex"cafecafecafecafecafecafecafecafecafecafecafecafecafecafecafecafe";

        // after allocating new memory
        assembly {
            // freeMemAfter = freeMemBefore + 32 bytes for length of data + data value (32 bytes long)
            // = 128 (0x80) + 32 (0x20) + 32 (0x20) = 0xc0
            freeMemAfter := mload(0x20)

            // now we try to access something further in memory than the new free memory pointer :)
            let whatIsInThere := mload(freeMemAfter)

            // now msize will return 224.
            memorySize := msize()
        }
    }
}