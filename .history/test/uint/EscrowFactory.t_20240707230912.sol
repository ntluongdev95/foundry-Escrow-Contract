    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {EscrowFactory} from "../../src/EscrowFactory.sol";
import {DeployEscrowFactory} from "../../script/DeployEscrowFactory.s.sol";
import {Escrow} from "../../src/Escrow.sol";
import{ERC20MockFailedTransfer} from "../../test/mock/ERC20MockFailedTransfer.t.sol";

contract TestEscrowFactory is Test {
    ERC20Mock token;
    EscrowFactory factory;
    bytes32 public constant SALT2 = bytes32(uint256(keccak256(abi.encodePacked("test2"))));
    uint256 public constant PRICE = 1e18;
    address public BUYER;
    address public SELLER;
    address public ARBITER;
    uint256 public constant ARBITER_FEE = 1e16;

    function setUp() public {
        token = new ERC20Mock();
        BUYER = makeAddr("buyer");
        SELLER = makeAddr("seller");
        ARBITER = makeAddr("arbiter");
        DeployEscrowFactory deployed = new DeployEscrowFactory();
        factory = deployed.run();
    }

    function test_ComputedAddressEqualsDeployedAddress() public {
        vm.startPrank(BUYER);
        token.mint(BUYER, PRICE * 2);
        token.approve(address(factory), PRICE * 2);
        console.log((token).balanceOf(BUYER));
        console.log((token).balanceOf(address(factory)));
        address computedAddress = factory.createNewEscrow(
            PRICE,
            token,
            BUYER,
            SELLER,
            ARBITER,
            ARBITER_FEE
        );
        vm.stopPrank();
        assertEq(Escrow(computedAddress).getPrice(), PRICE);
    }

     function test_RevertsIfTokenTxFails() public {
        ERC20MockFailedTransfer failedTxToken = new ERC20MockFailedTransfer();
        uint256 amount = PRICE - 1e16;
        failedTxToken.mint(BUYER, amount);
        failedTxToken.approve(address(factory), PRICE);
        vm.startPrank(BUYER);
        vm.expectRevert();
        factory.createNewEscrow(
            PRICE,
            failedTxToken,
            BUYER,
            SELLER,
            ARBITER,
            ARBITER_FEE
        );
     }

    
}
