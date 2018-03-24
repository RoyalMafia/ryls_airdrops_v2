--[[

   AIRDROP GRENADE
   SOME CODE FROM TTT MODIFIED FOR MY NEEDS
   SOURCE: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/gamemodes/terrortown/entities/weapons/weapon_tttbasegrenade.lua

]]--

AddCSLuaFile()

--[[

   SWEP VARIABLES
   
]]--

if CLIENT then
   SWEP.PrintName          = "Airdrop grenade"
   SWEP.Instructions       = "Calls an airdrop at the requested location"
   SWEP.Slot               = 3

   SWEP.ViewModelFlip      = true
   SWEP.DrawCrosshair      = false

   SWEP.Icon               = "entities/weapon_frag"
end

SWEP.Spawnable             = true
SWEP.AdminOnly             = true
SWEP.Category              = "ryl's airdrops"
SWEP.SpawnMenuIcon         = "entities/weapon_frag"

SWEP.ViewModel             = "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel            = "models/weapons/w_eq_flashbang.mdl"

SWEP.Weight                = 5
SWEP.AutoSwitchFrom        = true
SWEP.NoSights              = true

SWEP.Primary.ClipSize      = -1
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Automatic     = false
SWEP.Primary.Delay         = 1.0
SWEP.Primary.Ammo          = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.HoldType              = "grenade"

--[[

   SWEP FUNCTIONS

]]--

function SWEP:Initialize()
   if self.SetHoldType then
      self:SetHoldType( "grenade" )
   end
end

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

   if SERVER then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end

   self:SendWeaponAnim( ACT_VM_THROW )

   timer.Simple( 0.5, function()
      self:Throw()
   end )
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
   local ply = self:GetOwner()
   if not IsValid(ply) then return end
end

function SWEP:Deploy()
   if self.SetHoldType then
      self:SetHoldType( "grenade" )
   end

   return true
end

function SWEP:Reload()
   return false
end

--[[

   SWEP META FUNCS
   THROW FUNCTIONS IS FROM TTT GRENADE BASE

]]--

function SWEP:Throw()
   if SERVER then
      local ply = self:GetOwner()
      if not IsValid(ply) then return end

      local ang = ply:EyeAngles()
      local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())+ (ang:Forward() * 8) + (ang:Right() * 10)
      local target = ply:GetEyeTraceNoCursor().HitPos
      local tang = (target-src):Angle() -- A target angle to actually throw the grenade to the crosshair instead of fowards
      -- Makes the grenade go upgwards
      if tang.p < 90 then
         tang.p = -10 + tang.p * ((90 + 10) / 90)
      else
         tang.p = 360 - tang.p
         tang.p = -10 + tang.p * -((90 + 10) / 90)
      end
      tang.p=math.Clamp(tang.p,-90,90) -- Makes the grenade not go backwards :/
      local vel = math.min(800, (90 - tang.p) * 6)
      local thr = tang:Forward() * vel + ply:GetVelocity()
      self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, math.random(-1200, 1200), 0), ply)

      self:Remove()
   end
end

function SWEP:CreateGrenade(src, ang, vel, angimp, ply)
   local gren = ents.Create( "ryl_airdrop_grenade" )
   if not IsValid(gren) then return end

   gren:SetPos(src)
   gren:SetAngles(ang)

   gren:SetGravity(0.4)
   gren:SetFriction(0.2)
   gren:SetElasticity(0.45)

   gren:Spawn()

   gren:PhysWake()

   local phys = gren:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocity(vel)
      phys:AddAngleVelocity(angimp)
   end

   -- Set the owner of the grenade entity
   gren.owner = self:GetOwner()

   return gren
end