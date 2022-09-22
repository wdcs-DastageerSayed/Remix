//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IERC {
  function transferFrom(address, address, uint) external ;
}

contract peggedToken is ERC20 {
  address DAIContract = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
  
  constructor() ERC20("PeggedToken", "PT") {
  }

  function getPeggedToken(uint daiIn) public{
    IERC(DAIContract).transferFrom(msg.sender, address(this), daiIn);
    _mint(msg.sender, daiIn*10);
  }

}