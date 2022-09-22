//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract automateStaking is KeeperCompatibleInterface {

    address payable _to = payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);

    uint public immutable interval;
    uint public lastTimeStamp;

    constructor (uint updateInterval) payable{
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
    }

    function balance() public view returns(uint256){
        return address(this).balance;
    }


    function checkUpkeep(bytes calldata ) external view override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            _to.transfer(address(this).balance);
        }
    }
}