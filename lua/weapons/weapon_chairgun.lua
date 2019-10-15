SWEP.Base = "weapon_tttbase"
SWEP.PrintName = "Chair Launcher"
SWEP.Slot = 2
SWEP.SlotPos = 5
SWEP.DrawWeaponInfoBox = false
SWEP.Instructions = "Left mouseclick to fire a chair!"

SWEP.ViewModel = "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"

SWEP.Spawnable = true
SWEP.UseHands = true

SWEP.HoldType = "pistol"
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= true

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Delay = 0.1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "none"


SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

local ShootSound = Sound( "Metal.SawbladeStick" )

--------------------------------- TTT ----------------------------------

SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = 'The Chair Launcher throws chairs'
}

SWEP.Icon = "materials/vgui/ttt/chair_launcher_icon.png"
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true
SWEP.AllowDrop = true

if ( GAMEMODE.Name == "Trouble in Terrorist Town" ) then
	SWEP.Slot = 6
end

function SWEP:IsEquipment() return false end

------------------------------ END OF TTT ------------------------------


function SWEP:PrimaryAttack()

	if ( IsFirstTimePredicted() ) then

		self:ThrowChair( "models/props/cs_office/Chair_office.mdl" )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		if ( GAMEMODE.Name == "Trouble in Terrorist Town" ) then
			self:TakePrimaryAmmo( 1 )
		end

	end

	if self.Owner:GetAmmoCount(self.Primary.Ammo) < 1 then
		self:Remove()
		return false
	end
end


function SWEP:ThrowChair( model_file )

	self:EmitSound( ShootSound )


	if ( CLIENT ) then return end

	local ent = ents.Create( "prop_physics" )

	if ( !IsValid( ent ) ) then return end

	ent:SetModel( model_file )

	ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 32 ) )
	ent:SetAngles( self.Owner:EyeAngles() )
	ent:Spawn()




	local phys = ent:GetPhysicsObject()
	if ( !IsValid( phys ) ) then ent:Remove() return end


	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 1000000
	velocity = velocity + ( VectorRand() * 10 )
	phys:ApplyForceCenter( velocity )

	cleanup.Add( self.Owner, "props", ent )

	undo.Create( "Thrown_Chair" )
		undo.AddEntity( ent )
		undo.SetPlayer( self.Owner )
	undo.Finish()
end
