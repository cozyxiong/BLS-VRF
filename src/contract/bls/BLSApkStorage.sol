// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BN254} from "../../libraries/BN254.sol";

abstract interface BLSApkStorage {

    struct PubKeyRegistrationParams {
        BN254.G1Point pubKeyG1;
        BN254.G2Point pubKeyG2;
        BN254.G1Point sigma;
    }
    struct StakeTotals {
        uint256 totalEthStake;
        uint256 totalTokenStake;
    }
    struct SignatureCheckParams {
        BN254.G2Point[] nonSignerPubKeys;
        BN254.G1Point apkG1;
        BN254.G1Point sigma;
        uint256 totalEthStake;
        uint256 totalTokenStake;
    }
    struct ApkRecord {
        bytes24 apkHash;
        uint32 updateBlockNumber;
        uint32 nextUpdateBlockNumber;
    }
    address public whitelistManager;
    address public vrfManager;
    ApkRecord[] public apkHistory;


}
