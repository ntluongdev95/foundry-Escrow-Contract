// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Escrow} from "./Escrow.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IEscrowDeployer} from "./IEscrowDeployer.sol";

contract EscrowFactory is IEscrowDeployer {
    using SafeERC20 for IERC20;

    error EscrowFactory__FeeExceedsPrice(uint256 price, uint256 fee);
    error EscrowFactory__MustDeployWithTokenBalance();
    error EscrowFactory__TokenZeroAddress();
    error EscrowFactory__BuyerZeroAddress();
    error EscrowFactory__SellerZeroAddress();
    error EscrowFactory__AddressesDiffer();

    EscrowParams public parameters;

    function createNewEscrow(
        uint256 i_price,
        IERC20 i_token,
        address i_buyer,
        address i_seller,
        address i_arbiter,
        uint256 i_arbiterFee,
        bytes32 salt
    ) external returns (address escrowAddress) {
        if (address(i_token) == address(0)) revert EscrowFactory__TokenZeroAddress();
        if (i_buyer == address(0)) revert EscrowFactory__BuyerZeroAddress();
        if (i_seller == address(0)) revert EscrowFactory__SellerZeroAddress();
        if (i_arbiterFee >= i_price) revert EscrowFactory__FeeExceedsPrice(i_price, i_arbiterFee);
        i_token.safeTransferFrom(msg.sender, address(this), i_price);
        // if (i_token.balanceOf(address(this)) < i_price) revert EscrowFactory__MustDeployWithTokenBalance();
        parameters = EscrowParams({
            i_price: i_price,
            i_token: i_token,
            i_buyer: i_buyer,
            i_seller: i_seller,
            i_arbiter: i_arbiter,
            i_arbiterFee: i_arbiterFee
        });
        address computedAddress = computeEscrowAddress(
            address(this), (salt), i_price, i_token, msg.sender, i_seller, i_arbiter, i_arbiterFee
        );
        i_token.safeTransfer( computedAddress, i_price);
        Escrow escrow = new Escrow{salt: (salt)}();
        delete parameters;
        if (address(escrow) != computedAddress) {
            revert EscrowFactory__AddressesDiffer();
        }
        return computedAddress;
    }

    function computeEscrowAddress(
        address deployer,
        bytes32 salt,
        uint256 price,
        IERC20 token,
        address buyer,
        address seller,
        address arbiter,
        uint256 arbiterFee
    ) public pure returns (address pool) {
        bytes32 initCodeHash = keccak256(type(Escrow).creationCode);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            deployer,
                            keccak256(abi.encodePacked(price, token,buyer, )),
                            initCodeHash
                            )
                        )
                    )
                )
            );
    }
}
