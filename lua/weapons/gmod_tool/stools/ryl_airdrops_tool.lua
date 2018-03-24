--[[
	
	TOOL SETTINGS

]]--

TOOL.Category    = "ryl's shit"
TOOL.Name        = "Airdrop Position"
TOOL.Description = "Create/Remove Airdrop positions"

--[[

	NET MESSAGES

]]--

if SERVER then
	util.AddNetworkString( "ryl_airdrop_tool_update_positions" )
end

--[[

	VARIABLES

]]--

if CLIENT then
	TOOL.hasCreatedHook = false
end

if SERVER then
	TOOL.userCanUse = false
end

--[[

	PRECACHE SOUNDS

]]--

util.PrecacheSound("weapons/pistol/pistol_empty.wav") 

--[[

	LANGUAGE SETTINGS

]]--

if CLIENT then
	language.Add( "tool.ryl_airdrops_tool.name", "ryl's airdrop position" )
	language.Add( "tool.ryl_airdrops_tool.desc", "Create/Remove Airdrop positions" )
	language.Add( "tool.ryl_airdrops_tool.0", "Left Click creates a airdrop position / Right Click removes airdrop position" )
end

--[[

	FUNCTIONS

]]--

local function checkPlyRank( ply )
	for k, v in pairs( ryl_airdrop_config.ranks ) do
		if ply:GetUserGroup() == v then
			return true
		end
	end
end

local function drawStencilSphere( pos, ref, compare_func, radius, color, detail )
	if CLIENT then
		render.SetStencilReferenceValue( ref )
		render.SetStencilCompareFunction( compare_func )
		render.DrawSphere( pos, radius, detail, detail, color )
	end
end

--[[

	TOOL FUNCTIONS

]]--

function TOOL:DrawToolScreen( width, height )
	if CLIENT then
		surface.SetDrawColor( Color( 20, 20, 20 ) )
		surface.DrawRect( 0, 0, width, height )

		draw.SimpleText( "Left Click to create a position", "Trebuchet18", 5, 15, Color( 200, 200, 200 ), 0, 0 )
		draw.SimpleText( "Right Click to remove a position", "Trebuchet18", 5, 35, Color( 200, 200, 200 ), 0, 0 )
		draw.SimpleText( "If the positions don't show re-equip", "Trebuchet18", 5, 55, Color( 200, 200, 200 ), 0, 0 )
	end
end

function TOOL:Deploy()
	if SERVER then
		self.userCanUse = checkPlyRank( self:GetOwner() )

		if !self.userCanUse then
			self:GetOwner():SendLua( 'chat.AddText( Color( 240, 40, 40 ), "[ ryl\'s airdrops ]", Color( 255, 255, 255 ), " Invalid rank to use tool!" )' )
		else
			self:sendPositions()
		end
	end

	if CLIENT then
		if !self.hasCreatedHook then
			-- Create the hook to draw circle stencils
			hook.Add( "PostDrawTranslucentRenderables", "drawPositionCircles"..self:GetOwner():EntIndex(), function() 
				-- Draw a stencil where the owner is aiming
				self:drawCircle( self:GetOwner():GetEyeTrace().HitPos, Color( 40, 240, 40, 100 ) ) 

				-- Draw the other points if there are any
				if cl_ryl_airdrop_positions != nil then
					for k, v in pairs( cl_ryl_airdrop_positions ) do
						self:drawCircle( v, Color( 240, 40, 40, 100 ) )
					end
				end
			end )

			self.hasCreatedHook = true
		end
	end
end

function TOOL:Holster()
	if CLIENT then
		if self.hasCreatedHook then
			-- Remove the hook when holstered
			hook.Remove( "PostDrawTranslucentRenderables", "drawPositionCircles"..self:GetOwner():EntIndex() )

			self.hasCreatedHook = false
		end
	end
end

function TOOL:LeftClick( trace )
	-- Left click adds drop position
	if SERVER then 
		if !self.userCanUse then return end 

		self:addPosition( trace.HitPos )
	end

	return true
end

function TOOL:RightClick( trace )
	-- Right click removes the closest point to where the player is aiming
	if SERVER then
		if !self.userCanUse then return end

		self:removePosition( trace.HitPos )
	end

	return true
end

function TOOL:Reload()
	-- Reload toggles the display of the points
	self.isDisplayingPoints = !self.isDisplayingPoints

	if self.isDisplayingPoints then

	end

	return false
end

--[[

	TOOL META FUNCTIONS

]]--

function TOOL:sendPositions()
	net.Start( "ryl_airdrop_tool_update_positions" )
		net.WriteTable( ryl_airdrop_positions )
	net.Send( self:GetOwner() )
end

function TOOL:addPosition( pos )
	if SERVER then
		if self.userCanUse then
			-- Notify the player
			self:GetOwner():SendLua( 'chat.AddText( Color( 240, 40, 40 ), "[ ryl\'s airdrops ]", Color( 255, 255, 255 ), " Added new position" )' )

			-- Add the new position to the table
			table.insert(  ryl_airdrop_positions, pos )

			-- Save the new position in the SQL table
			sql.Query( "BEGIN" )
				sql.Query( "INSERT INTO ryl_airdrop_positions_sql_"..game.GetMap().."( strVector ) VALUES( '".. pos.x .. " " .. pos.y .. " " .. pos.z .. "' )" )
			sql.Query( "COMMIT" )

			-- Send the updated table to the TOOL owner
			self:sendPositions()
		end
	end
end

function TOOL:removePosition( pos )
	if SERVER then
		for k, v in pairs( ryl_airdrop_positions ) do
			if ( v - pos ):Length() < ryl_airdrop_config.dropRadius then
				-- Notify the player
				self:GetOwner():SendLua( 'chat.AddText( Color( 240, 40, 40 ), "[ ryl\'s airdrops ]", Color( 255, 255, 255 ), " Removed position" )' )

				-- Remove position from live table
				table.remove( ryl_airdrop_positions, k )

				-- Remove position from saved table
				sql.Query( "BEGIN" )
					sql.Query( "DELETE FROM ryl_airdrop_positions_sql_"..game.GetMap().." WHERE strVector='".. v.x .. " " .. v.y .. " " .. v.z .. "'" )
				sql.Query( "COMMIT" )

				-- Send updated positions to the TOOL owner
				self:sendPositions()

				return
			end
		end

		-- We didn't find a position
		self:GetOwner():SendLua( 'chat.AddText( Color( 240, 40, 40 ), "[ ryl\'s airdrops ]", Color( 255, 255, 255 ), " Unable to find near position" )' )
	end
end

function TOOL:drawCircle( origin, colour )
	if CLIENT then
		local mat = Material( "particle/particle_ring_wave_additive" )
		local dropRadius = ryl_airdrop_config.dropRadius/4.7

		cam.Start3D2D( origin + Vector( 0, 0, 1 ), Angle( 0, 0, 0 ), 10 )
			surface.SetDrawColor( colour )
			surface.SetMaterial( mat )
			surface.DrawTexturedRect( -dropRadius/2, -dropRadius/2, dropRadius, dropRadius )
		cam.End3D2D()
	end
end

--[[

	NET MESSAGE HANDLING

]]--

if CLIENT then
	net.Receive( "ryl_airdrop_tool_update_positions", function()
		cl_ryl_airdrop_positions = net.ReadTable()
	end)
end