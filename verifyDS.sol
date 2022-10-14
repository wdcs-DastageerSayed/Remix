//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract verifyDS{

    // _signer: given by ecrecover
    //_sig: It is not the original signature but a pointer to the signature
    // function verify(address _signer, string memory _message, bytes memory _sig)external pure returns(bool){

    //     bytes32 messageHash = getMessageHash(_message);
    //     bytes32 ethSignedMessageHash = getETHSignedMessageHash(messageHash);

    //     return recover(ethSignedMessageHash, _sig) == _signer;
    // }

    function getMessageHash(string memory _message) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_message));
    }

    function setDomain(string memory name, string memory version) public pure returns(bytes32){
        return keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            5,
           "0xE3fc8FF80cA2F67687924e16370345CfA0cEadF6"
        ));
    }

    // function getETHSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32){
    //     return keccak256(abi.encodePacked(_messageHash));
    // }

    function recover(bytes32 domain_separator,bytes32 _getSignedMessageHash, bytes memory _sig, address holder, address spender, uint256 nonce, uint256 expiry, bool allowed)public pure returns(address){
        bytes32 digest =
            keccak256(abi.encodePacked(
                "\x19\x01",
                domain_separator,
                keccak256(abi.encode(_getSignedMessageHash, holder,spender,nonce,expiry,allowed))));
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
         return ecrecover(digest, v, r, s);
    }

    function _split(bytes memory _sig) public pure returns(bytes32 r, bytes32 s, uint8 v){
        require(_sig.length == 65, "Invalid signature length");
        assembly{
            //first 32 bytes is data
             r := mload(add(_sig, 32))
             s := mload(add(_sig, 64))
             v := byte(0, mload(add(_sig, 96))) // bcoz we need only 1st byte  
        }
        //does not require return bcoz solidity takes it implicitly
    }


}