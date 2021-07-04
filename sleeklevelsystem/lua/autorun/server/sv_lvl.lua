--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.

AddCSLuaFile("autorun/client/cl_lvl.lua")

util.AddNetworkString( "Level.ClientFile" )
util.AddNetworkString( "Level.Int_File" )

resource.AddSingleFile( "materials/sleeklvl/def/start.png" )
resource.AddSingleFile( "materials/sleeklvl/def/main.png" )
resource.AddSingleFile( "materials/sleeklvl/def/end.png" )

Level = {}

Level.cvars = {}
Level.cvars.enabled = CreateConVar("level_enabled", "1", FCVAR_ARCHIVE):GetBool() -- Set it to 0 to disable, 1 to enable.
Level.cvars.maxlevel = CreateConVar("level_maxlevel", "200", FCVAR_ARCHIVE):GetInt() -- The highest level you can reach.
Level.cvars.exprate = CreateConVar("level_exprate", "100", FCVAR_ARCHIVE):GetInt() -- The more, the faster you level up.
Level.cvars.expmul = CreateConVar("level_expmul", "8.5", FCVAR_ARCHIVE):GetFloat() -- The amount that is multiplied to calculate the needed exp
Level.cvars.integrate = CreateConVar("level_integrate", "1", FCVAR_ARCHIVE):GetBool() -- Should it try to integrate itself into the gamemode's scoreboards/targetid/... ?
Level.cvars.savemethod = CreateConVar("level_savemethod", "sqlite", FCVAR_ARCHIVE):GetString()

if ( not Level.cvars.enabled ) then
	MsgN("[LVL] Level system disabled.")

	return
else


	MsgN("[LVL] Level system by Leystryku loaded !")
end



cvars.AddChangeCallback( "level_enabled", function( convar_name, oldValue, newValue )

	local bool = GetConVar("level_enabled"):GetBool()

	if ( bool ) then
		MsgN( "[LVL] Enabled." )

		concommand.Add("level_networkvars", Level.NetworkVars)
		concommand.Add("level_reloadhud", Level.ReloadHud)
		concommand.Add("level_forlevel", Level.ForLevel)
		hook.Add("Initialize", "Level.Initialize", Level.Initialize)
	else
		concommand.Remove("level_networkvars")
		concommand.Remove("level_reloadhud")
		concommand.Remove("level_forlevel")
		hook.Remove("Initialize", "Level.Initialize")
		hook.Remove("PlayerInitialSpawn", "Level.PlayerInitialSpawn")

		MsgN( "[LVL] Disabled." )
	end

end )

cvars.AddChangeCallback( "level_integrate", function( convar_name, oldValue, newValue )

	local bool = GetConVar("level_integrate"):GetBool()
	
	if ( bool ) then
		MsgN( "[LVL] Integration enabled" )
		Level.cvars.integrate = true
	else
		MsgN( "[LVL] Integration disabled" )
		Level.cvars.integrate = false
	end

end)

cvars.AddChangeCallback( "level_maxlevel", function( convar_name, oldValue, newValue )

	if ( newValue and tonumber(newValue) ) then
		Level.cvars.maxlevel = tonumber(newValue)
		MsgN( "[LVL] Maximum Level changed: " .. newValue )
	end

end )


cvars.AddChangeCallback( "level_exprate", function( convar_name, oldValue, newValue )

	if ( newValue and tonumber(newValue) ) then
		Level.cvars.exprate = math.Round(tonumber(newValue), 2)
		MsgN( "[LVL] Exp Rate changed: " .. tostring(Level.cvars.exprate) )
	end

end )


cvars.AddChangeCallback( "level_expmul", function( convar_name, oldValue, newValue )

	if ( newValue and tonumber(newValue) ) then
		Level.cvars.expmul = math.Round(tonumber(newValue), 2)
		MsgN( "[LVL] Exp Multiplier changed: " .. tostring(Level.cvars.expmul) )
	end

end )

cvars.AddChangeCallback( "level_savemethod", function( convar_name, oldValue, newValue )
	
	if ( newValue != "sqlite"  and newValue != "mysql" ) then
		MsgN( "[LVL] Invalid save method !")
		return
	end

	Level.cvars.savemethod = newValue

end)

include("lvl_data.lua")

function Level:GetEXP( ply, bool )
	
	if ( not ply or not IsValid(ply) ) then return 0 end
	if ( ply:IsBot() ) then return 0 end

	if ( bool ) then -- don't return cache result
		local hisexp = Level:Data_Get( ply, "level_exp" )
		
		if ( hisexp == "" ) then
			Level:Data_Set( ply, "level_exp", "0" )
			Level:Data_Set( ply, "level_lvl", "1" )
			return -1
		end

		return tonumber(hisexp)
	end
	
	if ( not ply.tmp_EXP ) then
		ply.tmp_EXP = Level:GetEXP( ply, true )
	end

	if ( not ply.tmp_EXP or ply.tmp_EXP == -1 ) then
		Level:Data_Set( ply, "level_exp", "0" )
		Level:Data_Set( ply, "level_lvl", "1" )
		ply.tmp_EXP = 0
	end

	return ply.tmp_EXP

end

function Level:GetLevel( ply )
	
	if ( not ply or not IsValid(ply) ) then return 0 end
	if ( ply:IsBot() ) then return 0 end

	local hislevel = Level:Data_Get( ply, "level_lvl" )
		
	if ( hislevel == "" ) then
		Level:Data_Set( ply, "level_exp", "0" )
		Level:Data_Set( ply, "level_lvl", "1" )
		return 1
	end

	return tonumber(Level:Data_Get( ply, "level_lvl" )) or 0

end

function Level:GetNeededEXP( ply )
	
	if ( not ply or not IsValid(ply) ) then return 100 end
	if ( ply:IsBot() ) then return 1 end

	local base = ply
	
	if ( type(ply) != "number" ) then
		base = Level:GetLevel(ply) 
	end
	
	base = base * 10000
	base = base / Level.cvars.exprate
	base = base * Level.cvars.expmul

	return math.Round(base)

end

function Level:SetEXP( ply, ex )

	if ( not ply or not ex ) then return end
	if ( not Level.cvars.enabled ) then return end
	if ( ply:IsBot() ) then return end

	if ( not ply.tmp_EXP ) then
		ply.tmp_EXP = tonumber(Level:GetEXP( ply, true ))
	end

	ply.tmp_EXP = math.Round(ex) -- We 'cache' EXP, in case someone often calls the SetEXP func.

	umsg.Start("level_update")
	umsg.Entity( ply )
	umsg.Long( Level:GetEXP( ply ) )
	umsg.Long( Level:GetLevel( ply ) )
	umsg.Long( Level:GetNeededEXP( ply ) )
	umsg.End()

	self:CheckLevelUp( ply )

end

function Level:SetLevel( ply, lvl )

	if ( not ply or not lvl ) then return 0 end
	if ( not Level.cvars.enabled ) then return end
	if ( ply:IsBot() ) then return end

	hook.Run( "Level.OnLevelUp", ply, lvl)

	Level:Data_Set( ply, "level_lvl", tostring(math.Round(lvl)) )
	
	umsg.Start("level_update")
	umsg.Entity( ply )
	umsg.Long( Level:GetEXP( ply ) )
	umsg.Long( Level:GetLevel( ply ) )
	umsg.Long( Level:GetNeededEXP( ply ) )
	umsg.End()

end

function Level:AddEXP( ply, ex )

	self:SetEXP( ply, self:GetEXP( ply ) + ex )

end

function Level:TakeEXP( ply, ex )

	self:SetEXP( ply, self:GetEXP( ply ) - ex )

end

function Level:CheckLevelUp( ply )
	
	if ( not ply or not IsValid(ply) ) then return end
	if ( ply:IsBot() ) then return end

	if ( Level:GetEXP(ply) > self:GetNeededEXP( ply ) and self:GetLevel(ply) <= Level.cvars.maxlevel ) then

		self:SetEXP( ply, 0 )
		self:SetLevel( ply, self:GetLevel( ply ) + 1 )

	end

end

function Level.NetworkVars( ply )
	
	if ( not Level.cvars.enabled ) then return end

	if ( not ply or not IsValid(ply) ) then return end
	if ( ply:IsBot() ) then return end

	if ( Level:GetLevel(ply) == 0 ) then
		Level:SetLevel(ply, 1)
	end

	ply.tmp_EXP = tonumber(Level:GetEXP(ply, true))
	
	umsg.Start("level_update")
		umsg.Entity( ply )
		umsg.Long( Level:GetEXP( ply ) )
		umsg.Long( Level:GetLevel( ply ) )
		umsg.Long( Level:GetNeededEXP( ply ) )
	umsg.End()

	for k,v in pairs(player.GetAll()) do
		if(not IsValid(v)) then continue end
		
		timer.Simple( k/4, function() -- To prevent overflows etc.
			if(not IsValid(ply)) then return end
			umsg.Start("level_update", ply)
				umsg.Entity( v )
				umsg.Long( Level:GetEXP( v ) )
				umsg.Long( Level:GetLevel( v ) )
				umsg.Long( Level:GetNeededEXP( v ) )
			umsg.End()
		end)

	end

	timer.Simple(0.7, function()
		
		if ( not ply ) then return end
		if ( not IsValid(ply) ) then return end -- gg
	
		local clfile = "lvl/cl/" .. string.sub(GAMEMODE.Folder, 11 ) .. ".lua"
		local integrate_file = "lvl/cl_int/" .. string.sub(GAMEMODE.Folder, 11 ) .. ".lua"

		if ( file.Exists(clfile, "GAME") ) then
				
			net.Start("Level.ClientFile")
			net.WriteString(file.Read(clfile, "GAME"))
			net.Send(ply)

		else
			
			net.Start("Level.ClientFile")
			net.WriteString(file.Read("lvl/cl/base.lua", "GAME"))
			net.Send(ply)
		end
		
		timer.Simple(0.1, function()
			if ( not ply ) then return end

			if ( Level.cvars.integrate ) then
				if ( file.Exists(integrate_file, "GAME") ) then

					net.Start("Level.Int_File")
					net.WriteString(file.Read(integrate_file, "GAME"))
					net.Send(ply)

				end
			end
		end)

	end)

end

concommand.Add("level_networkvars", Level.NetworkVars)

function Level.ReloadHud( ply, c, args)

	local clfile = "lvl/cl/" .. string.sub(GAMEMODE.Folder, 11 ) .. ".lua"

	if ( file.Exists(clfile, "GAME") ) then

		net.Start("Level.ClientFile")
		net.WriteString(file.Read(clfile, "GAME"))
		net.Send(ply)

	else

		net.Start("Level.ClientFile")
		net.WriteString(file.Read("lvl/cl/base.lua", "GAME"))
		net.Send(ply)
	end
end

concommand.Add("level_reloadhud", Level.ReloadHud)

function Level.ForLevel( ply, c, args )


	if ( not args[1] ) then return end
	if ( not tonumber(args[1]) ) then return end

	if ( not ply ) then return end
	if ( IsValid(ply) and not ply:IsAdmin() ) then return end
	
	ply:ChatPrint( "For Level " .. args[1] .. " you would need " .. tostring(Level:GetNeededEXP( tonumber(args[1]) )) .. " EXP" )


end

concommand.Add("level_forlevel", Level.ForLevel)

Level.Initialized = false
function Level.Initialize( )
	
	if ( Level.Initialized ) then return end

	local gm_file = "lvl/sv/" .. string.sub(GAMEMODE.Folder, 11 ) .. ".lua"

	if ( file.Exists(gm_file, "GAME") ) then

		print("[LVL] Including Gamemode file...")
		RunStringEx(file.Read(gm_file, "GAME"), gm_file)
		Level.Initialized = true

	else
		
		RunStringEx(file.Read("lvl/sv/base.lua", "GAME"), "lvl/sv/base.lua")
		Level.Initialized = true
	end

end

hook.Add("Initialize", "Level.Initialize", Level.Initialize)

function Level.PlayerInitialSpawn( ply )

	timer.Simple(0.1, function() -- since bots dont run the cmd
		if ( ply:IsBot() ) then

			umsg.Start( "level_update" )
				umsg.Entity( ply )
				umsg.Long( Level:GetEXP( ply ) )
				umsg.Long( Level:GetLevel( ply ) )
				umsg.Long( Level:GetNeededEXP( ply ) )
			umsg.End()

		end
	end)

end

hook.Add("PlayerInitialSpawn", "Level.PlayerInitialSpawn", Level.PlayerInitialSpawn)



local saveDelay = 10 -- save cached exp every 10 secs

timer.Create("Level_SaveEXP", saveDelay, 0, function()

	for k,v in pairs(player.GetAll()) do
		if ( v:IsBot() ) then continue end

		Level:Data_Set( v, "level_exp", tostring(Level:GetEXP(v)) or "0" )

	end
	
end)