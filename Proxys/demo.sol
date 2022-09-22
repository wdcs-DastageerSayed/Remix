// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract demo {

    struct Storage {
        mapping(bytes32 => bool) _bool;
        mapping(bytes32 => int) _int;
        mapping(bytes32 => uint) _uint;
        mapping(bytes32 => string) _string;
        mapping(bytes32 => address) _address;
        mapping(bytes32 => bytes) _bytes;
    }

    Storage internal s;

    function setBoolean(bytes32 h, bool v) public {
        s._bool[h] = v;
    }

    function getBoolean(bytes32 h) public view returns (bool){
        return s._bool[h];
    }

    function rollback() public pure returns(bytes32){
        return bytes32(uint256(keccak256('eip1967.proxy.rollback')) - 1);
    } 
}