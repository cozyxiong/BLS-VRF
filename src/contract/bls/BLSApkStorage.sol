// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BN254} from "../../libraries/BN254.sol";

abstract contract BLSApkStorage {

    bytes32 internal constant ZERO_PK_HASH = hex"ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5";
    bytes32 public constant PUBKEY_REGISTRATION_TYPEHASH = keccak256("BN254PubkeyRegistration(address operator)");

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
