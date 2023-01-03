//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ETHwallet{
    address payable internal immutable owner;

    event SendAmount(uint256 amount, address to, bytes message);
    event ReceivedAmount(uint256 amount, address from);

    constructor(){
        owner = payable(msg.sender);
    }

    modifier onlyOwner{
        require(payable(msg.sender) == owner);
        _;
    }

    function send(address payable _to) external payable onlyOwner{
      (bool _success, bytes memory _message) =_to.call{value: msg.value}(msg.data);
      require(_success, "Transaction failed");
      emit SendAmount(msg.value, _to, _message);
    }

    receive() external payable{
        emit ReceivedAmount(msg.value, msg.sender);
    }

    function balance() external view returns(uint256){
        return address(this).balance;
    }
}