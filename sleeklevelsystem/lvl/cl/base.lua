--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.

local lply = LocalPlayer()

surface.CreateFont( "Level_Base_EXPHudFont1", {
 font = "Coolvetica",
 size = 30,
 weight = 600,
 blursize = 0.1,
 scanlines = 0,
 antialias = true,
 strikeout = true,
 shadow = false,
 additive = true,
 outline = false
} )

surface.CreateFont( "Level_Base_EXPHudFont2", {
 font = "Arial",
 size = 15,
 weight = 600,
 scanlines = 0,
 antialias = true,
 strikeout = false,
 shadow = false,
 additive = false,
 outline = false
} )

local OnlyShowAlive = false -- Should the EXP HUD only show when the player is alive?

local x, y, w, h, x2, y2, w2, x3, w3

local function Refresh()

	x = ScrW()/3
	y = 40
	w = x*1.80
	h = 20
	x2 = x + 60
	y2 = y + 2
	w2 = w/2.6
	x3 = x*1.15
	w3 = x/1.45 / 100

	if ( ScrW() > 630 ) then
		w3 = x/1.54 / 100
	end

	if ( ScrW() > 700 ) then
		w3 = x/1.51 / 100
	end

	if ( ScrW() > 900 ) then
		x3 = x*1.25
		w2 = w/2.8
		w3 = x/1.48 / 100
	end

	if ( ScrW() > 1200 ) then
		w2 = w/2.5
		w3 = x/1.45 / 100
		x3 = x * 1.211
	end

	if ( ScrW() > 1300 ) then
		x3 = x * 1.199
	end

	if ( ScrW() > 1500 ) then
		w3 = x/1.45 / 100
		x3 = x*1.169
	end
	
	if ( ScrW() > 1700 ) then
		w3 = x/1.36 / 100
		x3 = x*1.141
	end

end

local mat_level_start = Material("sleeklvl/def/start.png", "nocull")
local mat_level_main = Material("sleeklvl/def/main.png", "nocull")
local mat_level_end = Material("sleeklvl/def/end.png", "nocull")

timer.Create("Level_BaseEXPHud_ScrSize", 3, 0, function()

	Refresh()

end)

local ScoreboardOpen = false
local round = math.Round
local setdrawcolor = surface.SetDrawColor
local drawrect = surface.DrawRect
local drawtextrect = surface.DrawTexturedRect
local setmaterial = surface.SetMaterial
local setfont = surface.SetFont
local settextcolor = surface.SetTextColor
local settextpos = surface.SetTextPos
local drawtext = surface.DrawText

local Colors = {} -- you can add new colors to this table
Colors[1] = Color(93, 188, 210, 255)
Colors[2] = Color(102, 51, 153, 255)
Colors[3] = Color(200,0,0,255)
Colors[4] = Color(25, 25, 12)

local OnlyScoreboardShow = false -- Only show the level sys when the scoreboard is open

local selectedcolor = Colors[2] -- change the number here, to change the color !

hook.Add("HUDPaint", "Level_BaseEXPHud", function()
	
	if ( not x or not y or not w or not h ) then
		Refresh()

		return
	end
	
	if ( not lply ) then
		return
	end

	local exp = lply.EXP or 225--3
	local nextexp = lply.Next_EXP or 4250--3
	local lvl = lply.Level or 5--0
	
	if ( not exp or not nextexp or not lvl ) then return end
	if ( OnlyShowAlive and not lply:Alive() ) then return end

	if ( OnlyScoreboardShow and not ScoreboardOpen ) then return end

	local percent = exp / nextexp
	percent = percent * 100
	percent = round(percent)

	local wmain = w3 * ((percent/100)*100)

	setdrawcolor(selectedcolor)

	drawrect(x3,y2, wmain,h*1.20)

	setdrawcolor( 255, 255, 255, 255 ) 
	setmaterial( mat_level_main )

	drawtextrect( x2, y2, w2, 28 )

	setdrawcolor( 255, 255, 255, 255 ) 
	setmaterial( mat_level_start )
	drawtextrect( x+30, y*1.05, 60, 28 )

	setdrawcolor( 255, 255, 255, 255 ) 
	setmaterial( mat_level_end	)
	drawtextrect( x*1.80, y*1.05, 60, 28 )

	setfont( "Level_Base_EXPHudFont1" )
	settextcolor( 255,255,255,255 )
	settextpos( x2, y*1.05) 
	drawtext( lvl )

	
	setfont( "Level_Base_EXPHudFont2" )
	settextcolor( 255,255,255,255 )
	settextpos( x+w*0.25, y + 8 ) 
	drawtext( exp.."/" .. nextexp .. " - " .. percent .. "%" )

end)

hook.Add("ScoreboardShow", "Level.ScoreboardOpen", function()
	
	ScoreboardOpen = true

end)

hook.Add("ScoreboardHide", "Level.ScoreboardOpen", function()
	
	ScoreboardOpen = false

end)


