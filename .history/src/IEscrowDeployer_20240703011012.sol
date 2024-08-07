// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IEscrowDeployer {
    struct EscrowParams {
        uint256 s_price;
        address s_token;
        address s_buyer;
        address s_seller;
        address s_arbiter;
        uint256 s_arbiterFee;
    }

    function parameters () external returns(
        uint256 s_price,
        address s_token,
        address s_buyer,
        address s_seller,
        address s_arbiter,
        uint256 s_arbiterFee
    );
}