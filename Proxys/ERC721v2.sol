// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTv1 is Initializable, ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor

    address tokenAddress;
    uint256 cost;

    mapping(address => bool)Lock;

    modifier addressLocked() {
        require(Lock[msg.sender] = true, "Address Locked");
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address _erc20tokenAddress, uint256 _cost) initializer public {
        tokenAddress = _erc20tokenAddress;
        cost = _cost; 
        __ERC721_init("NFTv1", "v1");
        __ERC721Burnable_init();
        __Ownable_init();
    }

    function setLock(address _userAddress) public onlyOwner{
        Lock[_userAddress] = true;
    }

    function mint(uint256 _amount) external addressLocked {
        address sender = _msgSender();
        require(_amount * cost <= IERC20(tokenAddress).balanceOf(sender), "Insufficent Amount");
        IERC20(tokenAddress).transferFrom(sender, address(this), _amount * cost);
        _safeMint(sender, _amount);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}
