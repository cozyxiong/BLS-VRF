// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../libraries/BN254.sol";

interface IBLSApkRegistry{

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

    function updateWhitelist(address operator, bool isAdd) external;
    function getPubKeyRegMessageHash(address operator) external view returns (BN254.G1Point memory);
    function registerPubKey(address operator, PubKeyRegistrationParams calldata params, BN254.G1Point memory msgHash) external returns (bytes32);
    function getRegisteredPubKey(address operator) external view returns (BN254.G1Point memory, bytes32);
    function addSigner(address operator) external;
    function removeSigner(address operator) external;
    function checkSignature(uint256 blockNumber, SignatureCheckParams calldata params, bytes32 msgHash) external view returns (StakeTotals memory, bytes32);
}
