// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IEscrowDeployer} from "./IEscrowDeployer.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
contract Escrow is ReentrancyGuard {
    
    //error
    error Escrow__OnlyBuyer();
    error Escrow__InWrongState(State currentState, State expectedState);
    error  Escrow__OnlyBuyerOrSeller();

    //events 
    event Confirmed(address indexed seller);
    event Disputed(address indexed disputer);
    event Resolved(address indexed buyer, address indexed seller);


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
       ( i_price, i_token, i_buyer, i_seller, i_arbiter, i_arbiterFee) = IEscrowDeployer(msg.sender).parameters();
    }

    modifier onlyBuyer(){
       if(msg.sender != i_buyer) {
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
    modifier onlyBuyerOrSeller() {
        if (msg.sender != i_buyer && msg.sender != i_seller) {
            revert Escrow__OnlyBuyerOrSeller();
        }
        _;
    }
     modifier onlyArbiter() {
        if (msg.sender != i_arbiter) {
            revert Escrow__OnlyArbiter();
        }
        _;
    }

     function confirmReceipt() external onlyBuyer inState(State.Created) {
        s_state = State.Confirmed;
        emit Confirmed(i_seller);

        i_token.safeTransfer(i_seller, i_token.balanceOf(address(this)));
    }


    /////////////////////
    // View functions
    /////////////////////

    function getPrice() external view returns (uint256) {
        return i_price;
    }

    function getTokenContract() external view returns (IERC20) {
        return i_token;
    }

    function getBuyer() external view returns (address) {
        return i_buyer;
    }

    function getSeller() external view returns (address) {
        return i_seller;
    }

    function getArbiter() external view returns (address) {
        return i_arbiter;
    }

    function getArbiterFee() external view returns (uint256) {
        return i_arbiterFee;
    }

    function getState() external view returns (State) {
        return s_state;
    }




   
}
