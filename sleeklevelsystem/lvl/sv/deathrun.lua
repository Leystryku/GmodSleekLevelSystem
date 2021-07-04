--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.

local giveallexp = false

hook.Add( "OnRoundSet", "Level.OnRoundSet", function( round, winner )


	if(giveallexp) then
		for k,v in pairs(player.GetAll()) do
			Level:AddEXP(v, 100)
		end
	else
		for k,v in pairs(player.GetAll()) do
			if(v:Team()!=winner) then continue end
			Level:AddEXP(v, 100)
		end
	end

end)