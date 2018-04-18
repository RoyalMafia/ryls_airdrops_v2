ENT.Type           = "anim"
ENT.Base           = "base_gmodentity"
ENT.PrintName      = "airdrop grenade entity"
ENT.Category       = "ryl's airdrops" 
ENT.Author         = "ryl"
ENT.Spawnable      = false

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "isSleeping" )
end
