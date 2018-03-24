AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--[[

	ENT FUNCTIONS

]]--

function ENT:Initialize()
	self:SetModel( "models/weapons/w_eq_flashbang.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )

	self.phys = self:GetPhysicsObject()
	
	if (self.phys:IsValid()) then
		self.phys:Wake()
	end

	-- ENT VARIABLES
	self.hasCalledDrop = false
end

function ENT:Think()
	if !self.hasCalledDrop and self.phys:IsAsleep() then
		self:CallInDrop()

		self.hasCalledDrop = true

		-- Once we've called in the drop we're no longer needed
		timer.Simple( 15, function()
			self:Remove()
		end )
	end	
end

--[[

	ENT META FUNCTIONS

]]--

function ENT:CallInDrop()
	-- Get the boundary of the map then calculate the middle
	local mapBoundsMin, mapBoundsMax = game.GetWorld():GetModelBounds()
	local mapCenter = Vector( math.sqrt( mapBoundsMax.x - mapBoundsMin.x )*2, math.sqrt( mapBoundsMax.y - mapBoundsMin.y )*2, 0 )
	
	-- Get a random direction then find the position on a circle inside the map boundaries
	local randDirection = math.Rand( 0, 360 )
	local flightStartPos = mapCenter + Vector( math.cos( randDirection ) * math.abs( mapBoundsMin.x - mapBoundsMax.x )/2, math.sin( randDirection ) * math.abs( mapBoundsMin.x - mapBoundsMax.x )/2, 500 )
	
	-- Calculate the angle between the spawn position and drop position so plane flies towards the drop
	local flightDirection = ( Vector( self:GetPos().x, self:GetPos().y, 0 ) - Vector( flightStartPos.x, flightStartPos.y, 0 ) ):Angle()

	-- Spawn the plane in and set its drop position
	local planeEnt = ents.Create( "ryl_airdrop_plane" )
	planeEnt:SetPos( flightStartPos  )
	planeEnt:SetAngles( flightDirection )
	planeEnt:Spawn()

	-- Variables for the plane
	planeEnt.dropPos = self:GetPos()
	planeEnt.caller  = self.owner
end