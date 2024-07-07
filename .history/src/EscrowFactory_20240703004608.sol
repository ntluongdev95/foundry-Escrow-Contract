// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/s/token/ERC20/IERC20.sol";

contract EscrowFactory is IEscrowDeployer {

    error Escrow__FeeExceedsPrice(uint256 price, uint256 fee);
    error Escrow__MustDeployWithTokenBalance();
    error Escrow__TokenZeroAddress();
    error Escrow__BuyerZeroAddress();
    error Escrow__SellerZeroAddress();
    function createNewEscrow (
        uint256 _price,
        address _token,
        address _buyer,
        address _seller,
        address _arbiter,
        uint256 _arbiterFee
    ) external returns (address escrow)
    {
        if (address(_token) == address(0)) revert Escrow__TokenZeroAddress();
        if (_buyer == address(0)) revert Escrow__BuyerZeroAddress();
        if (_seller == address(0)) revert Escrow__SellerZeroAddress();
        if (_arbiterFee >= price) revert Escrow__FeeExceedsPrice(price, arbiterFee);
        if (token.balanceOf(address(this)) < price) revert Escrow__MustDeployWithTokenBalance();
        
        parameters = EscrowParams({
            price: _price,
            token: _token,
            buyer: _buyer,
            seller: _seller,
            arbiter: _arbiter,
            arbiterFee: _arbiterFee
        });

    }

     function computeEscrowAddress(
        address deployer,
        uint256 salt,
        uint256 price,
        IERC20 tokenContract,
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
                            factory,
                            keccak256(abi.encodePacked(token0, token1, fee)),
                            keccak256(type(UniswapV3Pool).creationCode)
                        )
                    )
                )
            )
        );
    }

    function computeEscrowAddress() external pure returns(address){

    }


}