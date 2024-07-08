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
    address escrowAdd;

     event Confirmed(address indexed seller);
    event Disputed(address indexed disputer);
    event Resolved(address indexed buyer, address indexed seller);
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
        (escrowAdd) =factory.createNewEscrow(PRICE, token, BUYER, SELLER, ARBITER, ARBITER_FEE);
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
        Escrow(escrowAdd).confirmReceipt();

    }

    function testConfirmReceiptOnlyByBuyerFuzz(address randomAddress) public escrowDeployed {
        vm.assume(randomAddress != BUYER);
        vm.expectRevert(Escrow.Escrow__OnlyBuyer.selector);
        vm.prank(randomAddress);
        Escrow(escrowAdd).confirmReceipt();
    }

     function testStateChangesOnConfirmedReceipt() public escrowDeployed {
        vm.prank(BUYER);
         Escrow(escrowAdd).confirmReceipt();
        assertEq(uint256( Escrow(escrowAdd).getState()), uint256(Escrow.State.Confirmed));
    }

    function testConfirmReceiptEmitsEvent() public escrowDeployed {
        vm.prank(BUYER);
        vm.expectEmit(true, false, false, false, escrowAdd);
        emit Confirmed(SELLER);
        Escrow(escrowAdd).confirmReceipt();
    }

     function testOnlyBuyerOrSellerCanCallinitiateDispute(address randomAdress) public escrowDeployed {
        vm.assume(randomAdress != BUYER && randomAdress != SELLER);
        vm.expectRevert(Escrow.Escrow__OnlyBuyerOrSeller.selector);
        vm.prank(randomAdress);
        Escrow(escrowAdd).initiateDispute();
    }

    function testCanOnlyInitiateDisputeInConfirmedState() public escrowDeployed {
        vm.prank(BUYER);
         Escrow(escrowAdd).confirmReceipt();

        vm.prank(BUYER);
        vm.expectRevert(
            abi.encodeWithSelector(
                Escrow.Escrow__InWrongState.selector, Escrow.State.Confirmed, Escrow.State.Created
            )
        );
        Escrow(escrowAdd).initiateDispute();
    }

    function testInitiateDisputeChangesState() public escrowDeployed {
        vm.prank(BUYER);
         Escrow(escrowAdd).initiateDispute();
        assertEq(uint256(escrow.getState()), uint256(IEscrow.State.Disputed));
    }

    function testInitiateDisputeEmitsEvent() public escrowDeployed {
        vm.prank(BUYER);
        vm.expectEmit(true, false, false, false, address(escrow));
        emit Disputed(BUYER);
        escrow.initiateDispute();
    }

    function testInitiateDisputeWithoutArbiterReverts() public {
        vm.startPrank(BUYER);
        ERC20Mock(address(i_tokenContract)).mint(BUYER, PRICE);
        ERC20Mock(address(i_tokenContract)).approve(address(escrowFactory), PRICE);
        escrow = escrowFactory.newEscrow(PRICE, i_tokenContract, SELLER, address(0), ARBITER_FEE, SALT1);
        vm.expectRevert(IEscrow.Escrow__DisputeRequiresArbiter.selector);
        escrow.initiateDispute();
        vm.stopPrank();
    }




}

