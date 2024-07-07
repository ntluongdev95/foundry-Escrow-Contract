    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {EscrowFactory} from "../../src/EscrowFactory.sol";
import {DeployEscrowFactory} from "../../script/DeployEscrowFactory.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Escrow} from "../../src/Escrow.sol";

contract TestEscrowFactory is Test {
    IERC20 token;
    EscrowFactory factory;
    bytes32 public constant SALT1 = bytes32(uint256(keccak256(abi.encodePacked("test"))));
    bytes32 public constant SALT2 = bytes32(uint256(keccak256(abi.encodePacked("test2"))));
    uint256 public constant PRICE = 1e18;
    address public BUYER;
    address public SELLER;
    address public ARBITER;
    uint256 public constant ARBITER_FEE = 1e16;

    function setUp() public {
        ERC20Mock token_add = new ERC20Mock();
        token = IERC20(address(token_add));
        BUYER = makeAddr("buyer");
        SELLER = makeAddr("seller");
        ARBITER = makeAddr("arbiter");
        DeployEscrowFactory deployed = new DeployEscrowFactory();
        factory = deployed.run();
    }

    function test_ComputedAddressEqualsDeployedAddress() public {
        vm.startPrank(BUYER);
        
        address computedAddress = factory.computeEscrowAddress(
            address(factory), (SALT1), PRICE, token, BUYER, SELLER, ARBITER, ARBITER_FEE
        );
        vm.startPrank(address(factory));
        
        Escrow escrow = new Escrow{salt:(SALT1)}();
        vm.stopPrank();
        assertEq(computedAddress, address(escrow));
    }
}
