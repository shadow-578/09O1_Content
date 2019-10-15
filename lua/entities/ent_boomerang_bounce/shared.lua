
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.PrintName		= "Boomerang"

ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false

ENT.Icon = "vgui/ttt/icon_boomerang.png"
ENT.Projectile = true
ENT.MaxSpeed = 1000

local BounceSounds = {
	Sound( "physics/metal/metal_box_impact_bullet1.wav" ),
	Sound( "physics/metal/metal_box_impact_bullet2.wav" ),
	Sound( "physics/metal/metal_box_impact_bullet3.wav" )
}

function ENT:Use(activator, caller)
	caller:Give("weapon_ttt_boomerang")
	if SERVER then self:Remove() end
end

local function deploySwep(ent)
		--local ent = LocalPlayer():GetNWEntity("boomerang_swep")
		local weapon = ents.Create("weapon_ttt_boomerang")
		weapon:SetPos(ent:GetPos())
		weapon:SetAngles(ent:GetAngles())
		weapon:SetVelocity(ent:GetVelocity())
		weapon:Spawn()
		weapon:Activate()
		weapon:SetModel("models/boomerang/boomerang.mdl")
		weapon.Hits = ent.Hits
		weapon:SetClip1(ent.Hits)
		if SERVER then 
			ent:Remove()
		end
end

function ENT:DropDown()
	 self:GetNWEntity("BoomerangOwner"):SetNWEntity("boomerang_swep", self)
	 timer.Create("propTimer" .. self:EntIndex(), 0.1, 1, function()
		if IsValid(self) then
			deploySwep(self)
		end
	end)
	
	 self.Drop = true
	 self:GetPhysicsObject():EnableGravity(true)
end

function ENT:StartTouch( ent )
	if ent:IsPlayer( ) then
		ent.damagedFromBoomerang = ent.damagedFromBoomerang or {}
		if CurTime( ) > ( ent.damagedFromBoomerang[self] or 0 ) + 0.2 then
			ent.damagedFromBoomerang[self] = CurTime( )
		else
			return
		end
		
		local dmgInfo = DamageInfo( )
		dmgInfo:SetDamage( 30 )
		dmgInfo:SetDamageType( DMG_SLASH )
		dmgInfo:SetAttacker( self:GetNWEntity("BoomerangOwner") )
		dmgInfo:SetDamageForce( Vector( 0, 0, 0 ) )
		if ent != self:GetNWEntity("BoomerangOwner") then
			dmgInfo:SetInflictor( self )
		end
		ent:TakeDamageInfo( dmgInfo )
		self:EmitSound("weapons/crossbow/hitbod1.wav")
	end
end

function ENT:Initialize()

	if ( SERVER ) then
		self:SetModel( "models/props_junk/sawblade001a.mdl" )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		self:SetTrigger(true)		
		
		local phys = self:GetPhysicsObject()
		phys:Wake()
		phys:SetMass( 50000 )
		phys:EnableGravity(false)
		
	else 
		self.LightColor = Vector( 0, 0, 0 )
		self:SetModel( "models/boomerang/boomerang.mdl")
	end
	
	self.DropOnNextCollide = false
	timer.Simple(10, function()
		self.DropOnNextCollide = true
	end)
end

function ENT:PhysicsCollide( data, physobj )
	if self.DropOnNextCollide or IsValid(data.HitEntity) and data.HitEntity:IsWorld() then 
		self:DropDown()
		return
	end
	
	if ( data.Speed > 20 && data.DeltaTime > 0.2 ) then
		sound.Play( table.Random( BounceSounds ), self:GetPos(), 70, math.random( 90, 150 ), 1 )
	end
	
	local newVel = physobj:GetVelocity():GetNormalized() * self.MaxSpeed
	physobj:AddAngleVelocity( -physobj:GetAngleVelocity( ) + Vector( 0, 0, -1000 ) )
	physobj:SetVelocity( newVel )
end

function ENT:Think( )
	if CLIENT then 
		self:SetModel( "models/boomerang/boomerang.mdl" )
		self:SetAngles(Angle(20,self:GetAngles().y,90)) 
	end
	
	local physobj = self:GetPhysicsObject( )
	if IsValid( physobj ) then
		physobj:AddAngleVelocity( -physobj:GetAngleVelocity( ) + Vector( 0, 0, -1000 ) )
		
		if physobj:GetVelocity( ):Length( ) < 10 then
			self:DropDown()
		end
	end
end