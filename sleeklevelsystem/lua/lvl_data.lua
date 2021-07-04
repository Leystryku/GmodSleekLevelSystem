--Copyright 2013-2015 - Leystryku
--Sharing this software, or re-selling it is a break against the law.

local Mysql_Hostname 	= "ip"
local Mysql_Username 	= "username"
local Mysql_Password 	= "password"
local Mysql_Database 	= "database"
local Mysql_Port		= 3306 -- 3306 = default mysql port

local MysqlDB


local Mysql_CreateQuery = "INSERT INTO leveldata (`steamid`, `data`) VALUES('%s', '%s')" -- first s = steamid64, second s = startdata
local Mysql_CheckQuery	= "SELECT * FROM `leveldata` WHERE steamid='%s'" -- first s = steamid64
local Mysql_GetQuery	= "SELECT `data` FROM `leveldata` WHERE `steamid`='%s'" -- first s = steamid64
local Mysql_SetQuery	= "UPDATE `leveldata` SET `data`='%s' WHERE `steamid`='%s'" -- first s = set to, second s = steamid64




local function InitializeMysqlDB()

	if(Level.cvars.savemethod != "mysql") then
		print("no mysql4u")
		return
	end

	if(not tmysql) then require ("tmysql4") if (not tmysql) then return end end
	if ( MysqlDB ) then return end
	
	local db, err = tmysql.initialize( Mysql_Hostname, Mysql_Username, Mysql_Password, Mysql_Database, Mysql_Port )

	if ( not db ) then
		MsgC( Color(255,0,0), "[LVL] Crticial Error: Could not connect to mysql database - " .. err )
		return
	end

	MysqlDB:Query( "CREATE TABLE IF NOT EXISTS `leveldata` ( `steamid` varchar(50)  NOT NULL, `data` varchar(300) NOT NULL PRIMARY KEY)")
	
	MysqlDB = db
	print("[LVL] Connected to mysql db!")

end

hook.Add("Initialize", "Level_Mysql_Init", function()

	if(Level.cvars.savemethod != "mysql") then
		return
	end

	timer.Simple(0.1, function()
		if(not MysqlDB) then InitializeMysqlDB() end
	end)
end)

hook.Add("PlayerInitialSpawn", "Level_Mysql_CheckPlayer", function(p)
	if(Level.cvars.savemethod != "mysql") then
		return
	end

	if(not MysqlDB) then InitializeMysqlDB() end

	local formatted = string.format(Mysql_CheckQuery, sql.SQLStr(tostring(p:SteamID64())))
	
	MysqlDB:Query( formatted, function( results )

		if(results and results[1] and results[1].data and results[1].data["data"]) then
			return
		end

		print("Creating new mysql data for: " .. p:Nick())

		formatted = string.format(Mysql_CreateQuery, sql.SQLStr(tostring(p:SteamID64())), [[{"level_exp":0",level_lvl":"1"}]])

		MysqlDB:Query( formatted )

	end)

end)

-- Get Data Funcs

local function SQLiGet( ply, str )
	if ( not ply ) then return end

	return ply:GetPData( str )
end

local function MysqlCreate( ply, str )

	if ( not ply ) then return end
	
	local deer = string.format(  Mysql_CreateQuery, ply:SteamID64(), str )

	MysqlDB:Query( deer )

end

local function MysqlGet( ply, str )
	if ( not ply ) then return end

	if ( not MysqlDB ) then InitializeMysqlDB() end

	if ( not MysqlDB ) then MsgC( Color(255,0,0), "[LVL] Critical Error: Couldn't initialize Mysql DB !!!" ) return false end

	local ret = ""
	
	local formatted = string.format(Mysql_GetQuery, sql.SQLStr(tostring(p:SteamID64())))
	
	MysqlDB:Query( formatted, function( results )

		if(not results or not results[1] or not results[1].data or not results[1].data["data"]) then
			print("[LVL] No LVL Data for player: " .. ply:Nick())
			return
		end

		local json = results[1].data["data"]
		local tbl = util.JSONToTable(json)

		if(tbl[str]) then
			ret = tbl[str]
		end

	end)
	
	return ret
end

-- Set Data Funcs

local function SQLiSet( ply, str1, str2 )
	if ( not ply ) then return end

	return ply:SetPData( str1, str2 )
end

local function MysqlSet( ply, str1, str2 )
	if ( not ply ) then return end
	if ( not MysqlDB ) then InitializeMysqlDB() end

	if ( not MysqlDB ) then MsgC( Color(255,0,0), "[LVL] Critical Error: Couldn't initialize Mysql DB !!!" ) return false end

	local ret = ""
	
	local formatted = string.format(Mysql_GetQuery, sql.SQLStr(tostring(p:SteamID64())))
	
	MysqlDB:Query( formatted, function( results )

		if(not results or not results[1] or not results[1].data or not results[1].data["data"]) then
			print("[LVL] No LVL Data for player: " .. ply:Nick())
			return
		end

		local json = results[1].data["data"]
		local tbl = util.JSONToTable(json)
		tbl[str1] = str2

		formatted = string.format(Mysql_SetQuery, sql.SQLStr(util.TableToJSON(tbl)), sql.SQLStr(tostring(p:SteamID64())))

		MysqlDB:Query(formatted)

	end)
	
	return ret
end


--globalization

function Level:Data_Get( ply, str )

	local savemethod = Level.cvars.savemethod
	
	local ret

	if ( savemethod == "sqlite" ) then
	
		ret = SQLiGet( ply, str )
		
	elseif ( savemethod == "mysql" ) then
		
		ret = MysqlGet( ply, str )
		
	end

	return ret
end

function Level:Data_Set( ply, str1, str2 )

	local savemethod = Level.cvars.savemethod

	if ( savemethod != "sqlite" and savemethod != "mysql" ) then
		RunConsoleCommand("level_savemethod", "sqlite")
		savemethod = sqlite
	end
	
	local ret

	if ( savemethod == "sqlite" ) then
	
		ret = SQLiSet( ply, str1, str2 )
		
	elseif ( savemethod == "mysql" ) then
		
		ret = MysqlSet( ply, str1, str2 )
		
	end

	return ret
end
