// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract GoldBarTether is ERC20, Ownable {
    // Final daily mine amount
    uint256 public constant DAILY_MINE_AMOUNT = 19890927000000000000000000; // 19890927 * 1e18
    uint256 public constant MINE_INTERVAL = 1 days;

    address public constant FEE_RECEIVER = 0xF7F965b65E735Fb1C22266BdcE7A23CF5026AF1E;
    uint256 public constant TRANSFER_FEE = 100000000000000000; // 0.1 GBT

    mapping(address => uint256) public lastMine;
    mapping(uint256 => uint256) public priceHistory;
    uint256 public launchTimestamp;

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) ERC20("GoldBarTether", "GBT") {
        launchTimestamp = block.timestamp;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // -------------------
    // MINING LOGIC
    // -------------------
    function mine() external {
        require(canMine(msg.sender), "Mine only once per 24h");

        _mint(msg.sender, DAILY_MINE_AMOUNT);
        lastMine[msg.sender] = block.timestamp;
    }

    function canMine(address user) public view returns (bool) {
        return block.timestamp >= lastMine[user] + MINE_INTERVAL;
    }

    // -------------------
    // TRANSFER W/ FEE
    // -------------------
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > TRANSFER_FEE, "Amount must be greater than fee");

        uint256 amountAfterFee = amount - TRANSFER_FEE;
        super._transfer(sender, recipient, amountAfterFee);
        super._transfer(sender, FEE_RECEIVER, TRANSFER_FEE);
    }

    // -------------------
    // PRICE BEHAVIOR (18% ↑ → 6% ↓ allowed)
    // -------------------
    bool public priceCanDrop = false;

    function updatePriceFromOracle() public onlyOwner {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid oracle price");

        uint256 day = (block.timestamp - launchTimestamp) / 1 days;
        priceHistory[day] = uint256(price);

        if (day > 0) {
            uint256 prev = priceHistory[day - 1];
            if (priceHistory[day] >= (prev * 118) / 100) {
                priceCanDrop = true;
            }
        }
    }

    function allowPriceDrop(uint256 newPrice) external view returns (bool) {
        uint256 day = (block.timestamp - launchTimestamp) / 1 days;
        uint256 current = priceHistory[day];
        return priceCanDrop && newPrice <= (current * 94) / 100;
    }

    function setOracle(address _priceFeed) external onlyOwner {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract GoldBarTether is ERC20, Ownable {
    // Final daily mine amount
    uint256 public constant DAILY_MINE_AMOUNT = 19890927000000000000000000; // 19890927 * 1e18
    uint256 public constant MINE_INTERVAL = 1 days;

    address public constant FEE_RECEIVER = 0xF7F965b65E735Fb1C22266BdcE7A23CF5026AF1E;
    uint256 public constant TRANSFER_FEE = 100000000000000000; // 0.1 GBT

    mapping(address => uint256) public lastMine;
    mapping(uint256 => uint256) public priceHistory;
    uint256 public launchTimestamp;

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) ERC20("GoldBarTether", "GBT") {
        launchTimestamp = block.timestamp;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // -------------------
    // MINING LOGIC
    // -------------------
    function mine() external {
        require(canMine(msg.sender), "Mine only once per 24h");

        _mint(msg.sender, DAILY_MINE_AMOUNT);
        lastMine[msg.sender] = block.timestamp;
    }

    function canMine(address user) public view returns (bool) {
        return block.timestamp >= lastMine[user] + MINE_INTERVAL;
    }

    // -------------------
    // TRANSFER W/ FEE
    // -------------------
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > TRANSFER_FEE, "Amount must be greater than fee");

        uint256 amountAfterFee = amount - TRANSFER_FEE;
        super._transfer(sender, recipient, amountAfterFee);
        super._transfer(sender, FEE_RECEIVER, TRANSFER_FEE);
    }

    // -------------------
    // PRICE BEHAVIOR (18% ↑ → 6% ↓ allowed)
    // -------------------
    bool public priceCanDrop = false;

    function updatePriceFromOracle() public onlyOwner {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid oracle price");

        uint256 day = (block.timestamp - launchTimestamp) / 1 days;
        priceHistory[day] = uint256(price);

        if (day > 0) {
            uint256 prev = priceHistory[day - 1];
            if (priceHistory[day] >= (prev * 118) / 100) {
                priceCanDrop = true;
            }
        }
    }

    function allowPriceDrop(uint256 newPrice) external view returns (bool) {
        uint256 day = (block.timestamp - launchTimestamp) / 1 days;
        uint256 current = priceHistory[day];
        return priceCanDrop && newPrice <= (current * 94) / 100;
    }

    function setOracle(address _priceFeed) external onlyOwner {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
}
