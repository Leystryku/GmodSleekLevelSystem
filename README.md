# GmodSleekLevelSystem
[![License](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)
[![App Version](https://img.shields.io/badge/version-v1.1.2-brightgreen)](https://github.com/Leystryku/GmodSleekLevelSystem)

Sleek Level System - one of my addons from ~2013, very barebones imo.

- MySQL support
- Integration for TTT and some other gamemodes
- Deathrun support
- Prophunt support
- Zombiesurvival support
- Sandbox support
- Automatic display of level for some gamemodes
- Easy to use API

API (shared works on both servers and clients):
- Level:GetLevel(ply) - Get the players Level
- Level:GetNeededExp(ply) - Get EXP required for leveling up
- Level:GetEXP(ply) - Get the players total EXP for this level
- Level:AddEXP(ply) - Add EXP to the player for this level
- Level:TakeEXP(ply) - Remove EXP from the player for this level
- Level:SetEXP(ply) - Set the players EXP directly for this level
- Level:SetLevel(ply) - Set players level to another level directly

Integrations:
- lvl/sv - for gamemode specific Level system integrations to make e.g. that gamemodes EndRound give you EXP
- lvl/cl_int - To integrate in with the scoreboard and other stuff like the TargetID
- lvl/cl - Incase you want to modify the base UI or have gamemode specific UIs

![image](https://raw.githubusercontent.com/Leystryku/GmodSleekLevelSystem/main/assets/1.png)
