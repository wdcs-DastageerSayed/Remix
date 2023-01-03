//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract verifyDS{

    // _signer: given by ecrecover
    //_sig: It is not the original signature but a pointer to the signature
    function verify(address _signer, string memory _message, bytes memory _sig)external pure returns(bool){

        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getETHSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;

    }

    function getMessageHash(string memory _message) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_message));
    }

    function getETHSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_messageHash));
    }

    function recover(bytes32 _getSignedMessageHash, bytes memory _sig)public pure returns(address){
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
         return ecrecover(_getSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v){
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