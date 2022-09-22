//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Escrow{

    address payable public buyer;
    address payable public seller;
    address payable public arbiter;
    mapping(address => uint256) totalAmount;

    modifier onlyBuyer{
        require(buyer == msg.sender || msg.sender == arbiter);
        _;
    }  

    modifier onlySeller{
        require(msg.sender == seller);
        _;
    }

    modifier instate(State expected_state){
        require(state == expected_state);
        _;
    }

    enum State{
        awate_payment,
        awate_delivery,
        complete
    }

    State public state;

    constructor(address payable _buyer, address payable _seller){
        arbiter = payable(msg.sender);
        buyer = _buyer;
        seller = _seller;
        state = State.awate_payment;
    }

    function confirm_payment() onlyBuyer instate(State.awate_payment) public payable{
        state = State.awate_delivery;
    } 

    function confirm_delivery() onlyBuyer instate(State.awate_delivery) public payable{
        seller.call{value:(address(this).balance)};
        state = State.complete;
    }

    function return_Payment() onlySeller instate(State.complete) public payable{
        buyer.call{value:(address(this).balance)};
    }
}
