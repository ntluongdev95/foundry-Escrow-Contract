// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IEscrowDeployer {
    struct EscrowParams {
        uint256 price;
        address token;
        address buyer;
        address seller;
        address arbiter;
        uint256 arbiterFee;
    }

    function parameters () external
}