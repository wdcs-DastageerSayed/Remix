// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract MyToken is ERC1155, Ownable, ERC1155Burnable {

    address vaultAddress;

    constructor() ERC1155("https://ipfs.io/ipfs/QmQYcU55uhKFuXQXkooVcJLVADnjX6AatKTEpTMayyDBsP/{id}.json") {
    }

    modifier onlyVault{
        require(msg.sender == vaultAddress, "Only Vault can mint new Tokens!");
        _;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setVaultAddress(address _vaultAddress) public {
        vaultAddress = _vaultAddress;
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        // onlyVault
    {
        _mint(account, id, amount, data);
    }
}

