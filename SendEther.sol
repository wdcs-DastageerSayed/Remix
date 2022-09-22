//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract sendETH{

    function Transfer(address _to) public payable { //gas: 35956 tx: 31266
        payable(_to).transfer(msg.value);
    }

    function Call(address _to) public payable returns(bool){ //gas:28645 tx:24908
       (bool success,) = _to.call{value: msg.value}("");
       return success;
    }

    function Send(address _to) public payable returns(bool){ //gas:36222 tx:31497
        bool success = payable(_to).send(msg.value);
        return success;
    }

    function Assemble(address _to, uint256 _amount) public payable{ //gas:36327 tx:31588
        bool success ;
        assembly{
            success := call(gas(), _to, _amount, 0, 0, 0, 0)
        }
    }
}