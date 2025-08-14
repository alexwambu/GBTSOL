// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * GoldBarTether (GBT)
 * - ERC-20 (18 decimals)
 * - Flat transfer fee: 0.1 GBT sent to feeReceiver
 * - PoW mining: submitWork(nonce) with keccak(msg.sender, nonce, prevBlockHash) < target
 * - Global daily mining cap: 19,890,927 GBT per 24h (UTC day buckets via block.timestamp/1 days)
 * - Infinite supply via mining only (no owner mint)
 *
 * Notes:
 * - Owner can adjust PoW target to tune difficulty.
 * - PoW reward is per valid proof. Default 1 GBT per proof.
 * - Miners can submit multiple proofs/day until the global cap is hit.
 */
contract GoldBarTether is ERC20, Ownable {
    // ======== Fee config ========
    // Hardcoded fee receiver as requested
    address public constant feeReceiver = 0xF7F965b65E735Fb1C22266BdcE7A23CF5026Af1E;
    // 0.1 GBT (18 decimals)
    uint256 public constant TRANSFER_FEE = 100_000_000_000_000_000; // 0.1 * 1e18

    // ======== Mining config ========
    // Global daily cap
    uint256 public constant DAILY_MINE_CAP = 19_890_927 * 1e18;
    // Reward per valid proof-of-work
    uint256 public powReward = 1e18; // 1 GBT per valid proof
    // Difficulty target (lower target = harder). Default target ~ 1e-10 of full range.
    uint256 public target;

    // Tracking per day mined total
    uint256 public minedToday;
    uint256 public lastMinedDay;

    event Mined(address indexed miner, uint256 amount, bytes32 hash, uint256 day);
    event TargetUpdated(uint256 newTarget);
    event PowRewardUpdated(uint256 newReward);

    constructor() ERC20("GoldBarTether", "GBT") {
        // Default target (adjustable): roughly max/1e10. Tune as needed.
        target = type(uint256).max / 1e10;
        // No premine. Supply grows only via mining & fees routed to feeReceiver.
        // If you want an initial allocation to feeReceiver, uncomment:
        // _mint(feeReceiver, 999_000_000_000_000_000_000_000 * 1e18);
    }

    // ======== Transfers with flat fee ========
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > TRANSFER_FEE, "Amount must exceed fee");
        uint256 sendAmount = amount - TRANSFER_FEE;
        super._transfer(sender, recipient, sendAmount);
        super._transfer(sender, feeReceiver, TRANSFER_FEE);
    }

    // ======== PoW Mining ========
    /**
     * Submit a nonce to attempt PoW. Uses previous block hash as changing salt.
     * hash = keccak256(abi.encodePacked(msg.sender, nonce, blockhash(block.number-1)));
     * Requires: uint256(hash) < target
     * Mints powReward to msg.sender if the global daily cap is not exceeded.
     */
    function submitWork(bytes32 nonce) external {
        // Determine current UTC day bucket
        uint256 day = block.timestamp / 1 days;

        // Reset daily counters if we crossed into a new day
        if (day > lastMinedDay) {
            minedToday = 0;
            lastMinedDay = day;
        }

        // Check PoW
        bytes32 h = keccak256(abi.encodePacked(msg.sender, nonce, blockhash(block.number - 1)));
        require(uint256(h) < target, "Invalid PoW");

        // Respect daily cap
        require(minedToday + powReward <= DAILY_MINE_CAP, "Daily cap reached");
        minedToday += powReward;

        _mint(msg.sender, powReward);
        emit Mined(msg.sender, powReward, h, day);
    }

    // ======== Admin controls ========
    function setTarget(uint256 newTarget) external onlyOwner {
        require(newTarget > 0, "Target must be > 0");
        target = newTarget;
        emit TargetUpdated(newTarget);
    }

    function setPowReward(uint256 newReward) external onlyOwner {
        require(newReward > 0, "Reward must be > 0");
        powReward = newReward;
        emit PowRewardUpdated(newReward);
    }
}
