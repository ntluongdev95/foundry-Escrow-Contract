 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/test/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {EscrowFactory} from "../../src/EscrowFactory.sol";
import {DeployEscrowFactory} from "../../script/DeployEscrowFactory.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestEscrowFactory is Test {
    IERC20 token;
    EscrowFactory factory;
    bytes32 public constant SALT1 = bytes32(uint256(keccak256(abi.encodePacked("test"))));
    bytes32 public constant SALT2 = bytes32(uint256(keccak256(abi.encodePacked("test2"))));
    uint256 public constant PRICE = 1e18;
    address public constant BUYER = makeAddr("buyer");
    address public constant SELLER =makeAddr("seller");
    address public constant ARBITER = makeAddr("arbiter");
    uint256 public constant ARBITER_FEE = 1e16;

   function setUp () public {
         ERC20Mock token_add = new ERC20Mock();
         token = IERC20(token_add);
         DeployEscrowFactory deployed = new DeployEscrowFactory();
         factory = deployed.run();
   }
   function test_ComputedAddressEqualsDeployedAddress() public{
      address 
   }
}