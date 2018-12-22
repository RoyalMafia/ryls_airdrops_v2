--[[

	VARS

]]--

ryl_airdrop_positions = {}

--[[

	SQL MANAGEMENT

]]--

local function sqlInit()
	-- Let the engine know we about to execute queries
	sql.Query( "BEGIN" )

	-- First check to see if the SQL position table exists
	if sql.TableExists( "ryl_airdrop_positions_sql_"..game.GetMap() ) then
		-- Get all positions from table and insert them into the lua table
		local sqlQueryTable = sql.Query( "SELECT strVector FROM ryl_airdrop_positions_sql_"..game.GetMap() )

		-- If the variable isn't nil then there are items in the table
		if sqlQueryTable != nil then
			for k, v in pairs( sqlQueryTable ) do
				local strArray = string.Explode( " ", v.strVector )
				table.insert( ryl_airdrop_positions, Vector( tonumber( strArray[1], 10 ), tonumber( strArray[2], 10 ), tonumber( strArray[3], 10 ) ) )
			end
		end
	else
		-- Create the table
		sql.Query( "CREATE TABLE ryl_airdrop_positions_sql_"..game.GetMap().."( strVector TEXT )" )
	end

	-- Let the system know we've finished
	sql.Query( "COMMIT" )
end

sqlInit()

--[[

	FUNCTIONS

]]--

function getPlaneStartPos( posToDrop )
	local startPos = Vector( 0, 0, 0 )
	local flightDir = Angle( 0, 0, 0 )

	-- Get the boundary of the map then calculate the middle
	local mapBoundsMin, mapBoundsMax = game.GetWorld():GetModelBounds()
	local mapCenter = Vector( math.sqrt( mapBoundsMax.x - mapBoundsMin.x )*2, math.sqrt( mapBoundsMax.y - mapBoundsMin.y )*2, 0 )

	-- Get a random direction then find the position on a circle inside the map boundaries
	local randDirection = math.Rand( 0, 360 )
	local startPos = mapCenter + Vector( math.cos( randDirection ) * math.abs( mapBoundsMin.x - mapBoundsMax.x )/2, math.sin( randDirection ) * math.abs( mapBoundsMin.x - mapBoundsMax.x )/2, math.Clamp( mapBoundsMax.z/1.2, 0, 4000 ) )
	
	-- Calculate the angle between the spawn position and drop position so plane flies towards the drop
	local flightDir = ( Vector( posToDrop.x, posToDrop.y, 0 ) - Vector( startPos.x, startPos.y, 0 ) ):Angle()

	return startPos, flightDir
end

local function checkPlyRank( ply, ranktable )
	for k, v in pairs( ranktable ) do
		if ply:GetUserGroup() == v then
			return true
		end
	end
end

local function spawnDrop()
	if #ryl_airdrop_positions > 0 then
		-- Select a position from the list
		local posToDrop = ( #ryl_airdrop_positions > 1 and ryl_airdrop_positions[math.random( 1, #ryl_airdrop_positions )] or ryl_airdrop_positions[1] )


		local flightStartPos, flightDirection = getPlaneStartPos( posToDrop )

		-- Spawn the plane in and set its drop position
		local planeEnt = ents.Create( "ryl_airdrop_plane" )
		planeEnt:SetPos( flightStartPos  )
		planeEnt:SetAngles( flightDirection )
		planeEnt:Spawn()
		planeEnt.dropPos = posToDrop

		return true
	end
end

--[[

	SPAWN TIMER

]]--

if !timer.Exists( "ryl_airdrop_drop_timer" ) then
	timer.Create( "ryl_airdrop_drop_timer", ryl_airdrop_config.dropRate*60, 0, function() spawnDrop() end)
end

--[[

	HOOKS

]]--

hook.Add( "PlayerSay", "ryl_airdrop_add_pos", function( ply, txt )
	-- Chat command for forcing a drop
	if checkPlyRank( ply, ryl_airdrop_config.ranks ) then
		if string.lower( txt ) == "!forcedrop" then
			if spawnDrop() then
				ply:SendLua( 'chat.AddText( Color( 240, 40, 40 ), "[ ryl\'s airdrops ]", Color( 255, 255, 255 ), " Called in airdrop" )' )
			else
				ply:SendLua( 'chat.AddText( Color( 240, 40, 40 ), "[ ryl\'s airdrops ]", Color( 255, 255, 255 ), " No airdrop positions" )' )
			end

			return false
		end
	end
end )
