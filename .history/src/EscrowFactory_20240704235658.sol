// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/s/token/ERC20/IERC20.sol";
import {Escrow} from "./Escrow.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
contract EscrowFactory is IEscrowDeployer {

     using SafeERC20 for IERC20;

    error EscrowFactory__FeeExceedsPrice(uint256 price, uint256 fee);
    error Escrowactory__MustDeployWithTokenBalance();
    error Escrowactory__TokenZeroAddress();
    error Escrowactory__BuyerZeroAddress();
    error Escrowactory__SellerZeroAddress();
    error EscrowFactory__AddressesDiffer();
    
    EscrowParams public parameters;


    function createNewEscrow (
        uint256 i_price,
        address i_token,
        address i_buyer,
        address i_seller,
        address i_arbiter,
        uint256 i_arbiterFee
    ) external returns (address escrow)
    {
        if (address(i_token) == address(0)) revert Escrow__TokenZeroAddress();
        if (i_buyer == address(0)) revert Escrow__BuyerZeroAddress();
        if (i_seller == address(0)) revert Escrow__SellerZeroAddress();
        if (i_arbiterFee >= i_price) revert Escrow__FeeExceedsPrice(price, arbiterFee);
        if (i_token.balanceOf(address(this)) < i_price) revert Escrow__MustDeployWithTokenBalance();
        
        parameters = EscrowParams({
            i_price: i_price,
            i_token: i_token,
            i_buyer: i_buyer,
            i_seller: i_seller,
            i_arbiter: i_arbiter,
           i_arbiterFee:i_arbiterFee
        });
        address computedAddress = computeEscrowAddress(
            address(this),
            uint256(salt),
            i_price,
            i_token,
            msg.sender,
            i_seller,
            i_arbiter,
            i_arbiterFee
        );
         token.safeTransferFrom(msg.sender, computedAddress, i_price);
          Escrow escrow = new Escrow{salt: salt}(
            s_price,
            s_token,
            msg.sender, 
            s_seller,
            s_arbiter,
            s_arbiterFee
        );
        delete parameters;
        if (address(escrow) != computedAddress) {
            revert EscrowFactory__AddressesDiffer();
        }
        return computedAddress;

    }

     function computeEscrowAddress(
        address deployer,
        uint256 salt,
        uint256 price,
        IERC20 token,
        address buyer,
        address seller,
        address arbiter,
        uint256 arbiterFee
    ) internal pure returns (address pool) {
        bytes32 initCodeHash = keccak256(type(Escrow).creationCode);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            deployer,
                            salt,
                             keccak256(
                                abi.encodePacked(
                                    initCodeHash, abi.encode(price, token, buyer, seller, arbiter, arbiterFee)
                                )
                            )
                        )
                    )
                )
            )
        );
    }

    function computeEscrowAddress() external pure returns(address){

    }


}