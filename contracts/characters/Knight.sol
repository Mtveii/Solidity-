// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

import "./L6WarriorGuild.sol";

contract L6Knight is L6WarriorGuild {
    event SwordStrike(address indexed who, uint256 damage);

    function attack(uint256 targetStrength) external override returns (uint256 damage) {
        require(registered[msg.sender], "Not registered");
        // Knight deals stable melee damage: base power * 1.5
        uint256 d = (power[msg.sender] * 3) / 2;
        emit SwordStrike(msg.sender, d);
        return d;
    }
}
