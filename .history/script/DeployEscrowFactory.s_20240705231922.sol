// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DeployEscrowFactory {
    address public escrowFactoryAddress;
    address public escrowFactoryDeployer;
    constructor() {
        escrowFactoryDeployer = msg.sender;
        escrowFactoryAddress = address(new EscrowFactory());
    }
}