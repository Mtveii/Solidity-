// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

import "./L6IQuest.sol";

contract L6QuestManager is IQuest {
    struct Quest { uint256 id; uint256 reward; uint256 levelRequirement; }

    mapping(uint256 => Quest) public quests;
    mapping(address => mapping(uint256 => bool)) public started;
    mapping(address => mapping(uint256 => bool)) public completed;
    mapping(address => uint256) public goldBalance;
    mapping(address => uint256) public xp;
    mapping(address => uint256) public level;

    event QuestStarted(address indexed player, uint256 questId);
    event QuestCompleted(address indexed player, uint256 questId, uint256 reward);

    constructor(){
        // seed some example quests
        quests[1] = Quest(1, 100, 1);
        quests[2] = Quest(2, 250, 2);
        quests[3] = Quest(3, 500, 5);
    }

    function _ensurePlayerInit(address player) internal {
        if(level[player] == 0) level[player] = 1;
    }

    function startQuest(address player, uint256 questId) external override returns (bool) {
        _ensurePlayerInit(player);
        Quest memory q = quests[questId];
        require(q.id != 0, "Quest not found");
        require(level[player] >= q.levelRequirement, "Level too low");
        require(!started[player][questId], "Already started");

        started[player][questId] = true;
        emit QuestStarted(player, questId);
        return true;
    }

    function completeQuest(address player, uint256 questId) external override returns (uint256 reward) {
        require(started[player][questId], "Quest not started");
        require(!completed[player][questId], "Already completed");
        Quest memory q = quests[questId];
        require(q.id != 0, "Quest not found");

        completed[player][questId] = true;
        // give reward
        goldBalance[player] += q.reward;
        xp[player] += q.reward / 10;
        // simple level up: every 100 xp -> level++
        while(xp[player] >= level[player] * 100){
            xp[player] -= level[player] * 100;
            level[player] += 1;
        }

        emit QuestCompleted(player, questId, q.reward);
        return q.reward;
    }

    function getReward(address player, uint256 questId) external view override returns (uint256) {
        Quest memory q = quests[questId];
        require(q.id != 0, "Quest not found");
        if(completed[player][questId]) return q.reward;
        return 0;
    }

    // helper views
    function playerLevel(address player) external view returns (uint256){
        uint256 l = level[player]; if(l == 0) return 1; return l;
    }
}
