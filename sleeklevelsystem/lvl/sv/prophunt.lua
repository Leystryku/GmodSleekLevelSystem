--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.

local ForDeadPlayers = 10
local ForLoseTeam = 50
local ForWinTeam = 100

local function EndRound( winteam )

	for k,v in pairs(player.GetAll()) do
		if ( not IsValid(v) ) then continue end
		if v:Alive() then
			if v:Team() == winteam then
				if ( ForWinTeam == 0 ) then continue end
				Level:AddEXP( v, ForWinTeam )
				v:ChatPrint("You've won and are alive, you get " .. tostring(ForWinTeam) .. " EXP !")
			else
				if ( ForLoseTeam == 0 ) then continue end
				Level:AddEXP( v, ForLoseTeam )
				v:ChatPrint("You lost but you're still alive, you get " .. tostring(ForLoseTeam) .. " EXP !")
			end
		else
			if ( ForDeadPlayers == 0 ) then continue end
			Level:AddEXP( v, ForDeadPlayers )
			v:ChatPrint("You died, but you still get " .. tostring(ForDeadPlayers) .. " EXP !")
		end
	end
end

hook.Add("OnEndOfGame", "Level_EndRound", EndRound)