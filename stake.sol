// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DevCoin is ERC20 {

    //15780000 = 6 Months
    uint public immutable StakeEndTime = 100;
    address Owner;

    modifier onlyOwner(){
        Owner = msg.sender;
        _;
    }

    constructor() ERC20("DevCoin", "DC") {
        _mint(msg.sender, (3000/2) * 10 ** decimals());
        Owner = msg.sender;
    }

    function unstake() public onlyOwner{
        IERC20(address(this)).transfer(msg.sender, 3000 * 10 ** decimals());
    }

    function stakeBalance() public view returns(uint256){
        return address(this).balance;
    }
}