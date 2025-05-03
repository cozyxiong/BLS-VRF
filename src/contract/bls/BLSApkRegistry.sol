// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin-upgrades/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin-upgrades/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

import "../../libraries/BN254.sol";
import "../../interface/IBLSApkRegistry.sol";
import "./BLSApkStorage.sol";

contract BLSApkRegistry is Initializable, OwnableUpgradeable, EIP712, BLSApkStorage, IBLSApkRegistry {

    using BN254 for BN254.G1Point;

    uint256 internal constant PAIRING_EQUALITY_CHECK_GAS = 120000;

    event PubKeyRegistration(
        address operator,
        BN254.G1Point pubKeyG1,
        BN254.G2Point pubKeyG2
    );

    event SignerAdded(
        address operator,
        bytes32 pubKeyHash
    );

    event SignerRemoved(
        address operator,
        bytes32 pubKeyHash
    );

    modifier onlyWhitelistManager() {
        require(msg.sender == whitelistManager, "BLSApkRegistry.onlyWhitelistManager");
        _;
    }

    modifier onlyVrfManager() {
        require(msg.sender == vrfManager, "BLSApkRegistry.onlyVrfManager");
        _;
    }

    constructor() EIP712("BLSApkRegistry", "v0.0.1") {
        _disableInitializers();
    }

    function initialize(address _initialOwner, address _whiteListManager, address _vrfManager) external initializer {
        __Ownable_init(_initialOwner);
        whitelistManager = _whiteListManager;
        vrfManager = _vrfManager;
        _initializeApk();
    }

    function updateWhitelist(address operator, bool isAdd) external onlyWhitelistManager {
        require(operator == address(0), "BLSApkRegistry.updateWhitelist: operator address is zero");
        whitelist[operator] = isAdd;
    }

    function registerPubKey(address operator, PubKeyRegistrationParams calldata params, bytes32 memory msgHash) external returns (bytes32) {
        require(whitelist[msg.sender], "BLSApkRegistry.registerPubKey: this address not authorized to register public key");

        byte32 pubKeyG1Hash = BN254.hashG1Point(params.pubKeyG1);
        require(pubKeyG1Hash != ZERO_PK_HASH, "BLSApkRegistry.registerPubKey: this public key hash is zero");
        require(operatorToPubKeyHash[operator] == bytes32(0), "BLSApkRegistry.registerPubKey: this operator already register public key");
        require(pubKeyHashToOperator[pubKeyG1Hash] == address(0), "BLSApkRegistry.registerPubKey: this public key hash already registered");

        uint256 gamma = uint256(
            keccak256(
                abi.encodePacked(
                    msgHash,
                    params.pubKeyG1.X,
                    params.pubKeyG1.Y,
                    params.pubKeyG2.X,
                    params.pubKeyG2.Y,
                    params.sigma.X,
                    params.sigma.Y
                )
            )
        ) % BN254.FR_MODULUS;

        require(
            BN254.pairing(
                params.sigma.plus(params.pubKeyG1.scalar_mul(gamma)),
                BN254.negGeneratorG2(),
                BN254.hashToG1(msgHash).plus(BN254.generatorG1().scalar_mul(gamma)),
                params.pubKeyG2
            ),
            "BLSApkRegistry.registerPubKey: signature is wrong or G1 and G2 public key not match"
        );

        operatorToPubKeyHash[operator] = pubKeyG1Hash;
        pubKeyHashToOperator[pubKeyG1Hash] = operator;
        operatorToPubKey[operator] = params.pubKeyG1;
        emit PubKeyRegistration(operator, params.pubKeyG1, params.pubKeyG2);

        return pubKeyG1Hash;
    }

    function getRegisteredPubKey(address operator) external view returns (BN254.G1Point memory, bytes32) {
        BN254.G1Point memory pubKeyG1 = operatorToPubKey[operator];
        bytes32 pubKeyG1Hash = operatorToPubKeyHash[operator];
        require(pubKeyG1Hash != bytes32(0), "BLSApkRegistry.getRegisteredPubKey: operator is not registered");

        return (pubKeyG1, pubKeyG1Hash);
    }

    function addSigner(address operator) public onlyVrfManager {
        (BN254.G1Point memory pubKeyG1,) = getRegisteredPubKey(operator);
        _updateApk(pubKeyG1);
        emit SignerAdded(operator, operatorToPubKeyHash[operator]);
    }

    function removeSigner(address operator) public onlyVrfManager {
        (BN254.G1Point memory pubKeyG1,) = getRegisteredPubKey(operator);
        _updateApk(pubKeyG1.negate());
        emit SignerRemoved(operator, operatorToPubKeyHash[operator]);
    }

    function _updateApk(BN254.G1Point memory pubKeyG1) internal {
        uint256 historyLength = apkHistory.length;
        require(historyLength != 0, "BLSApkRegistry._updateApk: apk not exists");

        apkG1 = apkG1.plus(pubKeyG1);
        bytes24 apkG1Hash = bytes24(BN254.hashG1Point(apkG1));

        ApkRecord storage lastRecord = apkHistory[historyLength - 1];
        if (lastRecord.updateBlockNumber == uint32(block.number)) {
            lastRecord.apkHash = apkG1Hash;
        } else {
            lastRecord.nextUpdateBlockNumber = uint32(block.number);
            apkHistory.push(ApkRecord({
                apkHash: apkG1Hash,
                updateBlockNumber: uint32(block.number),
                nextUpdateBlockNumber: 0
            }));
        }
    }

    function checkSignature(uint256 blockNumber, SignatureCheckParams calldata params, bytes32 memory msgHash) external returns (StakeTotals memory, bytes32) {
        require(blockNumber < uint32(block.number), "BLSApkRegistry.checkSignature: invalid block number");

        uint256 nonSignerPubKeyLength = params.nonSignerPubKeysG1.length;
        bytes32[] memory nonSignerPubKeyHash;
        BN254.G1Point memory signerApkG1 = BN254.G1Point(0, 0);
        if(nonSignerPubKeyLength > 0) {
            nonSignerPubKeyHash = new bytes32[](nonSignerPubKeyLength);
            for(uint256 i = 0; i < nonSignerPubKeyLength; i++) {
                nonSignerPubKeyHash[i] = params.nonSignerPubKeysG1[i].hashG1Point();
                signerApkG1 = apkG1.plus(params.nonSignerPubKeysG1[i].negate());
            }
        } else {
            signerApkG1 = apkG1;
        }

        uint256 gamma = uint256(
            keccak256(
                abi.encodePacked(
                    msgHash,
                    apkG1.X,
                    apkG1.Y,
                    params.apkG2.X[0],
                    params.apkG2.X[1],
                    params.apkG2.Y[0],
                    params.apkG2.Y[1],
                    params.sigma.X,
                    params.sigma.Y
                )
            )
        ) % BN254.FR_MODULUS;

        require(
            BN254.safePairing(
                params.sigma.plus(apkG1.scalar_mul(gamma)),
                BN254.negGeneratorG2(),
                BN254.hashToG1(msgHash).plus(BN254.generatorG1().scalar_mul(gamma)),
                params.apkG2,
                PAIRING_EQUALITY_CHECK_GAS
            ),
            "BLSSignatureChecker.checkSignatures: signature is invalid or apkG1 and apkG2 not matched"
        );

        bytes32 nonSignerRecordHash = keccak256(abi.encodePacked(blockNumber, nonSignerPubKeyHash));
        StakeTotals memory stakeRecord = StakeTotals({totalEthStake: params.totalEthStake, totalTokenStake: params.totalTokenStake});
        return (nonSignerRecordHash, stakeRecord);
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
