// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EscrowFactory is IEscrowDeployer {
    address private immutable s_escrow;
    address private immutable s_token;
    address private immutable s_buyer;
    address private immutable s_seller;
    address private immutable s_arbiter;
    uint256 private immutable s_arbiterFee;

    constructor(address escrow, address token, address buyer, address seller, address arbiter, uint256 arbiterFee) {
        s_escrow = escrow;
        s_token = token;
        s_buyer = buyer;
        s_seller = seller;
        s_arbiter = arbiter;
        s_arbiterFee = arbiterFee;
    }

    function parameters() external view override returns (uint256, address, address, address, address, uint256) {
        return (s_escrow, s_token, s_buyer, s_seller, s_arbiter, s_arbiterFee);
    }
}