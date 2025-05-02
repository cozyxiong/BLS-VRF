// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../contract/bls/BLSApkStorage.sol";

interface IBLSApkRegistry is BLSApkStorage {
    function updateWhiteList(address operator, bool isAdd) external;
    function registerPubKey(address operator, PubKeyRegistrationParams calldata params, bytes32 memory msgHash) external returns (bytes32);
    function getRegisteredPubKey(address operator) external view returns (BN254.G2Point memory, bytes32);
    function registerOperator(address operator) external;
    function deregisterOperator(address operator) external;
    function checkSignatures(uint256 blockNumber, SignatureCheckParams calldata params, bytes32 memory msgHash) external returns (StakeTotals memory, bytes32);
}
