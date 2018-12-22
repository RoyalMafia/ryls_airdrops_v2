AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--[[

	ENT FUNCTIONS

]]--

function ENT:Initialize()
	self:SetModel( "models/drmatt/c130/body.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_NONE )

	self.phys = self:GetPhysicsObject()
	
	if (self.phys:IsValid()) then
		self.phys:Wake()
	end

	-- Variables
	self.Rotors = {}
	self.hasDropped = false
	self.dropDistance = math.random( 50, ryl_airdrop_config.dropRadius )^2
	self.spawnTime = CurTime()

	-- Spawn in props
	self:spawnProps()
end

function ENT:Think()
	-- Spawn the airdrop when close to drop zone
	if self.dropPos != nil then
		-- The airdrop spawns offset to the plane so instead of checking if the center is close check the offset position instead
		if ( ( self:GetPos() - self:GetAngles():Forward() * 500 ) - self.dropPos ):Length2DSqr() < self.dropDistance and !self.hasDropped then
			self:spawnAirdrop( self:GetPos() - self:GetAngles():Forward() * 500 )
			self.hasDropped = true
		end
	end

	-- Will self remove once the plane gets close to the map border and has been alive for more than 2 seconds
	local mapBoundsMin, mapBoundsMax = game.GetWorld():GetModelBounds()
	if !self:GetPos():WithinAABox( mapBoundsMin/1.2, mapBoundsMax/1.2 ) and ( CurTime() - self.spawnTime ) > 2 then
		if !self.hasDropped then
			-- If the plane failed to drop then just spawn above where it should
			self:spawnAirdrop( self.dropPos + Vector( 0, 0, 10 ) )
		end

		self:Remove()
	end
end

function ENT:PhysicsUpdate()
	-- Move the plane forward at a nice speed
	if IsValid( self.phys ) then
		self.phys:SetPos( self:GetPos() + self:GetAngles():Forward() * 30 * FrameTime()*66 )
	end

	-- Spin the propellers
	if #self.Rotors > 0 then
		for k, v in pairs( self.Rotors ) do
			if IsValid( v ) then
				v:SetAngles( self:GetAngles() + Angle( 0, 0, ( CurTime() * 2000 ) * FrameTime()*66 ) )
			end
		end
	end
end

function ENT:OnRemove()
	if #self.Rotors > 0 then
		for k, v in pairs( self.Rotors ) do
			if IsValid( v ) then
				v:Remove()
			end
		end
	end
end

--[[

	ENT META FUNCTIONS

]]--

function ENT:spawnProps()
	-- All of these offsets & function is from WAC, so I have Dr. Matt to thank for this part
	local propOffsets = {
		Vector(140,-228,189.5),
		Vector(140,452,198),
		Vector(140,224,189.5),
		Vector(140,-457,198)
	}

	-- Create the prop entities
	for k, v in pairs( propOffsets ) do
		self.Rotors[k] = ents.Create( "prop_physics" )
		self.Rotors[k]:SetModel( "models/drmatt/c130/propellor.mdl" )
		self.Rotors[k]:SetPos( self:LocalToWorld( v ) )
		self.Rotors[k]:SetAngles( self:GetAngles() )
		self.Rotors[k]:SetParent( self )
		self.Rotors[k]:Spawn()
		self.Rotors[k]:SetNotSolid( true )
		self.Rotors[k].phys = self.Rotors[k]:GetPhysicsObject()
		self.Rotors[k].phys:EnableGravity( false )
		self.Rotors[k].phys:SetMass( 5 )
	end
end

function ENT:spawnAirdrop( pos )
	local newAirdrop = ents.Create( "ryl_airdrop" )
	newAirdrop:SetPos( pos )
	newAirdrop:SetAngles( Angle( 0, math.Rand( -360, 360 ), 0 ) )
	newAirdrop:Spawn()

	-- If a player called in the drop then make sure the airdrop knows that someone called it in
	if self.caller != nil then
		newAirdrop.owner = self.caller
	end
end
