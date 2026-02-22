// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

contract L6WarriorGuild {
    mapping(address => bool) public registered;
    mapping(address => uint256) public power;

    event Registered(address indexed who);

    function registerWarrior() external returns (bool){
        registered[msg.sender] = true;
        power[msg.sender] = 10; // base power
        emit Registered(msg.sender);
        return true;
    }

    // virtual attack function to be overridden
    function attack(uint256 targetStrength) external virtual returns (uint256 damage) {
        require(registered[msg.sender], "Not registered");
        uint256 d = power[msg.sender] / 2;
        return d;
    }
}
