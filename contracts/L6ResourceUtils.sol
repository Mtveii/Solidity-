// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

library L6ResourceUtils {
    // Calculate upgrade cost using exponential growth
    function upgradeCost(uint256 base, uint256 level, uint256 multiplier) internal pure returns (uint256) {
        // cost = base * (multiplier ^ level)
        uint256 cost = base;
        for(uint256 i = 0; i < level; i++){
            cost = cost * multiplier / 1;
        }
        return cost;
    }

    // Simple gold optimization: returns spendable gold after reserve
    function optimizeGold(uint256 gold, uint256 reservePercent) internal pure returns (uint256) {
        if(reservePercent >= 100) return 0;
        return gold * (100 - reservePercent) / 100;
    }

    // Allocate energy equally among `units`, returns share per unit
    function allocateEnergy(uint256 totalEnergy, uint256 units) internal pure returns (uint256) {
        if(units == 0) return 0;
        return totalEnergy / units;
    }
}
