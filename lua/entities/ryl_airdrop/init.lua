AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--[[

	NET MESSAGES	

]]--

util.AddNetworkString( "ryl_airdrop_items" )
util.AddNetworkString( "ryl_airdrop_spawn_item" )

--[[

	FUNCTIONS

]]--

local function selectQuality( itemTable, randomSpawnChance )
	local totalSpawnChance = 0

	for k, v in pairs( itemTable ) do
		if randomSpawnChance <= v[1].spawnChance + totalSpawnChance then
			return v
		end

		totalSpawnChance = totalSpawnChance + v[1].spawnChance
	end

	return nil
end

local function selectRandomItem( quality )
	local sameQualityItems = {}

	-- Add items into the table
	for k, v in pairs( ryl_airdrop_config.items ) do
		if v.itemQuality == quality then
			table.insert( sameQualityItems, v )
		end
	end

	-- Randomly select an item from the table
	return sameQualityItems[math.random( 1, #sameQualityItems )]
end

local function cleanTable( itemtable )
	-- Since the net libary doesn't like sending functions in tables lets just remove 
	-- any functions from the table + other irrelevant things and send it a clean table
	local newTable = {}

	for k, v in pairs( itemtable ) do
		table.insert( newTable, { printName = v.printName, itemQuality = v.itemQuality } )
	end

	return newTable
end

local function hasReqRank( ply, rank )
	if type( rank ) == "string" then
		return string.lower( ply:GetUserGroup() ) == string.lower( rank )
	elseif type( rank ) == "table" then
		for k, v in pairs( rank ) do
			if string.lower( ply:GetUserGroup() ) == string.lower( v ) then
				return true
			end
		end

		return false
	else
		-- Something is probably wrong with the config
		return false
	end
end

local function getItemIndex( tableToSearch, keyToFind )
	local curItem = 1

	for k, v in pairs( tableToSearch ) do
		if k == keyToFind then
			return curItem
		end

		curItem = curItem + 1
	end
end

--[[

	ENT FUNCTIONS

]]--

function ENT:Initialize()
	self:SetModel( "models/Items/ammocrate_ar2.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )

	-- Entity Physics
	self.phys = self:GetPhysicsObject()
	
	if (self.phys:IsValid()) then
		self.phys:Wake()
	end

	-- Entity Variables
	self.spawnTime        = os.date( "%H:%M:%S - %d/%m/%Y", os.time() )
	self.dieTime          = CurTime() + ryl_airdrop_config.dropLife
	self.isFalling        = false
	self.hasHitGround     = false
	self.distanceToFloor  = 0
	self.hasGeneratedList = false

	-- Need to add a delay to make sure other variables are set externally before trying to generate inventory
	timer.Simple( 0.5, function()
		self.itemList = self:generateInventory()

		if type( self.itemList ) == "table" then
			self.hasGeneratedList = true 
		end
	end )
end

function ENT:Think()
	-- Create a trace to be used when judging how close the entity is to the ground
	local airdropTrace = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + Vector( 0, 0, -1 ) * 100000,
		filter = self
	})

	-- If the tracerhits then calculate the distance to the floor
	if airdropTrace.Hit then
		self.distanceToFloor = ( self:GetPos() - airdropTrace.HitPos ):Length()
		self.isFalling = self.distanceToFloor > 100
		
		if !self.isFalling and !self.hasHitGround then
			self.hasHitGround = true
		end
	end

	-- Delete if it has no loot
	if self.hasGeneratedList then
		if #self.itemList == 0 then
			self:Remove()
		end
	end

	-- Delete if it's past dieTime
	if CurTime() > self.dieTime then
		self:Remove()
	end
end

function ENT:PhysicsUpdate()
	-- If it's falling with the parachute out we want it to fall slowly
	if self.isFalling and !self.hasHitGround then
		self.phys:ApplyForceCenter(  Vector( 0, 0, 1 ) * self.phys:GetMass() * 9.80665 * ( self.phys:GetVelocity():Length()/self.distanceToFloor*2 ) )
	end
end

function ENT:Use( activator, caller  )
	if IsValid( caller ) and caller:IsPlayer() then
		-- Send the entity and item list to the player
		net.Start( "ryl_airdrop_items" )
			net.WriteEntity( self )
			net.WriteTable( cleanTable( self.itemList ) )
		net.Send( caller )
	end
end

--[[

	ENT META FUNCTIONS

]]--

function ENT:generateInventory()
	local items = {}

	-- Make sure we have the max table probability
	local maxProbability = 0

	-- Have to make sure that the lowest chances are last
	local newTable = {}

	-- Clone the quality table since we might not include them all and don't want to affect the main table
	local quality_clone = table.Copy( ryl_airdrop_config.qualities )

	for k, v in pairs( quality_clone ) do
		-- If a player has called in the drop then see if they're the right rank(s) for any qualities that have a rank requirement
		if self.owner != nil and v.reqRank != nil then
			if !hasReqRank( self.owner, v.reqRank ) then
				-- If they're not the right rank then remove the item
				v = nil
			end
		elseif self.owner == nil and v.reqRank != nil then
			-- If the player isn't valid then it wasn't spawned in so if there is a required rank remvoe the item
			v = nil
		end

		-- If we remove something for the list the item will become invalid so lets try not to use that item
		if v != nil then
			table.insert( newTable, { v, chance = v.spawnChance, tableKey = k } )
			maxProbability = maxProbability + v.spawnChance
		end
	end

	-- Sort the table so the lowest probability is first
	table.SortByMember( newTable, "chance", true )

	-- Get the items
	for x = 1, 5 do
		local randNum = math.Rand( 0, maxProbability )
		local itemQuality = selectQuality( newTable, randNum )

		if itemQuality != nil then
			local newItem = selectRandomItem( itemQuality.tableKey )
			
			if newItem != nil then
				table.insert( items, newItem )
			end
		end
	end

	return items
end

function ENT:spawnItem( ply, itemPrintName )
	if itemPrintName != nil then
		for k, v in pairs( self.itemList ) do
			if v.printName == itemPrintName then
				-- If the item has an entity then create it
				local newItem = nil
				
				if v.itemEnt != nil then
					newItem = ents.Create( v.itemEnt )

					if !IsValid( newItem ) then return end
					newItem:SetPos( self:GetPos() + Vector( 0, 0, 30 ) )
					newItem:Spawn()
				end

				-- If the item has a spawn function then call it
				if v.itemFunc != nil then 
					v.itemFunc( ply, newItem )
				end

				table.remove( self.itemList, k )
				break
			end
		end
	end
end

--[[

	NET RECEIVE

]]--

net.Receive( "ryl_airdrop_spawn_item", function( len, pl )
	local ent = net.ReadEntity()
	local itemId = net.ReadString()

	if !IsValid( ent ) then return end
	if ( pl:GetPos() - ent:GetPos() ):Length() > 200 then return end

	ent:spawnItem( pl, itemId )
end )