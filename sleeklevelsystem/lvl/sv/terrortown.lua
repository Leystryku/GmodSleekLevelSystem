--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.



local AddEXPToTraitors = {}
local AddEXPToInnos = {}

local EXPPerTraitorDeath = 200 -- Whenever an innocent guy kills a traitor he gets this amount of EXP
local EXPPerInnoDeath = 75 -- Whenever an traitor kills a innocent guy he gets this amount of EXP


local oSetRoundState = SetRoundState


function Level.GivePlayersRoundEXP()

	for k,v in pairs(AddEXPToInnos) do

		if ( not k or not IsValid(k) or not k:IsPlayer() ) then continue end

		Level:AddEXP(k, v)
		
		k = nil
	
	end
	
	for k,v in pairs(AddEXPToTraitors) do

		if ( not k or not IsValid(k) or not k:IsPlayer() ) then continue end

		Level:AddEXP(k, v)
		
		k = nil
	
	end

end

function SetRoundState(state)

	if ( state == ROUND_POST ) then
		
		timer.Simple(0, function()
			Level.GivePlayersRoundEXP()
		end)

	end

	return oSetRoundState(state)
end


local function isWrong( ply, attacker )

	if ( not ply or not attacker or not IsValid(ply) or not IsValid(attacker) or not ply:IsPlayer() or not attacker:IsPlayer() ) then
		return true
	end
	
	if ( ply:GetRole() == attacker:GetRole() ) then
		return true
	end
	
	if ( ply:GetRole() == ROLE_INNOCENT and attacker:GetRole() == ROLE_DETECTIVE ) then
		return true
	end
	
	if ( ply:GetRole() == ROLE_DETECTIVE and attacker:GetRole() == ROLE_INNOCENT ) then
		return true
	end
	
	return false
end


local function PlayerDeath( ply, inflictor, attacker )

	if ( attacker and IsValid(attacker) and attacker:IsPlayer() and attacker != ply ) then
		
		if ( isWrong( ply, attacker) ) then
			return
		end
		
		if ( ply:IsTraitor() ) then

			if ( not AddEXPToInnos[attacker] ) then
				AddEXPToInnos[attacker] = 0
			end

			AddEXPToInnos[attacker] = EXPPerTraitorDeath
		else

			if ( not AddEXPToTraitors[attacker] ) then
				AddEXPToTraitors[attacker] = 0
			end

			AddEXPToTraitors[attacker] = EXPPerInnoDeath
		end

	end

end

hook.Add("PlayerDeath", "Level_PlayerDeath", PlayerDeath)