// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/s/token/ERC20/IERC20.sol";
import {Escrow} from "./Escrow.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
contract EscrowFactory is IEscrowDeployer {

     using SafeERC20 for IERC20;

    error Escrow__FeeExceedsPrice(uint256 price, uint256 fee);
    error Escrow__MustDeployWithTokenBalance();
    error Escrow__TokenZeroAddress();
    error Escrow__BuyerZeroAddress();
    error Escrow__SellerZeroAddress();
    function createNewEscrow (
        uint256 s_price,
        address s_token,
        address s_buyer,
        address s_seller,
        address s_arbiter,
        uint256 s_arbiterFee
    ) external returns (address escrow)
    {
        if (address(s_token) == address(0)) revert Escrow__TokenZeroAddress();
        if (s_buyer == address(0)) revert Escrow__BuyerZeroAddress();
        if (s_seller == address(0)) revert Escrow__SellerZeroAddress();
        if (s_arbiterFee >= s_price) revert Escrow__FeeExceedsPrice(price, arbiterFee);
        if (s_token.balanceOf(address(this)) < s_price) revert Escrow__MustDeployWithTokenBalance();
        
        parameters = EscrowParams({
            s_price: s_price,
            s_token: s_token,
            s_buyer: s_buyer,
            s_seller: s_seller,
            s_arbiter: s_arbiter,
            s_arbiterFee: s_arbiterFee
        });
        address computedAddress = computeEscrowAddress(
            address(this),
            uint256(salt),
            s_price,
            s_token,
            msg.sender,
            s_seller,
            s_arbiter,
            s_arbiterFee
        );
         token.safeTransferFrom(msg.sender, computedAddress, s_price);
          Escrow escrow = new Escrow{salt: salt}(
            price,
            token,
            msg.sender, 
            seller,
            arbiter,
            arbiterFee
        );
        if (address(escrow) != computedAddress) {
            revert EscrowFactory__AddressesDiffer();
        }
         delete parameters;
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