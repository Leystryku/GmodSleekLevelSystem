--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.

local CATEGORY_NAME = "Levels"

------------------------------ SetLevel ------------------------------
function ulx.setlevel( calling_ply, target_plys, level )
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]

		if ( not Level ) then continue end
		
		Level:SetLevel( v, level )
		
		table.insert( affected_plys, v )
	end

	ulx.fancyLogAdmin( calling_ply, "#A set #T level to #i.", affected_plys, level )
end

local setlevel = ulx.command( CATEGORY_NAME, "ulx setlevel", ulx.setlevel, "!setlevel" )
setlevel:addParam{ type=ULib.cmds.PlayersArg }
setlevel:addParam{ type=ULib.cmds.NumArg, hint="The level the player should get.", min=1, default=1 }
setlevel:defaultAccess( ULib.ACCESS_ADMIN )
setlevel:help( "Sets the level of a player." )

------------------------------ Set EXP ------------------------------
function ulx.setexp( calling_ply, target_plys, exp )
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]

		if ( not Level ) then continue end
		
		Level:SetEXP( v, exp )
		
		table.insert( affected_plys, v )
	end

	ulx.fancyLogAdmin( calling_ply, "#A set #T exp to #i.", affected_plys, exp )
end

local setexp = ulx.command( CATEGORY_NAME, "ulx setexp", ulx.setexp, "!setexp" )
setexp:addParam{ type=ULib.cmds.PlayersArg }
setexp:addParam{ type=ULib.cmds.NumArg, hint="The exp the player should get.", min=1, default=1 }
setexp:defaultAccess( ULib.ACCESS_ADMIN )
setexp:help( "Sets the exp of a player." )