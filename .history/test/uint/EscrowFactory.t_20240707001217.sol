 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/test/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {EscrowFactory} from "../../src/EscrowFactory.sol";

contract TestEscrowFactory is Test {
    ERC20Mock token;
    EscrowFactory factory;
   function setUp () public {
         token = new ERC20Mock();
         DeployEscrowFactory script = new DeployEscrowFactory();

   }
}