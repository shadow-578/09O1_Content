CreateConVar("ttt_officegun_detective", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Can a detective buy the Office gun?")
CreateConVar("ttt_officegun_traitor", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Can a traittor buy the Office gun?")
CreateConVar("ttt_officegun_ammo", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How much ammo the chair gun has.")
CreateConVar("ttt_officegun_minvelocity", 100000, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "The minimum velocity objects shot by the gun have (more velocity = more speed AND more damage)")
CreateConVar("ttt_officegun_maxvelocity", 900000, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "The maximum velocity objects shot by the gun have (more velocity = more speed AND more damage)")
CreateConVar("ttt_officegun_minmass", 75, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "the minimum mass objects shot by the gun have (more mass = more damage)")
CreateConVar("ttt_officegun_maxmass", 150, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "the maximum mass objects shot by the gun have (more mass = more damage)")
CreateConVar("ttt_officegun_massshotcount", 3, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How many objects are shot on the Office guns secondary attack mode (Shotgun mode)")
CreateConVar("ttt_officegun_stealth", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the weapon look like a default shotgun or the default traitor weapon deagle")

local ShootSound = Sound("Metal.SawbladeStick")
local ModelsPathBase = "models/props/cs_office/"
local ModelsNames = {"water_bottle", "tv_plasma", 
"trash_can", "sofa_chair", "radio", 
"projector", "plant01", "phone", "paper_towels", "fire_extinguisher", 
"file_box", "computer_monitor", "computer_keyboard", 
"computer", "coffee_mug", "chair_office", "cardboard_box01" }

SWEP.Base = "weapon_tttbase"
SWEP.PrintName = "Office Gun"
SWEP.Slot = 2
SWEP.SlotPos = 5
SWEP.DrawWeaponInfoBox = false
SWEP.Instructions = "Left mouseclick to fire a office item!\nRight mouseclick to fire multiple!"

--set slot to 6 in ttt
if ( GAMEMODE.Name == "Trouble in Terrorist Town" ) then
	SWEP.Slot = 6
end

SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = 'The Office Gun guns Offices\n\nLeft Click guns one office,\nRight Click guns many offices.'
}
SWEP.Icon = "materials/vgui/ttt/shitty_icon_officegun.png"
SWEP.Kind = WEAPON_EQUIP2

if GetConVar("ttt_officegun_stealth"):GetBool() then
	--use stealthy shotgun model /w shotgun sounds (and shotgun everyting on the visual side):
	--change hold type accordingly
	SWEP.HoldType = "shotgun"

	--add recoil like a shotgun has
	SWEP.Primary.Recoil = 7
	
	--use shotgun model
	SWEP.UseHands = true
	SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
	SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
	
	--use shotgun fire sound
	ShootSound = Sound("Weapon_XM1014.Single")
	
	--adjust viewmodel vars
	SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54
else
	--use default "traitor deagle" visuals
	SWEP.HoldType = "pistol"
	SWEP.UseHands = true
	SWEP.ViewModel =  "models/weapons/v_pist_deagle.mdl"
	SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
	
	--adjust viewmodel vars
	SWEP.ViewModelFlip = true
    --SWEP.ViewModelFOV = 54
end

SWEP.Spawnable = true
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.Primary.ClipSize = GetConVar("ttt_officegun_ammo"):GetInt()
SWEP.Primary.DefaultClip = GetConVar("ttt_officegun_ammo"):GetInt()
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.8
SWEP.Secondary.Delay = 1.6

--single buy only
SWEP.LimitedStock = true
SWEP.AllowDrop = true

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = {}

if (GetConVar("ttt_officegun_detective"):GetBool()) then
	table.insert(SWEP.CanBuy, ROLE_DETECTIVE)
end
if (GetConVar("ttt_officegun_traitor"):GetBool()) then
	table.insert(SWEP.CanBuy, ROLE_TRAITOR)
end

function SWEP:IsEquipment() return false end

-- Precache sounds
function SWEP:Initialize()
	print("OfficeGun Init [abcdefghi]")
	util.PrecacheSound(ShootSound)
	self:SetWeaponHoldType(self.HoldType)
end

--Normal mode
function SWEP:PrimaryAttack()
	--get ammo left
	local ammoCount = self:Clip1()
	
	--do fire
	if ( IsFirstTimePredicted() and ammoCount > 0 and SERVER) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Owner:EmitSound(ShootSound)
	
		self:ThrowObject(self:GetRandomOfficeModel(), false)

		if ( GAMEMODE.Name == "Trouble in Terrorist Town" ) then
			self:TakePrimaryAmmo(1)
		end
		
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	end
end

--Shotgun mode
function SWEP:SecondaryAttack()
	--get ammo left
	local ammoCount = self:Clip1()
	
	--do fire
	if ( IsFirstTimePredicted() and ammoCount > 0 and SERVER) then
		--get how many objects to fire
		local objCount = GetConVar("ttt_officegun_massshotcount"):GetInt()
	
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Owner:EmitSound(ShootSound)
		
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	
		timer.Create("ttt_officegun_shottimer_"..math.random(0, 1000), 0.05, objCount, function() 
			if(self:Clip1() > 0) then
				--shoot object
				self:ThrowObject(self:GetRandomOfficeModel(), true)
				
				--remove ammo
				if ( GAMEMODE.Name == "Trouble in Terrorist Town" ) then
					self:TakePrimaryAmmo(1)
				end
			end
		end)
	end
end

--Draw tips on gui
function SWEP:DrawHUD()
	local x = ScrW() / 2.0
	local y = ScrH() * 0.995
	
	draw.SimpleText("Primary attack to use as pistol.", "Default", x, y - 20, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("Secondary attack to use as shotgun.", "Default", x, y, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

--get a random model from cs_office
function SWEP:GetRandomOfficeModel()
	local obj =  ModelsPathBase..table.Random(ModelsNames)..".mdl"
	print("Shot "..obj)
	return obj
end

--throw a object
function SWEP:ThrowObject(model_file, displaceRandom)
	local ent = ents.Create("prop_physics")
	if (!IsValid( ent ) or !IsValid(self.Owner)) then return end
	ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 10))

	if displaceRandom then
		--displace spawn pos randomly
		--ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 5) + (VectorRand() * 20))
		ent:SetAngles(self.Owner:EyeAngles() + (AngleRand() * 60))
	else
		--normal spawn pos
		--ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 10))
		ent:SetAngles(self.Owner:EyeAngles())
	end
	
	ent:SetModel(model_file)
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if ( !IsValid( phys ) ) then ent:Remove() return end

	local velocity = self.Owner:GetAimVector()
	velocity = velocity * math.Rand(GetConVar("ttt_officegun_minvelocity"):GetFloat(), GetConVar("ttt_officegun_maxvelocity"):GetFloat()) 
	velocity = velocity + ( VectorRand() * 10 )
	--phys:ApplyForceCenter( velocity )
	phys:SetVelocityInstantaneous(velocity)
	phys:SetMass(math.Rand(GetConVar("ttt_officegun_minmass"):GetFloat(), GetConVar("ttt_officegun_maxmass"):GetFloat()))
	
	cleanup.Add( self.Owner, "props", ent )
	undo.Create("Thrown_Chair")
		undo.AddEntity( ent )
		undo.SetPlayer( self.Owner )
	undo.Finish()
end
