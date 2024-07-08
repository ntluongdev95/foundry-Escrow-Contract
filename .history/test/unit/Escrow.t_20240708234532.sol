  // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {EscrowFactory} from "../../src/EscrowFactory.sol";
import {DeployEscrowFactory} from "../../script/DeployEscrowFactory.s.sol";
import {Escrow} from "../../src/Escrow.sol";
import {ERC20MockFailedTransfer} from "../../test/mock/ERC20MockFailedTransfer.t.sol";

contract TestEscrow is Test{
    
    ERC20Mock token;
    EscrowFactory factory;
    uint256 public constant PRICE = 1e18;
    address public BUYER;
    address public SELLER;
    address public ARBITER;
    uint256 public constant ARBITER_FEE = 1e16;
    Escrow escrowAdd;
    function setUp() external{
        token = new ERC20Mock();
        BUYER = makeAddr("buyer");
        SELLER = makeAddr("seller");
        ARBITER = makeAddr("arbiter");
        DeployEscrowFactory deployed = new DeployEscrowFactory();
        factory = deployed.run();
    }

    function testDeployEscrowFromFactory() public {
        vm.startPrank(BUYER);
        ERC20Mock(address(token)).mint(BUYER, PRICE);
        ERC20Mock(address(token)).approve(address(factory), PRICE);
        address escrow = factory.createNewEscrow(PRICE, token, BUYER, SELLER, ARBITER, ARBITER_FEE);
        vm.stopPrank();
        assertEq(Escrow(escrow).getPrice(), PRICE);
        assertEq(address(Escrow(escrow).getTokenContract()), address(token));
        assertEq(Escrow(escrow).getBuyer(), BUYER);
        assertEq(Escrow(escrow).getSeller(), SELLER);
        assertEq(Escrow(escrow).getArbiter(), ARBITER);
        assertEq(Escrow(escrow).getArbiterFee(), ARBITER_FEE);
    }

      modifier escrowDeployed() {
        vm.startPrank(BUYER);
        ERC20Mock(address(token)).mint(BUYER, PRICE);
        ERC20Mock(address(token)).approve(address(factory), PRICE);
        EscrowescrowAdd =factory.createNewEscrow(PRICE, token, BUYER, SELLER, ARBITER, ARBITER_FEE);
        vm.stopPrank();
        _;
    }

     function testConfirmReceiptRevertsOnTokenTxFail() public {

        ERC20MockFailedTransfer tokenContract = new ERC20MockFailedTransfer();
         tokenContract.changePasses(true);
        vm.startPrank(BUYER);
        tokenContract.mint(BUYER, PRICE);
        tokenContract.approve(address(factory), PRICE);
         address escrow = factory.createNewEscrow(PRICE, tokenContract, BUYER, SELLER, ARBITER, ARBITER_FEE);
        tokenContract.changePasses(false);
        vm.expectRevert();
        Escrow(escrow).confirmReceipt();
        vm.stopPrank();

     }

      function testConfirmReceiptOnlyByBuyer() public escrowDeployed {
        vm.expectRevert(Escrow.Escrow__OnlyBuyer.selector);
        vm.prank(ARBITER);
        escrowAdd.confirmReceipt();

    }

    function testConfirmReceiptOnlyByBuyerFuzz(address randomAddress) public escrowDeployed {
        vm.assume(randomAddress != BUYER);
        vm.expectRevert(Escrow.Escrow__OnlyBuyer.selector);
        vm.prank(randomAddress);
        escrowAdd.confirmReceipt();
    }



}

