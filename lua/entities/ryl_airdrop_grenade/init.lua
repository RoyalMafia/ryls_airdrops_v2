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

	-- Network Vars
	self:SetisSleeping( false )
end

function ENT:Think()
	if !self.hasCalledDrop and self.phys:IsAsleep() then
		-- Starts the smoke gen clientside
		self:SetisSleeping( true )

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
	-- Get position and direction
	local flightStartPos, flightDirection = getPlaneStartPos( self:GetPos() )

	-- Spawn the plane in and set its drop position
	local planeEnt = ents.Create( "ryl_airdrop_plane" )
	planeEnt:SetPos( flightStartPos  )
	planeEnt:SetAngles( flightDirection )
	planeEnt:Spawn()

	-- Variables for the plane
	planeEnt.dropPos = self:GetPos()
	planeEnt.caller  = self.owner
end
