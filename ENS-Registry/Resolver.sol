//SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 <0.9.0;

import "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import "https://github.com/ensdomains/ens-contracts/blob/master/contracts/resolvers/profiles/ABIResolver.sol";
import "https://github.com/ensdomains/ens-contracts/blob/master/contracts/resolvers/profiles/AddrResolver.sol";
import "https://github.com/ensdomains/ens-contracts/blob/master/contracts/resolvers/profiles/ContentHashResolver.sol";
import "https://github.com/ensdomains/ens-contracts/blob/master/contracts/resolvers/profiles/DNSResolver.sol";
import "https://github.com/ensdomains/ens-contracts/blob/master/contracts/resolvers/profiles/InterfaceResolver.sol";
import "https://github.com/ensdomains/ens-contracts/blob/master/contracts/resolvers/profiles/NameResolver.sol";
import "https://github.com/ensdomains/ens-contracts/blob/master/contracts/resolvers/profiles/PubkeyResolver.sol";
import "https://github.com/ensdomains/ens-contracts/blob/master/contracts/resolvers/profiles/TextResolver.sol";
import "https://github.com/ensdomains/ens-contracts/blob/master/contracts/resolvers/Multicallable.sol";

interface INameWrapper {
    function ownerOf(uint256 id) external view returns (address);
}

/**
 * A simple resolver anyone can use; only allows the owner of a node to set its
 * address.
 */
contract PublicResolver is
    Multicallable,
    ABIResolver,
    AddrResolver,
    ContentHashResolver,
    DNSResolver,
    InterfaceResolver,
    NameResolver,
    PubkeyResolver,
    TextResolver
{
    ENS immutable ens;
    INameWrapper immutable nameWrapper;
    address immutable trustedETHController;
    address immutable trustedReverseRegistrar;

    /**
     * A mapping of operators. An address that is authorised for an address
     * may make any changes to the name that the owner could, but may not update
     * the set of authorisations.
     * (owner, operator) => approved
     */
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Logged when an operator is added or removed.
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    constructor(
        ENS _ens,
        INameWrapper wrapperAddress,
        address _trustedETHController,
        address _trustedReverseRegistrar
    ) {
        ens = _ens;
        nameWrapper = wrapperAddress;
        trustedETHController = _trustedETHController;
        trustedReverseRegistrar = _trustedReverseRegistrar;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) external {
        require(
            msg.sender != operator,
            "ERC1155: setting approval status for self"
        );

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator)
        public
        view
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    function isAuthorised(bytes32 node) internal view override returns (bool) {
        if (
            msg.sender == trustedETHController ||
            msg.sender == trustedReverseRegistrar
        ) {
            return true;
        }
        address owner = ens.owner(node);
        if (owner == address(nameWrapper)) {
            owner = nameWrapper.ownerOf(uint256(node));
        }
        return owner == msg.sender || isApprovedForAll(owner, msg.sender);
    }

    function supportsInterface(bytes4 interfaceID)
        public
        view
        override(
            Multicallable,
            ABIResolver,
            AddrResolver,
            ContentHashResolver,
            DNSResolver,
            InterfaceResolver,
            NameResolver,
            PubkeyResolver,
            TextResolver
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceID);
    }
}