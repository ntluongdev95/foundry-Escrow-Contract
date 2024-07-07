// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EscrowFactory is IEscrowDeployer {
    erFee;
    }

    function parameters() external view override returns (uint256, address, address, address, address, uint256) {
        return (s_escrow, s_token, s_buyer, s_seller, s_arbiter, s_arbiterFee);
    }
}