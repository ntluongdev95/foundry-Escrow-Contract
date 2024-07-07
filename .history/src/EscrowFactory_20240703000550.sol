// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EscrowFactory is IEscrowDeployer {
    function createNewEscrow (
        uint256 _price,
        address _token,
        address _buyer,
        address _seller,
        address _arbiter,
        uint256 _arbiterFee
    ) external returns (address)
    {


    }


}