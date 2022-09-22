//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract NFT is ERC721, ERC2981, ERC721Burnable, Ownable  {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    string public baseTokenURI;

    constructor() ERC721("SAGA", "SAGA") {
        baseTokenURI = "";

        // set default royalty information.
        // _setDefaultRoyalty(msg.sender, _feeNumerator);
    }

    function supportsInterface(bytes4 interfaceId)
        public view virtual override(ERC721, ERC2981)
        returns (bool) 
    {
      return super.supportsInterface(interfaceId);
    }

    function safeMint(address to, uint96 _feeNumerator) public onlyOwner  {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        // set Royalty information for token ID
        _setTokenRoyalty(tokenId, msg.sender, _feeNumerator);
    }

    function burn(uint _tokenId) public override {
        _burn(_tokenId);
        _resetTokenRoyalty(_tokenId);
    }

    function _baseURI() internal view override returns(string memory) {
        return baseTokenURI;
    }

    function setbaseTokenURI(string memory _uri) public {
        baseTokenURI = _uri;
    } 

    // function royaltyDetails(uint _tokenId, uint _salePrice) public view returns (address receiver, uint royaltyAmount) {
    //     (receiver, royaltyAmount) = royaltyInfo(_tokenId, _salePrice);
    //     return (receiver, royaltyAmount);
    // }

}