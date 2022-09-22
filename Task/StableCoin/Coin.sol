//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IOracle {
    function getMarketData() external returns (uint256, bool);
    function getTargetData() external returns (uint256, bool);
}

contract stableCoin is ERC20{

    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 596 * 10**3 * 10**9; 
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS; 
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;
    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;

    address public Owner;
    uint256 public deviationThreshold;
    // uint256 public exchangeRate;
    uint256 public rebaseLag;
    uint256 public minRebaseTimeIntervalSec;
    uint256 public lastRebaseTimestampSec;
    uint256 public rebaseWindowOffsetSec;
    uint256 public rebaseWindowLengthSec;
    uint256 public epoch;
    bool public rebasePausedDeprecated;
    bool public tokenPausedDeprecated;

    //Events
     event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        uint256 cpi,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    //Mappings
    mapping(address => uint256) private _gonBalances;
    mapping (address => mapping (address => uint256)) private _allowedFragments;

    //Modifiers
    modifier onlyOwner() {
        require(msg.sender == Owner);
        _;
    }

    IOracle public targetPriceOracle;
    IOracle public marketOracle;
 
   constructor(address owner_) ERC20("DevCoin", "DC") {
        _mint(owner_, 596 * 10**3 * 10**9);
        rebasePausedDeprecated = false;
        tokenPausedDeprecated = false;

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[owner_] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;
        Owner = owner_;
    }

    function transfer(address to, uint256 amount) public override returns (bool)
    {
        uint256 gonValue = amount *_gonsPerFragment;
        _gonBalances[msg.sender] = _gonBalances[msg.sender] - gonValue;
        _gonBalances[to] = _gonBalances[to] + gonValue;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function balanceOf (address who) public view override returns (uint256)
    {
        return _gonBalances[who] / _gonsPerFragment;
    }

    function totalSupply() public view override returns (uint256)
    {
        return _totalSupply;
    }

    function setOracle(IOracle PriceOracle_) external onlyOwner{
        targetPriceOracle = PriceOracle_;
        marketOracle = PriceOracle_;
    }

    function setDeviationThreshold(uint256 deviationThreshold_) external onlyOwner{
        deviationThreshold = deviationThreshold_;
    }

    function setRebaseLag(uint256 rebaseLag_) external onlyOwner{
        require(rebaseLag_ > 0);
        rebaseLag = rebaseLag_;
    }

    function setRebaseTimingParameters(uint256 minRebaseTimeIntervalSec_, uint256 rebaseWindowOffsetSec_, uint256 rebaseWindowLengthSec_) external onlyOwner{
        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;
    }

    function inRebaseWindow() public view returns (bool) {
        return (
            (block.timestamp % minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec &&
            (block.timestamp % minRebaseTimeIntervalSec) < (rebaseWindowOffsetSec + rebaseWindowLengthSec)
        );
    }

    function getTragetValue() public returns(uint256, bool) {
        uint256 targetRate;
        bool targetRateValid;
        (targetRate, targetRateValid) = targetPriceOracle.getTargetData();
        return (targetRate,targetRateValid);
    }

    function getExchangerate() public returns(uint256, bool){
        uint256 exchangeRate;
        bool rateValid;
        (exchangeRate, rateValid) = marketOracle.getMarketData();
        return(exchangeRate, rateValid);
    }

    function withinDeviationThreshold(uint256 rate, uint256 targetRate) private view returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate * deviationThreshold / 10 **DECIMALS;
        return (rate >= targetRate && (rate - targetRate) < absoluteDeviationThreshold) || (rate < targetRate && (targetRate - rate) < absoluteDeviationThreshold);
    }

    function computeSupplyDelta(uint256 rate, uint256 targetRate) private view returns (int256)
    {
        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }
        // supplyDelta = totalSupply * (rate - targetRate) / targetRate
        int256 targetRateSigned = int256(targetRate);
        return int256(totalSupply()) * (int256(rate) - targetRateSigned) / targetRateSigned ;
    }

    function rebaseFragment(uint256 epoch, int256 supplyDelta) private returns (uint256)
    {
        if (supplyDelta == 0) {
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply - uint256(supplyDelta);
        } else {
            _totalSupply = _totalSupply + uint256(supplyDelta);
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS / _totalSupply;
        return _totalSupply;
    }

    function rebase() external onlyOwner {
        require(inRebaseWindow());
        // This comparison also ensures there is no reentrancy.
        require((lastRebaseTimestampSec + minRebaseTimeIntervalSec) < block.timestamp);

        // Snap the rebase time to the start of this window.
        lastRebaseTimestampSec = (block.timestamp - (block.timestamp % minRebaseTimeIntervalSec) + rebaseWindowOffsetSec);

        epoch = epoch+1;

        uint256 targetRate;
        bool targetRateValid;
        (targetRate, targetRateValid) = targetPriceOracle.getTargetData();
        require(targetRateValid);
        
        uint256 exchangeRate;
        bool rateValid;
        
        (exchangeRate, rateValid) = marketOracle.getMarketData();
        require(rateValid);

        if (exchangeRate > MAX_RATE) {
            exchangeRate = MAX_RATE;
        }
    
        int256 supplyDelta = computeSupplyDelta(exchangeRate, targetRate);

        supplyDelta = supplyDelta / int256(rebaseLag);

        if (supplyDelta > 0 && totalSupply() + uint256(supplyDelta) > MAX_SUPPLY) {
            supplyDelta = int256(MAX_SUPPLY - totalSupply());
        }

        uint256 supplyAfterRebase = rebaseFragment(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        emit LogRebase(epoch, exchangeRate, targetRate, supplyDelta, block.timestamp);
    }
}