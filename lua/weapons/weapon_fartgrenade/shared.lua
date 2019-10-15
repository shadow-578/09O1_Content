 AddCSLuaFile()

if CLIENT then
	SWEP.EquipMenuData = {
		type = "Weapon"
	};
	SWEP.Slot               = 3
   	SWEP.DrawCrosshair      = false
	SWEP.Icon               = "vgui/weapons/weapon_fartgrenade.png"
end

SWEP.PrintName			   = "Fart Grenade"
SWEP.Author				   = "SgtDark"
SWEP.Base                  = "weapon_tttbase"
SWEP.ViewModel             = "models/weapons/v_grenade.mdl"
SWEP.WorldModel            = "models/weapons/w_grenade.mdl"

SWEP.Weight                = 5
SWEP.AutoSwitchFrom        = true
SWEP.Spawnable 			   = true
SWEP.AdminOnly 			   = false
SWEP.ViewModelFlip 		   = false

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

SWEP.Kind                  = WEAPON_NADE
SWEP.IsGrenade             = true
SWEP.LimitedStock 		   = true
SWEP.CanBuy 			   = {ROLE_TRAITOR}

local fartSound = Sound("fart_1.wav")
local dieSound = Sound("fart_2.wav")
local throwSound = Sound("weapons/slam/throw.wav")

local hurtSounds = {
					Sound("vo/npc/Barney/ba_ohshit03.wav"), 
					Sound("vo/k_lab/kl_ahhhh.wav"),
					Sound("vo/npc/male01/moan01.wav"),
					Sound("vo/npc/male01/moan04.wav"),
					Sound("vo/npc/male01/ohno.wav")}
local hurtImpacts = {
					Sound("player/pl_pain5.wav"),
					Sound("player/pl_pain6.wav"),
					Sound("player/pl_pain7.wav")}


function SWEP:Initialize()
   game.AddParticles("particles/fart_particle.pcf")
   PrecacheParticleSystem("fartsmoke")
end

function SWEP:PrimaryAttack()
   self.Weapon:SendWeaponAnim(ACT_VM_THROW)
   self:Throw()
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:Throw()
	if SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end

      ply:EmitSound(throwSound)

      local ang = ply:EyeAngles()
      local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())+ (ang:Forward() * 8) + (ang:Right() * 10)
      local target = ply:GetEyeTraceNoCursor().HitPos
      local tang = (target-src):Angle()

      if tang.p < 90 then
         tang.p = -10 + tang.p * ((90 + 10) / 90)
      else
         tang.p = 360 - tang.p
         tang.p = -10 + tang.p * -((90 + 10) / 90)
      end
      tang.p=math.Clamp(tang.p,-90,90)
      local vel = math.min(800, (90 - tang.p) * 6)
      local thr = tang:Forward() * vel + ply:GetVelocity()


      self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, 0, 0), ply)
      self:Remove()
   end
end

function SWEP:CreateGrenade(src, ang, vel, angimp, ply)
   local gren = ents.Create("prop_physics")
   if not IsValid(gren) then return end

   gren:SetPos(src)
   gren:SetAngles(ang)
   gren:SetModel("models/weapons/w_grenade.mdl")
   gren:SetOwner(ply)
   gren:SetGravity(0.4)
   gren:SetFriction(0.2)
   gren:SetElasticity(0.45)

   gren:Spawn()
   gren:PhysWake()
   
   timer.Simple(3,function()
   		if(!IsValid(gren)) then return end

		ParticleEffect("fartsmoke",gren:GetPos()+Vector(-80,-40,0),Angle(0,0,0), nil)
		gren:EmitSound(fartSound)
		local v = {}
	   timer.Create("fartsmoke_"..gren:EntIndex(), 0.5, 24, function()
	   		if(IsValid(gren)) then
	   			local left = timer.RepsLeft("fartsmoke_"..gren:EntIndex())
	   			local players = player.GetAll()

	   			for p in pairs(player.GetAll()) do

	   				local ply = players[p]
	   				local vel = ply:GetVelocity()
	   				local dir = (ply:GetPos()-gren:GetPos()):GetNormalized()

	   				local dmg_rate = math.Clamp(ply:GetPos():Distance(gren:GetPos()),0,420)
	   				dmg_rate = (1-((1/420)*dmg_rate))

	   				local zdist = ply:GetPos().z-gren:GetPos().z
	   				if(zdist < 0) then zdist = zdist*-1 end

	   				if(dmg_rate <= 0 || zdist >= 160 || !ply:Alive())then continue end

	   				local force = vel+dmg_rate*500*dir
	   				local isDead = ply:Health()-10 <= 0

	   				ply:TakeDamage(10,self,self.Weapon)
	   				ply:ScreenFade( SCREENFADE.IN, Color( 255, 155, 0, 128 ), 0.3, 0 )
		   			ply:SetVelocity(force)
		   			print(zdist)
		   			if(!IsValid(v[ply:EntIndex()])) then
			   			ply:EmitSound(hurtSounds[math.random(1,5)])
			   			v[ply:EntIndex()] = ply
		   			end

		   			if(ply:Health() > 0) then
		   				ply:EmitSound(hurtImpacts[math.random(1,3)])
		   			end

		   			if(isDead) then
		   				ply:EmitSound(dieSound)
		   			end
	   			end
		   		if(left == 0) then
		   			gren:Remove()
		   		end 
	   		end
	   	end)
   	end)

   local phys = gren:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocity(vel)
      phys:AddAngleVelocity(angimp)
   end
end