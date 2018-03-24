include( 'shared.lua' )

--[[

	ENT FUNCTIONS

]]--

function ENT:Initialize()
	self:playEngineSound()

	self.audioSource = nil
end

function ENT:Think()
	if IsValid( self.audioSource ) then
		local newVol = ( self:GetPos() - LocalPlayer():GetPos() ):Length() / 25000
		self.audioSource:SetVolume( math.Clamp( 0.8 - newVol, 0 , 1 ) )

		-- Weird bug where sound glitches out upon creation so don't enable it at creation
		if !self.isAudioPlaying then
			self.audioSource:Play()
			self.isAudioPlaying = 1
		end
	end
end

function ENT:OnRemove()
	if IsValid( self.audioSource ) then
		self.audioSource:Stop()
	end
end

--[[

	ENT META FUNCTIONS

]]--

function ENT:playEngineSound()
	sound.PlayFile( "sound/wac/c130/external.wav", "mono noplay", function( source, err, errname )
		if IsValid( source ) then
			self.audioSource = source
			self.audioSource:SetVolume( 0 )
			self.audioSource:EnableLooping( true )
			self.isAudioPlaying = false
		end
	end )
end