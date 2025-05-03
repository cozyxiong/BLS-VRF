// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BN254} from "../../libraries/BN254.sol";

abstract interface BLSApkStorage {

    bytes32 internal constant ZERO_PK_HASH = hex"ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5";

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
        BN254.G1Point[] nonSignerPubKeysG1;
        BN254.G2Point apkG2;
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
    mapping(address => bool) public whitelist;
    address public vrfManager;
    ApkRecord[] public apkHistory;
    mapping(address => bytes32) public operatorToPubKeyHash;
    mapping(bytes32 => address) public pubKeyHashToOperator;
    mapping(address => BN254.G1Point) public operatorToPubKey;
    BN254.G1Point public apkG1;



}
