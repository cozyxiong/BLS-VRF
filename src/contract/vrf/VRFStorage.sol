// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IBLSApkRegistry} from "../../interface/IBLSApkRegistry.sol";

abstract contract VRFStorage {
    struct RequestStatus {
        bool isFulfilled;
        uint256[] randomWords;
    }
    address public nodeAddress;
    IBLSApkRegistry public blsRegistry;
    mapping(uint256 => RequestStatus) public requestMapping;
    uint256[] public requestIds;
    uint256 public lastRequestId;
}
