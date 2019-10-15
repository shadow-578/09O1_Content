SWEP.PrintName				= "BBY_Launcher"
SWEP.Author					= "Viveret"
SWEP.Instructions			= "Left mouse to fire a bby!"
SWEP.Category				= "TTT"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.EquipMenuData = {
   type = "BBY Launcher",
   desc = "Throw a baby at another baby"
};
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.AutoSpawnable = false
SWEP.HoldType = "pistol"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Weight					= 7
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= true

SWEP.ViewModel				= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_deagle.mdl"

if SERVER then
   resource.AddFile("materials/vgui/ttt/icon_bbylauncher.vmt")
   resource.AddFile("sound/baby_amused.wav")
end
SWEP.Icon = "vgui/ttt/icon_bbylauncher"

local ShootSound = Sound( "baby_amused.wav" )

function SWEP:PrimaryAttack()
	-- This weapon is 'automatic'. This function call below defines
	-- the rate of fire. Here we set it to shoot every 0.5 seconds.
--	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )	

	self:EmitSound( ShootSound ) 
	--
	-- If we're the client ) then this is as much as we want to do.
	-- We play the sound above on the client due to prediction.
	-- ( if ( we didn't they would feel a ping delay during multiplayer )
	--
	if ( CLIENT ) then return end

	local ent = ents.Create( "prop_physics" )
	if (  !IsValid( ent ) ) then return end
	ent:SetModel( "models/props_c17/doll01.mdl" )
 	util.SpriteTrail(ent, 0, Color(255,69,184), false, 15, 1, 4, 1/(15+1)*0.5, "trails/plasma.vmt")

	--
	-- Set the position to the player's eye position plus 16 units forward.
	-- Set the angles to the player'e eye angles. Then spawn it.
	--
	ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) )
	ent:SetAngles( self.Owner:EyeAngles() )
	ent:Spawn()
 
	--
	-- Now get the physics object. Whenever we get a physics object
	-- we need to test to make sure its valid before using it.
	-- If it isn't ) then we'll remove the entity.
	--
	local phys = ent:GetPhysicsObject()
	if (  !IsValid( phys ) ) then ent:Remove() return end
	--
	-- Now we apply the force - so the chair actually throws instead 
	-- of just falling to the ground. You can play with this value here
	-- to adjust how fast we throw it.
	phys:SetMass( 200 )
	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 500000
	phys:ApplyForceCenter( velocity )
	--
	-- Assuming we're playing in Sandbox mode we want to add this
	-- entity to the cleanup and undo lists. This is done like so.
	--
--	 cleanup.Add( self.Owner, "props", ent )
 
--	undo.Create( "Thrown_BBY" )
--		undo.AddEntity( ent )
--		undo.SetPlayer( self.Owner )
--	undo.Finish()

	if self.Owner:GetAmmoCount(self.Primary.Ammo) < 1 then
		self.Owner:DropWeapon( self )
		self:Remove() 
		return false
	end
end
