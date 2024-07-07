// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/s/token/ERC20/IERC20.sol";

contract EscrowFactory is IEscrowDeployer {
    function createNewEscrow (
        uint256 _price,
        address _token,
        address _buyer,
        address _seller,
        address _arbiter,
        uint256 _arbiterFee
    ) external returns (address escrow)
    {
         if (address(token) == address(0)) revert Escrow__TokenZeroAddress();
        if (buyer == address(0)) revert Escrow__BuyerZeroAddress();
        if (seller == address(0)) revert Escrow__SellerZeroAddress();
        if (arbiterFee >= price) revert Escrow__FeeExceedsPrice(price, arbiterFee);
        if (token.balanceOf(address(this)) < price) revert Escrow__MustDeployWithTokenBalance();


    }


}