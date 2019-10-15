CreateConVar("ttt_sword_detective", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Can a detective buy the sword?")
CreateConVar("ttt_sword_traitor", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Can a traitor buy the sword?")
CreateConVar("ttt_sword_damage", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How much damage one sword strike deals")

if( SERVER ) then
    AddCSLuaFile( "shared.lua" );
end

--names & shop descriptions of the sword. a random one is drawn every time the server (re-) loads the weapon (first load, levelchange, ...)
local SwordNames = {"Excalibur", 
"Chunchunmaru", 
"Steve", 
"Saavet'a",
"Günter"}
local SwordDescs = {"Das Legendäre Schwert König Arthurs, \ndem Magische Kräfte zugeschrieben werden (dem Schwert, nicht dem König)!",
"Das Großartigste Schwert, dass je Existierte. \nEs ist so mächtig, dass nur ein Wahrer Held es beherrschen kann!", 
"Ein Seltenes Schwert, welches Drachen & Dämonen erschug. \nNur der Name ist ein wenig unvorteilhaft...",
"Ein Schwert mit einem Unaussprechlichen Name, welcher jedoch, \nrichtig ausgesprochen, seine wahren Kräfte entfesselt!",
"Günter ist registrierter Sexualstraftäter... \nOh warte, es geht ja um Schwerter!"}
  
print("sword abcde")
SWEP.HoldType              = "melee"
SWEP.Slot                  = 2
SWEP.Icon                  = "materials/vgui/shitty_sword_icon.png"
SWEP.Base                  = "weapon_tttbase"
SWEP.Kind                  = WEAPON_EQUIP2
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.Instructions   = "Left: stab"
SWEP.DrawAmmo = false;
SWEP.DrawCrosshair = false;
SWEP.AutoSpawnable = false
SWEP.NextStrike = 0;

--SWEP.ViewModel      = "models/weapons/v_gamma_bustersword.mdl"
--SWEP.WorldModel     = "models/weapons/w_knife_t.mdl"
SWEP.ViewModel      = "models/weapons/v_dmascus.mdl"
SWEP.WorldModel     = "models/weapons/w_damascus_sword.mdl"
SWEP.ViewModelFOV   = 62
SWEP.ViewModelFlip  = false

--set slot to 6 in ttt
if ( GAMEMODE.Name == "Trouble in Terrorist Town" ) then
	SWEP.Slot = 6
end

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = {}

if (GetConVar("ttt_sword_detective"):GetBool()) then
	table.insert(SWEP.CanBuy, ROLE_DETECTIVE)
end
if (GetConVar("ttt_sword_traitor"):GetBool()) then
	table.insert(SWEP.CanBuy, ROLE_TRAITOR)
end

--set name & description randomly
local swIndex = math.random(0, table.Count(SwordNames))
print("count:"..table.Count(SwordNames).."swindex: "..swIndex)

SWEP.PrintName = SwordNames[swIndex]
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = SwordDescs[swIndex]
}
      
-------------Primary Fire Attributes----------------------------------------
SWEP.Primary.Delay          = 0.9   --In seconds
SWEP.Primary.Recoil         = 0     --Gun Kick
SWEP.Primary.Damage         = 15    --Damage per Bullet
SWEP.Primary.NumShots       = 1     --Number of shots per one fire
SWEP.Primary.Cone           = 0     --Bullet Spread
SWEP.Primary.ClipSize       = -1    --Use "-1 if there are no clips"
SWEP.Primary.DefaultClip    = -1    --Number of shots in next clip
SWEP.Primary.Automatic      = true  --Pistol fire (false) or SMG fire (true)
SWEP.Primary.Ammo           = "none"    --Ammo Type
  
-------------Secondary Fire Attributes-------------------------------------
SWEP.Secondary.Delay        = 0.9
SWEP.Secondary.Recoil       = 0
SWEP.Secondary.Damage       = 0
SWEP.Secondary.NumShots     = 0
SWEP.Secondary.Cone         = 0
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.Hit = {
    Sound("weapons/knife/knife_hitwall1.wav")
}

SWEP.FleshHit = {
    Sound( "weapons/knife/knife_hit1.wav" ),
    Sound( "weapons/knife/knife_hit2.wav" ),
    Sound( "weapons/knife/knife_hit3.wav" ),
    Sound( "weapons/knife/knife_hit4.wav" )
}

function SWEP:Initialize()
    if( SERVER ) then
        self.Weapon:SetWeaponHoldType( "melee" );
    end
end
 
function SWEP:Precache()
	util.PrecacheSound("weapons/knife/knife_deploy1.wav")
	util.PrecacheSound("weapons/knife/knife_hitwall1.wav")
	util.PrecacheSound("weapons/knife/knife_hit1.wav")
	util.PrecacheSound("weapons/knife/knife_hit2.wav")
	util.PrecacheSound("weapons/knife/knife_hit3.wav")
	util.PrecacheSound("weapons/knife/knife_hit4.wav")
	util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
end
 
function SWEP:Deploy()
    self.Owner:EmitSound( "weapons/knife/knife_deploy1.wav" );
    return true;
end
 
function SWEP:PrimaryAttack()
    if( CurTime() < self.NextStrike ) then return; end
    self.NextStrike = ( CurTime() + .5 );
    local trace = self.Owner:GetEyeTrace();
    if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
        if( trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass()=="prop_ragdoll" ) then
            self.Owner:EmitSound( self.FleshHit[math.random(1,#self.FleshHit)] );
        else
            self.Owner:EmitSound( self.Hit[math.random(1,#self.Hit)] );
        end
            self.Owner:SetAnimation( PLAYER_ATTACK1 );
            self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
                bullet = {}
                bullet.Num    = 1
                bullet.Src    = self.Owner:GetShootPos()
                bullet.Dir    = self.Owner:GetAimVector()
                bullet.Spread = Vector(0, 0, 0)
                bullet.Tracer = 0
                bullet.Force  = 1
                bullet.Damage = GetConVar("ttt_sword_damage"):GetInt()
            self.Owner:FireBullets(bullet)
    else
        self.Owner:SetAnimation( PLAYER_ATTACK1 );
        self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
        self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
    end
end