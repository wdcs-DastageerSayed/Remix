pragma solidity 0.6.6;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/lib/contracts/libraries/FixedPoint.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";

contract UniswapV2PriceOracle{
    using FixedPoint for *;

    uint256 public constant PERIOD = 10;

    IUniswapV2Pair public immutable pair;
    address public immutable token0;
    address public immutable token1;

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint32 public blockTimestampLast;

    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    constructor(IUniswapV2Pair _pair) public {
        pair = _pair;
        token0 = _pair.token0();
        token1 = _pair.token1();
        price0CumulativeLast = _pair.price0CumulativeLast();
        price1CumulativeLast = _pair.price1CumulativeLast();
        (, , blockTimestampLast)= _pair.getReserves();
    }

    function update() external{
        (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        uint256 timeElapsed = blockTimestamp - blockTimestampLast;
        require(timeElapsed >= PERIOD, "time elapsed < min pariod");

        price0Average = FixedPoint.uq112x112(
            uint224((price0Cumulative - price0CumulativeLast) / timeElapsed)
        );
        price1Average = FixedPoint.uq112x112(
            uint224((price1Cumulative - price1CumulativeLast) / timeElapsed)
        );
 
        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimestamp;
    }
     
    function consult(address _token, uint256 _amountIn) external view returns (uint256 _amountOut){
        require(_token == token0 || _token == token1, "Invalid Token" );

        if(_token == token0){
            _amountOut = price0Average.mul(_amountIn).decode144();
        }
        else{
            _amountOut = price1Average.mul(_amountIn).decode144();
        }
    }
}
