/**
 *Submitted for verification at Etherscan.io on 2020-01-30
*/
pragma solidity ^0.5.0;
import "./ONS.sol";
import "./Ownable.sol";
import "./Controllable.sol";


contract Root is Ownable, Controllable {
    bytes32 constant private ROOT_NODE = bytes32(0);

    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));

    event TLDLocked(bytes32 indexed label);

    ONS public ons;
    mapping(bytes32=>bool) public locked;

    constructor(ONS _ons) public {
        ons = _ons;
    }

    function setSubnodeOwner(bytes32 label, address owner) external onlyController {
        require(!locked[label]);
        ons.setSubnodeOwner(ROOT_NODE, label, owner);
    }

    function setResolver(address resolver) external onlyOwner {
        ons.setResolver(ROOT_NODE, resolver);
    }

    function lock(bytes32 label) external onlyOwner {
        emit TLDLocked(label);
        locked[label] = true;
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return interfaceID == INTERFACE_META_ID;
    }
}