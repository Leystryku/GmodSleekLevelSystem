--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.


--Not tested, pretty shity right now in my opinion. Gotta improve that gamemode file.

timer.Simple(4, function()
local meta = FindMetaTable("Player")

local oaddfrags = meta.AddFrags

function meta:AddFrags( num )
	
	if ( self and IsValid(self) and num > 0 ) then
		if ( TEAM_UNDEAD and self:Team() == TEAM_UNDEAD ) then
			Level:AddEXP( self, 100 )
		else
			Level:AddEXP( self, 10 )
		end
	end

	return oaddfrags(self, num)
end

local oredeem = meta.Redeem

function meta:Redeem()
	Level:AddEXP( self, 250 )

	return oredeem(self)
end
end)