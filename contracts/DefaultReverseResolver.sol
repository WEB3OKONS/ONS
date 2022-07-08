/**
 *Submitted for verification at Etherscan.io on 2020-01-30
*/

pragma solidity ^0.5.0;
import "./ONS.sol";


contract Resolver {
    function setName(bytes32 node, string memory name) public;
}

contract ReverseRegistrar {
    // namehash('addr.reverse')
    bytes32 public constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    ONS public ons;
    Resolver public defaultResolver;

    /**
     * @dev Constructor
     * @param onsAddr The address of the ONS registry.
     * @param resolverAddr The address of the default reverse resolver.
     */
    constructor(ONS onsAddr, Resolver resolverAddr) public {
        ons = onsAddr;
        defaultResolver = resolverAddr;

        // Assign ownership of the reverse record to our deployer
        ReverseRegistrar oldRegistrar = ReverseRegistrar(ons.owner(ADDR_REVERSE_NODE));
        if (address(oldRegistrar) != address(0x0)) {
            oldRegistrar.claim(msg.sender);
        }
    }
    
    /**
     * @dev Transfers ownership of the reverse ONS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in ONS.
     * @return The ONS node hash of the reverse record.
     */
    function claim(address owner) public returns (bytes32) {
        return claimWithResolver(owner, address(0x0));
    }

    /**
     * @dev Transfers ownership of the reverse ONS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in ONS.
     * @param resolver The address of the resolver to set; 0 to leave unchanged.
     * @return The ONS node hash of the reverse record.
     */
    function claimWithResolver(address owner, address resolver) public returns (bytes32) {
        bytes32 label = sha3HexAddress(msg.sender);
        bytes32 node = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));
        address currentOwner = ons.owner(node);

        // Update the resolver if required
        if (resolver != address(0x0) && resolver != ons.resolver(node)) {
            // Transfer the name to us first if it's not already
            if (currentOwner != address(this)) {
                ons.setSubnodeOwner(ADDR_REVERSE_NODE, label, address(this));
                currentOwner = address(this);
            }
            ons.setResolver(node, resolver);
        }

        // Update the owner if required
        if (currentOwner != owner) {
            ons.setSubnodeOwner(ADDR_REVERSE_NODE, label, owner);
        }

        return node;
    }

    /**
     * @dev Sets the `name()` record for the reverse ONS record associated with
     * the calling account. First updates the resolver to the default reverse
     * resolver if necessary.
     * @param name The name to set for this address.
     * @return The ONS node hash of the reverse record.
     */
    function setName(string memory name) public returns (bytes32) {
        bytes32 node = claimWithResolver(address(this), address(defaultResolver));
        defaultResolver.setName(node, name);
        return node;
    }

    /**
     * @dev Returns the node hash for a given account's reverse records.
     * @param addr The address to hash
     * @return The ONS node hash.
     */
    function node(address addr) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr)));
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        addr;
        ret; // Stop warning us about unused variables
        assembly {
            let lookup := 0x3031323334353637383961626364656600000000000000000000000000000000

            for { let i := 40 } gt(i, 0) { } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }
}

// File: @onsdomains/resolver/contracts/DefaultReverseResolver.sol

pragma solidity >=0.4.25;



/**
 * @dev Provides a default implementation of a resolver for reverse records,
 * which permits only the owner to update it.
 */
contract DefaultReverseResolver {
    // namehash('addr.reverse')
    bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    ONS public ons;
    mapping (bytes32 => string) public name;

    /**
     * @dev Only permits calls by the reverse registrar.
     * @param node The node permission is required for.
     */
    modifier onlyOwner(bytes32 node) {
        require(msg.sender == ons.owner(node));
        _;
    }

    /**
     * @dev Constructor
     * @param onsAddr The address of the ONS registry.
     */
    constructor(ONS onsAddr) public {
        ons = onsAddr;

        // Assign ownership of the reverse record to our deployer
        ReverseRegistrar registrar = ReverseRegistrar(ons.owner(ADDR_REVERSE_NODE));
        if (address(registrar) != address(0x0)) {
            registrar.claim(msg.sender);
        }
    }

    /**
     * @dev Sets the name for a node.
     * @param node The node to update.
     * @param _name The name to set.
     */
    function setName(bytes32 node, string memory _name) public onlyOwner(node) {
        name[node] = _name;
    }
}