    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {EscrowFactory} from "../../src/EscrowFactory.sol";
import {DeployEscrowFactory} from "../../script/DeployEscrowFactory.s.sol";
import {Escrow} from "../../src/Escrow.sol";
import {ERC20MockFailedTransfer} from "../../test/mock/ERC20MockFailedTransfer.t.sol";

contract TestEscrowFactory is Test {
    ERC20Mock token;
    EscrowFactory factory;
    uint256 public constant PRICE = 1e18;
    address public BUYER;
    address public SELLER;
    address public ARBITER;
    uint256 public constant ARBITER_FEE = 1e16;

    event EscrowCreated(address indexed escrowAddress, address indexed buyer, address indexed seller, address arbiter);

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
        address computedAddress = factory.createNewEscrow(PRICE, token, BUYER, SELLER, ARBITER, ARBITER_FEE);
        vm.stopPrank();
        assertEq(Escrow(computedAddress).getPrice(), PRICE);
    }

    function testRevertIfFeeGreaterThanPrice() public {
        vm.startPrank(BUYER);
         token.mint(BUYER, PRICE );
        token.approve(address(factory), PRICE );
        uint256 arbiterFee = PRICE + 1;
        vm.expectRevert(abi.encodeWithSelector(IEscrow.Escrow__FeeExceedsPrice.selector, PRICE, arbiterFee));
        factory.createNewEscrow(PRICE, token, BUYER, SELLER, ARBITER, ARBITER_FEE);
        vm.stopPrank();
    }


    function test_RevertsIfTokenTxFails() public {
        ERC20MockFailedTransfer failedTxToken = new ERC20MockFailedTransfer();
        uint256 amount = PRICE - 1e16;
        failedTxToken.mint(BUYER, amount);
        failedTxToken.approve(address(factory), PRICE);
        vm.startPrank(BUYER);
        vm.expectRevert();
        factory.createNewEscrow(PRICE, failedTxToken, BUYER, SELLER, ARBITER, ARBITER_FEE);
    }

    function testCreatingEscrowEmitsEvent() public {
        vm.startPrank(BUYER);
        token.mint(BUYER, PRICE * 2);
        token.approve(address(factory), PRICE * 2);
        address computedAddress =
            factory.computeEscrowAddress(address(factory), PRICE, token, BUYER, SELLER, ARBITER, ARBITER_FEE);
        vm.expectEmit(true, true, true, true);
        emit EscrowCreated(computedAddress, BUYER, SELLER, ARBITER);
        factory.createNewEscrow(PRICE, token, BUYER, SELLER, ARBITER, ARBITER_FEE);
        vm.stopPrank();
    }
}
