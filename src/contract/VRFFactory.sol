// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/proxy/Clones.sol";
import {VRFManager} from "./vrf/VRFManager.sol";

contract VRFFactory {

    event ProxyCreated(address mintProxyAddress);

    function createProxy(address implementation, address nodeAddress, address blsRegistry) external returns (address) {
        address mintProxyAddress = Clones.clone(implementation);
        VRFManager(mintProxyAddress).initialize(msg.sender, nodeAddress, blsRegistry);
        emit ProxyCreated(mintProxyAddress);
        return mintProxyAddress;
    }
}
