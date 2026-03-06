// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

import "./L6WarriorGuild.sol";

contract L6Assassin is L6WarriorGuild {
    event Backstab(address indexed who, uint256 damage);

    function attack(uint256 targetStrength) external override returns (uint256 damage) {
        require(registered[msg.sender], "Not registered");
        // Assassin deals high burst damage but lower consistent power: base power * 2 then random-ish modifier
        uint256 d = power[msg.sender] * 2;
        emit Backstab(msg.sender, d);
        return d;
    }
}
