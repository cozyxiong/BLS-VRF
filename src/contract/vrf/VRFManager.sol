// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin-upgrades/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgrades/contracts/access/OwnableUpgradeable.sol";
import {VRFStorage} from "./VRFStorage.sol";
import {IVRFManager} from "../../interface/IVRFManager.sol";
import {IBLSApkRegistry} from "../../interface/IBLSApkRegistry.sol";

contract VRFManager is Initializable, OwnableUpgradeable, VRFStorage, IVRFManager {

    event RequestSent(
        uint256 requestId,
        uint256 numWords,
        address current
    );

    event FillRandomWords(
        uint256 requestId,
        uint256[] randomWords
    );

    modifier onlyWhiteList() {
        require(msg.sender == nodeAddress, "VRF.onlyWhiteList");
        _;
    }

    constructor(){
        _disableInitializers();
    }

    function initialize(address initialOwner, address _nodeAddress, address _blsRegistry) public initializer {
        __Ownable_init(initialOwner);
        nodeAddress = _nodeAddress;
        blsRegistry = IBLSApkRegistry(_blsRegistry);
    }

    function requestRandomWords(uint256 _requestId, uint256 _numWords) external onlyOwner {
        requestMapping[_requestId] = RequestStatus({
            isFulfilled: false,
            randomWords: new uint256[](0)
        });
        requestIds.push(_requestId);
        lastRequestId = _requestId;
        emit RequestSent(_requestId, _numWords, address(this));
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords, uint256 blockNumber, IBLSApkRegistry.SignatureCheckParams calldata params, bytes32 memory msgHash) external onlyWhiteList {
        IBLSApkRegistry.checkSignatures(blockNumber, params, msgHash);

        requestMapping[_requestId] = RequestStatus({
            isFulfilled: true,
            randomWords: _randomWords
        });
        emit FillRandomWords(_requestId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId) external view returns (bool isFulfilled, uint256[] memory randomWords) {
        return (requestMapping[_requestId].isFulfilled, requestMapping[_requestId].randomWords);
    }

    function setWhitelist(address _nodeAddress) external onlyOwner {
        nodeAddress = _nodeAddress;
    }
}
