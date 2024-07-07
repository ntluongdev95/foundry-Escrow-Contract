  // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract TestEscrow is Test{
    
    ERC20Mock token;
    EscrowFactory factory;
    uint256 public constant PRICE = 1e18;
    address public BUYER;
    address public SELLER;
    address public ARBITER;
    uint256 public constant ARBITER_FEE = 1e16;
    function setup() external{

    }

}
