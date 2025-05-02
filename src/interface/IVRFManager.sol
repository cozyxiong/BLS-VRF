// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IVRFManager {
    function requestRandomWords(uint256 _requestId, uint256 _numWords) external;
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external;
    function getRequestStatus(uint256 _requestId) external view returns (bool isFulfilled, uint256[] memory randomWords);
    function setWhitelist(address _nodeAddress) external;
}
