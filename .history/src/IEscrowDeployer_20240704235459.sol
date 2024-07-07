// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/s/token/ERC20/IERC20.sol";
interface IEscrowDeployer {
    struct EscrowParams {
        uint256 i_price;
        IERC20 i_token;
        address i_buyer;
        address i_seller;
        address i_arbiter;
        uint256 s_arbiterFee;
    }

    function parameters () external returns(
        uint256 s_price,
        IERC20 s_token,
        address s_buyer,
        address s_seller,
        address s_arbiter,
        uint256 s_arbiterFee
    );
}