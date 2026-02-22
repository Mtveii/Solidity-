// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

import "./L6WarriorGuild.sol";

contract L6Mage is L6WarriorGuild {
    event SpellCast(address indexed who, uint256 damage);

    function attack(uint256 targetStrength) external override returns (uint256 damage) {
        require(registered[msg.sender], "Not registered");
        // Mage deals magic damage based on target weakness: base power + 30% of targetStrength
        uint256 d = power[msg.sender] + (targetStrength * 30) / 100;
        emit SpellCast(msg.sender, d);
        return d;
    }
}
