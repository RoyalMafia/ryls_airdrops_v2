include( 'shared.lua' )

--[[

	ENT FUNCTIONS

]]--

function ENT:Initialize()
	-- Create the particle emitter
	self.PE = ParticleEmitter( self:GetPos(), false )
end

function ENT:Think()
	if self:GetisSleeping() then
		self:createParticle( self.PE, self:GetPos() + self:GetAngles():Up() * 9, Vector( 0, 0, 30 + math.cos( CurTime() * math.random( 1, 5 ) ) * 3 ) + self:GetAngles():Up() * 10, 5, Color( 220, 40, 40 ) )
	end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	-- End the particle emitter
	self.PE:Finish()
end

--[[

	ENT META FUNCTIONS

]]--

function ENT:createParticle( p_emitter, pos, vel, life, col )
	local new_p = p_emitter:Add( "particle/smokesprites_0006", pos )

	new_p:SetColor( col.r, col.g, col.b )
	new_p:SetVelocity( vel )
	new_p:SetDieTime( life )
    new_p:SetLifeTime( 0 )
    new_p:SetStartSize( 2 )
    new_p:SetEndSize( math.random( 30, 50 ) )
    new_p:SetStartAlpha( 20 )
    new_p:SetEndAlpha( 0 )
end
