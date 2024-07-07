// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IEscrowDeployer} from "./IEscrowDeployer.sol";

contract Escrow {
    
    //error
    error Escrow__OnlyBuyer();

    //events 


    enum State {
        Created,
        Confirmed,
        Disputed,
        Resolved
    }

    uint256 private immutable i_price;
    IERC20 private immutable i_token;
    address private immutable i_buyer;
    address private immutable i_seller;
    address private immutable i_arbiter;
    uint256 private immutable i_arbiterFee;

    State private s_state;

    constructor (){
       ( i_price, i_token, i_buyer, s_seller, s_arbiter, s_arbiterFee) = IEscrowDeployer(msg.sender).parameters();
    }

    modifier onlyBuyer(){
       if(msg.sender != s_buyer) {
        revert Escrow__OnlyBuyer();
       }
        _;
    }

    /// @dev Throws if contract called in State other than one associated for function.
    modifier inState(State expectedState) {
        if (s_state != expectedState) {
            revert Escrow__InWrongState(s_state, expectedState);
        }
        _;
    }




   
}
