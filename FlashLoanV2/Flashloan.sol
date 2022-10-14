pragma solidity ^0.6.6;

import "./FlashLoanReceiverBase.sol";
import "./ILendingPoolAddressesProvider.sol";
import "./ILendingPool.sol";
import "hardhat/console.sol";

contract Flashloan is FlashLoanReceiverBase {

    constructor(address _addressProvider) FlashLoanReceiverBase(_addressProvider) public {}

    

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    )
        external
        override
    {
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance");
        uint totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    
    function flashloan(address _asset) public onlyOwner {
        bytes memory data = "";
        uint amount = 0.01 ether;
        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        // console.log(lendingPool);
        lendingPool.flashLoan(address(this), _asset, amount, data);
    }
}

//_addressProvider (Kovan): 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5
//DAI: 0xa799c2b72e25dB4c8Ea8f9D9e7690fac859c5cee


