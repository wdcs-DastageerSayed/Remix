//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract accessControl{

    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);

    //roles => address => bool
    mapping(bytes32 => mapping(address => bool)) public roles;

    //0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    //0x6270edb7c868f86fda4adedba75108201087268ea345934db8bad688e1feb91b
    bytes32 private constant OWNER = keccak256(abi.encodePacked("OWNER"));

    modifier onlyRole(bytes32 _role){
        require( roles[_role][msg.sender], "Not Authorized");
        _;
    }

    constructor(){
        _grantRole(ADMIN, msg.sender);
    }

    function _grantRole(bytes32 _role, address _account) internal {
        roles[_role][_account] = true; //mapping
        emit GrantRole(_role, _account);
    }

    function grantRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        _grantRole(_role, _account);
    }

    function revokeRole(bytes32 _role, address _account) external onlyRole(ADMIN){
        roles[_role][_account] = false;
        emit RevokeRole(_role, _account);
    }
}