// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin-upgrades/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin-upgrades/contracts/proxy/utils/Initializable.sol";
import {BLSApkStorage} from "./BLSApkStorage.sol";

contract BLSApkRegistry is Initializable, OwnableUpgradeable, BLSApkStorage {

    modifier onlyWhitelistManager() {
        require(msg.sender == whitelistManager, "BLSApkRegistry.onlyWhitelistManager");
        _;
    }

    modifier onlyVrfManager() {
        require(msg.sender == vrfManager, "BLSApkRegistry.onlyVrfManager");
        _;
    }

    constructor(){
        _disableInitializers();
    }

    function Initialize(address _initialOwner, address _whiteListManager, address _vrfManager) external initializer {
        __Ownable_init(_initialOwner);
        whitelistManager = _whiteListManager;
        vrfManager = _vrfManager;
        _initializeApk();
    }

    function _initializeApk() internal {
        require(apkHistory.length == 0, "BLSApkRegistry.initializeApk: apk already exits");
        apkHistory.push(ApkRecord({
            apkHash: bytes24(0),
            updateBlockNumber: uint32(block.number),
            nextUpdateBlockNumber: 0
        }));
    }
}
