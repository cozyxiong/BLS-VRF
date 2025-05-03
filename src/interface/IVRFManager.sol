// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IBLSApkRegistry.sol";

interface IVRFManager {
    function requestRandomWords(uint256 _requestId, uint256 _numWords) external;
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords, uint256 blockNumber, IBLSApkRegistry.SignatureCheckParams calldata params, bytes32 msgHash) external;
    function getRequestStatus(uint256 _requestId) external view returns (bool isFulfilled, uint256[] memory randomWords);
    function setWhitelist(address _nodeAddress) external;
}
