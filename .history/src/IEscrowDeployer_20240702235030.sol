// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IEscrowDeployer {
    function deployEscrow(
        uint256 price,
        address token,
        address buyer,
        address seller,
        address arbiter,
        uint256 arbiterFee
    ) external returns (address);
}