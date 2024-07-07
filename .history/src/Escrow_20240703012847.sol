// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IEscrowDeployer} from "./IEscrowDeployer.sol";

contract Escrow {

    //err

    uint256 private immutable s_price;
    IERC20 private immutable s_token;
    address private immutable s_buyer;
    address private immutable s_seller;
    address private immutable s_arbiter;
    uint256 private immutable s_arbiterFee;

    constructor (){
       ( s_price, s_token, s_buyer, s_seller, s_arbiter, s_arbiterFee) = IEscrowDeployer(msg.sender).parameters();


    }


   
}
