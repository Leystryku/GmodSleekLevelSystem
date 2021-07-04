--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.

MsgN("[LVL] Level system by Leystryku loaded !")

local ShouldLoad = false


Level = {}



function Level.UserMessage( um )

	local ent = um:ReadEntity()
	local xp = um:ReadLong()
	local lvl = um:ReadLong()
	local nexp = um:ReadLong()
	

	if ( not ent or not IsValid(ent) ) then return end

	if ( Level.FinishedLoading ) then
		if ( ent.Level and ent.Level != 0 and ent.Level != lvl ) then
			hook.Run( "Level.OnLevelUp", ent, lvl )
		end
	end

	ent.Level = lvl
	ent.EXP = xp
	ent.Next_EXP = nexp

end

usermessage.Hook("level_update", Level.UserMessage)

function Level.RunIntegrationFile( len )
	
	if ( not Level.IntegrationFile ) then
		Level.IntegrationFile = net.ReadString()
	end
	
	if ( not Level.IntegrationFile ) then return end

	if ( not ShouldLoad ) then
		timer.Simple(0.5, Level.RunIntegrationFile( ) )
		
		return
	end
		
	if ( LocalPlayer() and IsValid(LocalPlayer()) ) then
		MsgN("[LVL] Running Integration File...")
		
		for k,v in pairs(player.GetAll()) do -- Just for safety.
			v.Level = v.Level or 0
			v.EXP = v.EXP or 0
			v.Next_EXP = v.Next_EXP or 1
		end

		RunStringEx( Level.IntegrationFile, "[LVL] Integration File" )
	else

		Level.RunIntegrationFile( )

	end


end

net.Receive("Level.Int_File", Level.RunIntegrationFile)

function Level.RunClientFile( len )
	
	if ( not Level.ClientFile ) then
		Level.ClientFile = net.ReadString()
	end
	
	if ( not Level.ClientFile ) then return end

	if ( not ShouldLoad ) then
		timer.Simple(0.5, Level.RunClientFile( ) )
		
		return
	end
		
	if ( LocalPlayer() and IsValid(LocalPlayer()) ) then
		MsgN("[LVL] Running Client File...")
		
		for k,v in pairs(player.GetAll()) do -- Just for safety.
			v.Level = v.Level or 0
			v.EXP = v.EXP or 0
			v.Next_EXP = v.Next_EXP or 1
		end

		RunStringEx( Level.ClientFile, "[LVL] Client File" )
		Level.FinishedLoading = true
	else
			
		Level.RunClientFile( )
			
	end


end

net.Receive("Level.ClientFile", Level.RunClientFile)

function Level.InitPostEntity()

	RunConsoleCommand("level_networkvars")

	ShouldLoad = true

end

hook.Add("InitPostEntity", "Level.InitPostEntity", Level.InitPostEntity)
