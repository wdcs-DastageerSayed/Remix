//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract TestUniswapLiquidity {
    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;

    uint public amountSwapped;

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountA,
        uint _amountB
    ) external {
        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);

        IERC20(_tokenA).approve(ROUTER, _amountA);
        IERC20(_tokenB).approve(ROUTER, _amountB);

        (uint amountA, uint amountB, uint liquidity) = IUniswapV2Router02(ROUTER)
            .addLiquidity(
                _tokenA,
                _tokenB,
                _amountA,
                _amountB,
                1,
                1,
                address(this),
                block.timestamp
            );
    }

    function removeLiquidity(address _tokenA, address _tokenB) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        uint liquidity = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(ROUTER, liquidity);

        (uint amountA, uint amountB) = IUniswapV2Router02(ROUTER).removeLiquidity(
            _tokenA,
            _tokenB,
            liquidity,
            1,
            1,
            address(this),
            block.timestamp
        );
    }

    function swap(address tokenIn, address tokenOut, uint amountIn, address _to) public {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(ROUTER, amountIn);

        address[] memory path;
 
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        
        uint[] memory amountOutMins = IUniswapV2Router02(ROUTER).getAmountsOut(amountIn, path);
        amountSwapped = amountOutMins[path.length - 1];
    
        IUniswapV2Router02(ROUTER).swapExactTokensForTokens(amountIn, amountSwapped, path, _to, block.timestamp+1000);
    }
}
