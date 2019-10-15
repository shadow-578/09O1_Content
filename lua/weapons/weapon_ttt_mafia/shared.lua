if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Mafia Gun"
   SWEP.Slot               = 6

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54
   
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "1 Shot.\nThat's how mafia works.\n\nLässt das Opfer 14 sekunden lang Tanzen, bis es vor aufregung explodiert."
   };

   SWEP.Icon = "vgui/ttt/mafia64.png"
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Primary.Recoil        = 3
SWEP.Primary.Damage        = 1
SWEP.Primary.Delay         = 1
SWEP.Primary.Cone          = 0.01
SWEP.Primary.ClipSize      = 2
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 1
SWEP.Primary.Ammo          = "none"
SWEP.AmmoEnt               = "none"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_fiveseven.mdl"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.IronSightsPos         = Vector(-5.95, -1, 4.799)
SWEP.IronSightsAng         = Vector(0, 0, 0)

-- Precache sounds
function SWEP:Initialize()
	print("weapon_ttt_mafia init [abcdefgh]")
	util.PrecacheSound( "ttt_mafia_gun/lvl_up_sfx.wav" )
	util.PrecacheSound( "ttt_mafia_gun/mfa_sdf.wav" )   
	util.PrecacheSound( "ttt_mafia_gun/big_explosion.wav" )
end

--weapon primary attack
function SWEP:PrimaryAttack()
   if not self:CanPrimaryAttack() then return end
   self.Owner:EmitSound("ttt_mafia_gun/lvl_up_sfx.wav")
   local cone = self.Primary.Cone
   local num = 1

   local bullet = {}
   bullet.Num    = num
   bullet.Src    = self.Owner:GetShootPos()
   bullet.Dir    = self.Owner:GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = 1
   bullet.Force	= 10
   bullet.Damage = 1
   bullet.TracerName = "PhyscannonImpact"
   
   bullet.Callback = function(att, tr)
                        if SERVER or (CLIENT and IsFirstTimePredicted()) then
                           local ent = tr.Entity
						   
						   --make target dance with music while shooting
						   if SERVER and ent:IsPlayer() then
								ent:EmitSound("ttt_mafia_gun/mfa_sdf.wav")
								ent:GodEnable()
								
								--dance, recheck dance animation every second for 14 seconds
								timer.Create(self:EntIndex().."mafia_dance_t", 1, 14, function()
									ent:DoAnimationEvent( ACT_GMOD_TAUNT_DANCE, 1642 )
									if !ent:IsFrozen() then 
										ent:Freeze(true) 
									end
								end)
								
								--send shoot command 2x a second for 14 seconds
								--timer.Create(self:EntIndex().."mafia_shoot_t", 0.5, 14, function()
								--	if IsValid(ent) and ent:Alive() then
								--	ent:ConCommand("+attack")
								--	timer.Simple(0.25,function() 
								--		if IsValid(ent) then 
								--			ent:ConCommand("-attack") 
								--			end 
								--		end)
								--	end
								--end)
								ent:Freeze(true)
								
								--kill target after 15 seconds, creating an explosion
								timer.Simple(15, function() 
									if ent:Alive() then									
										--spawn explosion
										Xplode(ent)
										
										--disable god mode and freeze
										ent:GodDisable()
										ent:Freeze(false)
									
										--kill target
										local totalHealth = ent:Health() * 2
										local inflictWep = ents.Create('weapon_ttt_mafia')
										ent:TakeDamage( totalHealth, att, inflictWep )
									
										--unfreeze target again, just to be sure
										timer.Simple( 2, function() 
											if ent:IsFrozen() then 
												ent:Freeze(false) 
												end 
											end)
										end
									end)
								end
                           end
                        end
   self.Owner:FireBullets( bullet )
   if SERVER then
     self:TakePrimaryAmmo( 1 )
   end
end

--Create explosion
function Xplode(target)
   local ent = ents.Create( "env_explosion" )
   ent:SetPos( target:GetPos() )
   ent:SetOwner( target )
   ent:SetKeyValue( "iMagnitude", "100" )
   ent:Spawn()
   ent:Fire( "Explode", 0, 0 )
   ent:EmitSound( "ttt_mafia_gun/big_explosion.wav", 500, 500 )  
end

--Remove on drop
function SWEP:OnDrop()
	self:Remove()
end
            