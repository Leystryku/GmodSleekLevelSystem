--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.

local expnpcs = { "npc_zombie", "npc_zombie_torso", "npc_fastzombie", "npc_fastzombie_torso", "npc_zombine", "npc_poisionzombie", 
					"npc_headcrab", "npc_headcrab_fast", "npc_headcrab_poison", "npc_antlion", "npc_antlionguard",
					"npc_barnacle", "npc_crow" }

hook.Add("OnNPCKilled", "Level_OnNPCKilled", function( npc, attacker, inf )

	if ( not attacker or not npc ) then return end
	
	if ( not IsValid(attacker) ) then return end
	
	if ( not attacker.IsPlayer or not attacker:IsPlayer() ) then return end
	
	if ( not npc.GetClass or not npc:GetClass() ) then return end 
	
	for k,v in pairs(expnpcs) do
		if ( npc:GetClass() == v ) then
			Level:AddEXP( attacker, 350 )
		end
	end


end)

local function PlayerDeath( ply, inflictor, attacker )

	if ( attacker and IsValid(attacker) and attacker:IsPlayer() and attacker != ply ) then
		Level:AddEXP( attacker, 500 )
	end

end

hook.Add("PlayerDeath", "Level_PlayerDeath", PlayerDeath)