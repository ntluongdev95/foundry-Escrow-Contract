// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import{Script } from "forge-std/Script.sol";

contract DeployEscrowFactory is Script {
    address public escrowFactoryAddress;
    address public escrowFactoryDeployer;
    constructor() {
        escrowFactoryDeployer = msg.sender;
        escrowFactoryAddress = address(new EscrowFactory());
    }
}