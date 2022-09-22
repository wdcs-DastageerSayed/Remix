//"SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


contract Forwarder {

  address public destinationAddress;

  constructor(address _destinationAddress) {
    destinationAddress = _destinationAddress;
  }

  function withdraw() public payable{
      payable(destinationAddress).transfer(address(this).balance);
  }

  fallback() external payable{
      //require(address(this).balance>0,"Op");
      payable(destinationAddress).transfer(address(this).balance);
  }


}