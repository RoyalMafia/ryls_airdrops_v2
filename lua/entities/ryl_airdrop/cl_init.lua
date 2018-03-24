include( 'shared.lua' )

--[[

	VARIABLES

]]--

local isMenuOpen = false

--[[

	FONTS

]]--

surface.CreateFont( "rylfont1", { font = "Arial", size = 60, weight = 600, blursize = 1, scanlines = 0, antialias = true } );

--[[

	ENT FUNCTIONS

]]--

function ENT:Initialize()
	self.isFalling = false
	self.dieTime   = CurTime() + ryl_airdrop_config.dropLife

	-- Create the particle emitter
	self.PE = ParticleEmitter( self:GetPos(), false )

	-- Setup the variables
	self.randDirection = math.random( 0, 360 )
	self.windDirection = Vector( math.cos( self.randDirection ) * math.random( 30, 50 ), math.sin( self.randDirection ) * math.random( 30, 50 ), 0 ) 
end

function ENT:Think()
	-- Trace to check how far away the crate is from the floor
	local airdropTrace = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + Vector( 0, 0, -1 ) * 100000,
		filter = self
	})

	-- Crate distance checks
	self.distanceToFloor = ( self:GetPos() - airdropTrace.HitPos ):Length()
	self.isFalling = self.distanceToFloor < 100
	self.isOnGround = self.distanceToFloor < 50

	if self.distanceToFloor < 700 and !self.hasParachute then
		-- If the airdrop is close enough to the floor create a parachute model above it
		self.parachute = ClientsideModel( "models/jessev92/bf2142/parachute.mdl", 7 )
		self.parachute:SetPos( self:GetPos() - self:GetAngles():Up() * 47 )
		self.parachute:SetAngles( self:GetAngles() + Angle( 0, 90, 0 ) )
		self.parachute:SetParent( self )

		self.hasParachute = true
	elseif self.isOnGround and self.hasParachute then
		-- Remove parachute model once has landed
		if self.parachute:IsValid() then
			self.parachute:Remove()
		end

		-- Enable smoke particle effect and randomise the wind direction a bit
		self.windDirection = Vector( math.cos( CurTime() * math.random( 1, 5 ) ) * 3 +  math.cos( self.randDirection ) * math.random( 20, 50 ), math.sin( CurTime() * math.random( 1, 5 ) ) * 3 + math.sin( self.randDirection ) * math.random( 20, 50 ), 0 ) 
		self:createParticle( self.PE, self:GetPos() + self:GetAngles():Up() * 18, Vector( 0, 0, 30 + math.cos( CurTime() * math.random( 1, 5 ) ) * 3 ) + self.windDirection*1.2, 10, Color( 220, 40, 40 ) )
	end
end

function ENT:Draw()
	self:DrawModel()

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), 90)	

	cam.Start3D2D(Pos + Ang:Up() * 16.2, Ang, 0.11)
		draw.SimpleText( "Airdrop", "rylfont1", 0, -60, Color( 255, 255, 255 ), 1, 1 ) 
		draw.SimpleText( "Time left "..string.FormattedTime( ( self.dieTime - CurTime() ), "%02i:%02i" ), "DermaLarge", 0, 0, Color( 255, 255, 255 ), 1, 1 )
	cam.End3D2D()

	Ang:RotateAroundAxis(Ang:Up(), 0)
	Ang:RotateAroundAxis(Ang:Forward(), 0)
	Ang:RotateAroundAxis(Ang:Right(), 180 )

	cam.Start3D2D(Pos + Ang:Up() * 16.2, Ang, 0.11)
		draw.SimpleText( "Airdrop", "rylfont1", 0, -60, Color( 255, 255, 255 ), 1, 1 ) 
		draw.SimpleText( "Time left "..string.FormattedTime( ( self.dieTime - CurTime() ), "%02i:%02i" ), "DermaLarge", 0, 0, Color( 255, 255, 255 ), 1, 1 )
	cam.End3D2D()
end

function ENT:OnRemove()
	-- If the parachute exists then we got to remove it
	if self.hasParachute then
		if self.parachute:IsValid() then
			self.parachute:Remove()
		end
	end

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
    new_p:SetStartSize( 6 )
    new_p:SetEndSize( math.random( 60, 90 ) )
    new_p:SetStartAlpha( 20 )
    new_p:SetEndAlpha( 0 )
end

--[[

	AIRDROP MENU

]]--

local function drawRect( xpos, ypos, xscale, yscale, colour )
	surface.SetDrawColor( colour )
	surface.DrawRect( xpos, ypos, xscale, yscale )
end

local function open_item_hud( ent, itemTable )
	if isMenuOpen then return end
	isMenuOpen = true

	local im = vgui.Create( "DFrame" )
	im:SetSize( 530, 135 )
	im:Center()
	im:MakePopup()
	im:SetDraggable( false )
	im:ShowCloseButton( false )
	im:SetTitle( "" )

	function im:Paint( w,h )
	end

	function im:Think()
		-- If the entity doesn't exist anymore close the menu
		if !IsValid( ent ) then
			self:Close()
		end

		-- If the users mouse is outside of the panel and the click then close it
		local x, y = self:CursorPos()
		if ( x < -10 or x > self:GetWide() + 10 ) or ( y < -10 or y > self:GetTall() + 10 ) then
			if input.IsButtonDown( MOUSE_LEFT ) then
				self:Close()
			end
		end
	end

	function im:OnClose()
		isMenuOpen = false
	end

	local clbtn = vgui.Create( "DButton", im)
	clbtn:SetText( "" )
	clbtn:SetPos( im:GetWide() - 60, 0 )
	clbtn:SetSize( 60, 25 )

	function clbtn:Paint(w, h)
		draw.SimpleText( "[ CLOSE ]", "DebugFixed", w / 2, h / 2, ( self:IsHovered() and Color( 255, 51, 51 ) or Color( 0, 0, 0 ) ), 1, 1 )
	end

	function clbtn:DoClick()
		isMenuOpen = false
		im:Close()
	end

	local il = vgui.Create( "DIconLayout", im )
	il:SetSize( im:GetWide() - 10, 110 )
	il:SetPos( 5, 20 )
	il:SetSpaceX( 5 )
	il:SetSpaceY( 0 )

	function il:PerformLayout( update )
		if update then
			for k, v in pairs( self:GetChildren() ) do
				v.itemPos = v.itemPos + ( k - v.itemPos )
			end
		end
	end
	
	local itemCount = 0

	for k, v in pairs( itemTable ) do
		itemCount = itemCount + 1

		local id = il:Add( "DButton" )
		id:SetSize( 100, 100 )
		id:SetText( "" )
		id.itemPos = k

		function id:Paint( w,h )
			drawRect( 0, 0, w, h, Color( 240, 240, 240 ) )
			drawRect( 0, 0, w, 20, Color( 20, 20, 20 ) )

			draw.SimpleText( v.printName or "nil", "DebugFixed", w / 2, 10, ryl_airdrop_config.qualities[v.itemQuality].itemColour, 1, 1 )
			draw.SimpleText( ryl_airdrop_config.qualities[v.itemQuality].printName, "DebugFixed", w / 2, h - 10, Color( 30, 30, 30 ), 1, 1 )
			draw.SimpleText( "Click to loot", "DebugFixed", w / 2, h / 2, Color( 30, 30, 30 ), 1, 1 )
		end

		function id:Think()
			local w, h = self:GetSize()
			if self:IsHovered() then
				self:SetPos( ( w * ( self.itemPos - 1 ) ) + ( 5 * ( self.itemPos - 1 ) ), 0 )
			else
				self:SetPos( ( w * ( self.itemPos - 1 ) ) + ( 5 * ( self.itemPos - 1 ) ), 5 )
			end
		end

		function id:DoClick()
			net.Start( "ryl_airdrop_spawn_item" )
				net.WriteEntity( ent )
				net.WriteString( v.printName )
			net.SendToServer()

			itemCount = itemCount - 1
			if itemCount == 0 then
				isMenuOpen = false
				im:Close()
			end
			
			id:Remove()
			il:PerformLayout( true )
		end
	end
end

--[[

	NET MESSAGES

]]--

net.Receive( "ryl_airdrop_items", function( len )
	open_item_hud( net.ReadEntity(), net.ReadTable() )
end )