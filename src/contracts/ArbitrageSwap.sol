// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IWETH9 {
    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);

    function withdraw(uint256 wad) external;
}

contract ArbitrageSwap {
    IWETH9 weth;

    constructor(address payable _weth) {
        weth = IWETH9(_weth);
    }

    function swap(
        IUniswapV2Pair pool_a,
        IUniswapV2Pair pool_b,
        IERC20 token,
        uint256 intermediate_amount,
        uint256 profit
    ) public payable {
        weth.deposit{value: msg.value}();
        (uint256 amount0, uint256 amount1) = pool_a.token0() == address(token)
            ? (intermediate_amount, uint256(0))
            : (uint256(0), intermediate_amount);
        weth.transfer(address(pool_a), msg.value);
        pool_a.swap(amount0, amount1, address(pool_b), "");

        (uint256 amount0b, uint256 amount1b) = pool_b.token0() == address(token)
            ? (uint256(0), profit)
            : (profit, uint256(0));
        pool_b.swap(amount0b, amount1b, address(this), "");
        weth.transfer(msg.sender, profit);
        // weth.withdraw(profit);
        // payable(msg.sender).transfer(profit);
    }

    receive() external payable {}
}
