//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./ERC1155.sol";

contract Vault is ERC721Holder, ERC1155Holder{

    address internal owner_;
    MyToken token;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct NftOwner{
        address nftToken;
        uint256 nftId;
        address nftOwner;
        uint256 listPrice;
        address fractionalAddress;
        string fractionalTokenName;
        string fractionalTokenSymbol;
        uint256 fractionalTokenAmount;
        uint256 tokenTotalSupply;
        uint256 totalAmount;
        uint256 curatorFees;
    }

    mapping(uint256 => NftOwner) public nftData;

    event AddedNFT(address nftOwner, address nftToken, uint256 nftId, uint256 tokenId, uint256 tokenTokenSupply);
    event BoughtToken(address buyer, uint256 amount, uint256 Id);
    event Buyout(address newOwner, uint256 Id);

    constructor(address _tokenAddress) {
        owner_ = msg.sender;
        token =  MyToken(_tokenAddress);
    }

    function addNFT(address _nftToken, 
    uint256 _nftId, 
    string memory _fractionalTokenName,
    string memory _fractionalTokenSymbol,
    uint256 _tokenTotalSupply, 
    uint256 _listPrice) public 
    {
        // IERC721(_nftToken).setApprovalForAll(address(this), true);
        IERC721(_nftToken).safeTransferFrom(msg.sender, address(this), _nftId);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        token.mint(address(this), tokenId, _tokenTotalSupply, "");
        nftData[tokenId].nftToken = _nftToken;
        nftData[tokenId].nftId = _nftId;
        nftData[tokenId].fractionalTokenName = _fractionalTokenName;
        nftData[tokenId].fractionalTokenSymbol = _fractionalTokenSymbol;
        nftData[tokenId].nftOwner = msg.sender;
        nftData[tokenId].listPrice = _listPrice;
        nftData[tokenId].tokenTotalSupply = _tokenTotalSupply;
        emit AddedNFT(msg.sender, _nftToken, _nftId, tokenId, _tokenTotalSupply);
    }

    function buyToken(uint256 _tokenAmount, uint256 _tokenId) payable public
    {
        require(token.balanceOf(address(this), _tokenId) >= _tokenAmount, "Insufficent token balance");
        require(_tokenAmount * nftData[_tokenId].listPrice == msg.value, "Send the exact amount of ETH");
        token.safeTransferFrom(address(this), msg.sender, _tokenId, _tokenAmount, "");
        nftData[_tokenId].totalAmount = _tokenAmount * nftData[_tokenId].listPrice;
        emit BoughtToken(msg.sender, _tokenAmount, _tokenId);
    }

    function sellToken(uint256 _tokenId) public
    {
        
    }

    function buyout(uint256 _tokenId) public
    {
        require(nftData[_tokenId].tokenTotalSupply == token.balanceOf(msg.sender, _tokenId), "You do not have all the tokens!");
        token.burn(msg.sender, _tokenId, token.balanceOf(msg.sender, _tokenId));
        IERC721(nftData[_tokenId].nftToken).safeTransferFrom(address(this), msg.sender, nftData[_tokenId].nftId);
        emit Buyout(msg.sender, _tokenId);
    }

}