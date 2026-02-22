// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

interface IQuest {
    function startQuest(address player, uint256 questId) external returns (bool);
    function completeQuest(address player, uint256 questId) external returns (uint256 reward);
    function getReward(address player, uint256 questId) external view returns (uint256);
}
