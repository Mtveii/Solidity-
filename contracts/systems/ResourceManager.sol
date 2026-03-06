// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

import "./L6ResourceUtils.sol";

contract L6ResourceManager {
    using L6ResourceUtils for uint256;

    struct Resources { uint256 gold; uint256 energy; uint256 food; }

    mapping(address => Resources) public resources;

    event GoldDeposited(address indexed who, uint256 amount);
    event GoldSpent(address indexed who, uint256 amount);

    function depositGold() external payable {
        require(msg.value > 0, "No ether");
        resources[msg.sender].gold += msg.value;
        emit GoldDeposited(msg.sender, msg.value);
    }

    function withdrawGold(uint256 amount) external {
        require(resources[msg.sender].gold >= amount, "Insufficient gold");
        resources[msg.sender].gold -= amount;
        payable(msg.sender).transfer(amount);
    }

    function spendGoldOptimized(uint256 amount, uint256 reservePercent) external returns (bool) {
        uint256 spendable = L6ResourceUtils.optimizeGold(resources[msg.sender].gold, reservePercent);
        require(spendable >= amount, "Not enough optimized gold");
        resources[msg.sender].gold -= amount;
        emit GoldSpent(msg.sender, amount);
        return true;
    }

    function getUpgradeCost(uint256 base, uint256 level, uint256 multiplier) external pure returns (uint256){
        return L6ResourceUtils.upgradeCost(base, level, multiplier);
    }

    function allocateEnergyToUnits(uint256 units) external returns (uint256){
        uint256 share = L6ResourceUtils.allocateEnergy(resources[msg.sender].energy, units);
        // not modifying resources here — caller can use share to decide
        return share;
    }

    // admin helpers for tests/dev
    function setEnergy(uint256 amount) external {
        resources[msg.sender].energy = amount;
    }

    function setGold(uint256 amount) external {
        resources[msg.sender].gold = amount;
    }
}
