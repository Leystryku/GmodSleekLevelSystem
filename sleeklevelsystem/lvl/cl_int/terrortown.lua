local function ShowLevel( pnl )
	pnl:AddColumn( "Level", function( ply, label )
	
		label:SetTextColor( Color(255,255,255,255) )

		if ( ply.Level ) then
			return tostring(ply.Level)
		end
		
		return "1"
	end)
end
hook.Add( "TTTScoreboardColumns", "Level.TTTScoreboardColumns", ShowLevel )