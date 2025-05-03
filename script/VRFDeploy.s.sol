// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Vm.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Script, console} from "forge-std/Script.sol";

import {EmptyContract} from "../src/utils/EmptyContract.sol";
import "../src/contract/bls/BLSApkRegistry.sol";
import {VRFManager} from "../src/contract/vrf/VRFManager.sol";
import {VRFFactory} from "../src/contract/VRFFactory.sol";

contract VRFDeployScript is Script {

    EmptyContract public emptyContract;
    BLSApkRegistry public blsApkRegistry;
    BLSApkRegistry public blsApkRegistryImplementation;
    ProxyAdmin public blsApkRegistryProxyAdmin;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerAddress);
        vm.startBroadcast();

        emptyContract = new EmptyContract();
        TransparentUpgradeableProxy proxyBLSApkRegistry = new TransparentUpgradeableProxy(address(emptyContract), deployerAddress, "");
        blsApkRegistry = BLSApkRegistry(address(proxyBLSApkRegistry));
        blsApkRegistryImplementation = new BLSApkRegistry();
        blsApkRegistryProxyAdmin = ProxyAdmin(getProxyAdminAddress(address(proxyBLSApkRegistry)));
        blsApkRegistryProxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(address(blsApkRegistry)),
            address(blsApkRegistryImplementation),
            abi.encodeWithSelector(
                BLSApkRegistry.initialize.selector,
                deployerAddress,
                deployerAddress,
                deployerAddress
            )
        );

        VRFManager vrfImplementation = new VRFManager();
        VRFFactory vrfFactory = new VRFFactory();
        address proxyVrf = vrfFactory.createProxy(address(vrfImplementation));

        console.log("bls proxy contract deployed at:", address(blsApkRegistry));
        console.log("vrf logic contract deployed at:", address(vrfImplementation));
        console.log("vrf proxy contract deployed at:", address(proxyVrf));
        console.log("vrf factory contract deployed at:", address(vrfFactory));
    }

    function getProxyAdminAddress(address proxy) internal view returns (address) {
        address CHEATCODE_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
        Vm vm = Vm(CHEATCODE_ADDRESS);

        bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
        return address(uint160(uint256(adminSlot)));
    }
}
