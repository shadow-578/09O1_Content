if SERVER then
	AddCSLuaFile()
end

ENT.Base 		= "base_anim"
ENT.Type 		= "anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false
ENT.PrintName		= "Boomerang"
ENT.Icon = "vgui/ttt/icon_boomerang.png"

local ent = self
local speed = 2000

local BounceSounds = {
	Sound( "physics/metal/metal_box_impact_bullet1.wav" ),
	Sound( "physics/metal/metal_box_impact_bullet2.wav" ),
	Sound( "physics/metal/metal_box_impact_bullet3.wav" )
}

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

function ENT:Initialize()
	
	self.LastHitEntity = 0
	self.LastHitDirection = false
	
	self.Hits = 0
	self.HitPlayer = false
	self.TargetReached = false
	self.collided = false
	self.CollideCount = 0
	
	local targetPos = self:GetNWVector("targetPos")
	
	self.LastVelocity = (targetPos - self:GetPos()):GetNormalized()
	self.Drop = false
	
	self:SetModel( "models/boomerang/boomerang.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if SERVER && phys then
		phys:EnableGravity(false)
		--if SERVER then self:GetPhysicsObject():SetMaterial("dirt") end
		phys:SetMass( 1 )
		phys:AddAngleVelocity(Vector(0,-1000,0))
		phys:Wake()
	end
end

function ENT:Use(activator, caller)
	caller:Give("weapon_ttt_boomerang")
	if SERVER then self:Remove() end
end

function ENT:PhysicsCollide(data, phys)
	if self.Drop then return end
	local hitEntity = data.HitEntity
	if hitEntity == self:GetNWEntity("BoomerangOwner") then
		local boomerang = self:GetNWEntity("BoomerangOwner"):Give("weapon_ttt_boomerang")
		boomerang:SetClip1(self.Hits)
		if SERVER then
			self:Remove()
		end
		return
	end
	
	if self:NearOwner() then return end
	
	--init possible damage
	local dmg = DamageInfo()
	dmg:SetAttacker(self:GetNWEntity("BoomerangOwner"))
	dmg:SetDamage(100)
	
	dmg:SetDamageForce(self.LastVelocity * 100)
	
	self.Projectile = true
	dmg:SetInflictor(self)
	dmg:SetDamageType(DMG_SLASH)
	dmg:SetDamagePosition(hitEntity:GetPos())
	
	if data.DeltaTime > 0.2 && (!IsValid(hitEntity) || (!hitEntity:IsPlayer() && !hitEntity:GetClass() == "prop_ragdoll")) then
		sound.Play( table.Random( BounceSounds ), self:GetPos(), 70, math.random( 90, 150 ), 1 )
	elseif data.DeltaTime > 0.2 then
		self:EmitSound("weapons/crossbow/hitbod1.wav")
	end
	
	if IsValid(hitEntity) then
		
		if hitEntity:GetClass() == "prop_ragdoll" then
			dmg:SetDamageForce(self.LastVelocity * 20000)
		end
		
		if hitEntity:IsPlayer() then
			
			local tr = util.TraceLine( {
				start = self:GetPos(),
				endpos = self:GetPos() + ( self.LastVelocity:GetNormalized() * 100 ),
				filter = self,
				collisiongroup = COLLISION_GROUP_WORLD
			} )
			
			if tr.Hit then
			
				--self:EmitSound("weapons/crossbow/hitbod1.wav")
				dmg:SetDamage(100)
				hitEntity:TakeDamageInfo(dmg)
				
				self:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
				self:SetVelocity(Vector(0, 0, 0))
				self.TargetReached = true
				if !self.collided then
					self:GoYourWayBack(speed)
					self.collided = true
				end
				return
			else
				self:SetPos(self:GetPos() + (self.LastVelocity * 100))
				self:SetVelocity(Vector(0, 0, 0))
				self:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
				self:SetAngles(Angle(20,self:GetAngles().y,90))
				self:GetPhysicsObject():AddAngleVelocity(Vector(0,-1000,0) - self:GetPhysicsObject():GetAngleVelocity())
			end
		end
		
		if hitEntity == self.LastHitEntity and self.TargetReached == self.LastHitDirection then return end
		self.LastHitEntity = hitEntity
		self.LastHitDirection = self.TargetReached
		
		if hitEntity:IsPlayer() && !self.HitPlayer then 
			self.Hits = self.Hits - 1 
			self.HitPlayer = true
		end
		
		hitEntity:TakeDamageInfo(dmg)
		
	end
	
	if !hitEntity:IsPlayer()  then
		self.CollideCount = self.CollideCount + 1
		if self.CollideCount > 1 && !self.collided then
			if self:NearOwner() then
				self:GetNWEntity("BoomerangOwner"):Give("weapon_ttt_boomerang")
				local boomerang = self:GetNWEntity("BoomerangOwner"):GetWeapon("weapon_ttt_boomerang")
				boomerang:SetClip1(self.Hits)
				if SERVER then
					self:Remove()
				end
			else
				 self:GetNWEntity("BoomerangOwner"):SetNWEntity("boomerang_swep", self)
				 timer.Create("propTimer", 1, 1, function() deploySwep(self) end)
				 self.Drop = true
				 self:GetPhysicsObject():EnableGravity(true)
			 end
		else
			self:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
			self:SetVelocity(Vector(0, 0, 0))
			self.TargetReached = true
			if !self.collided then
				self:GoYourWayBack(speed)
				self.collided = true
			end
		end
	end
end


function ENT:Think()
	if self.collided then
		self.collided = false
		self:SetAngles(Angle(20,0,90))
		self:GetPhysicsObject():AddAngleVelocity(Vector(0,-1000,0) - self:GetPhysicsObject():GetAngleVelocity())
	end
	
	if CLIENT or self.Drop then return end
	
	local targetPos = self:GetNWVector("targetPos")
	local Pos = self:GetPos()
	local ownerPos = self:GetNWEntity("BoomerangOwner"):GetShootPos()
	--print("targetPos ", targetPos, " Pos ", Pos, " ownerPos ", ownerPos)
	if !self.TargetReached and (targetPos:Distance(Pos) < 500) then
		self:GoYourWayBack(speed)
		return
	elseif !self.TargetReached then
		self:GetPhysicsObject():ApplyForceCenter((targetPos - Pos):GetNormalized() * speed)
	else
		self:GetPhysicsObject():ApplyForceCenter(((ownerPos) - Pos):GetNormalized() * speed)
		--self:GoYourWayBack(speed)
	end

	if (self.TargetReached and self:NearOwner()) then
		self:GetNWEntity("BoomerangOwner"):Give("weapon_ttt_boomerang")
		local boomerang = self:GetNWEntity("BoomerangOwner"):GetWeapon("weapon_ttt_boomerang")
		boomerang:SetClip1(self.Hits)
		if SERVER then
			self:Remove()
		end
	end

end

function ENT:GoYourWayBack(power)
		local targetPos = self:GetNWVector("targetPos")
		local Pos = self:GetPos()
		local ownerPos = self:GetNWEntity("BoomerangOwner"):GetShootPos() - Vector(0, 0, 10)
		self:SetVelocity(Vector(0,0,0))
		self:GetPhysicsObject():ApplyForceCenter((ownerPos - Pos):GetNormalized() * power)
		self.LastVelocity = (ownerPos - self:GetPos()):GetNormalized()
		self.TargetReached = true
		self:GetPhysicsObject():AddAngleVelocity(Vector(0,-1000,0) - self:GetPhysicsObject():GetAngleVelocity())
end


function ENT:NearOwner()
	local targetPos = self:GetNWVector("targetPos")
	local Pos = self:GetPos()
	local ownerPos = self:GetNWEntity("BoomerangOwner"):GetShootPos()
	--if Pos:Distance(ownerPos) < 100 then return true end
	if targetPos:Distance(ownerPos) < targetPos:Distance(Pos) - 20 then return true end
		
	return false
end

hook.Add("PlayerDeath", "BoomerangKill", function(victim, infl, attacker)
	if IsValid(infl) and infl:GetClass() == "ent_boomerangclose" then
		local rag = victim.server_ragdoll
		
		if rag then
			rag:SetCollisionGroup(COLLISION_GROUP_WORLD)
		end
		timer.Simple(0.5, function() 
			--if rag then rag:Remove() end
			if rag then rag:SetCollisionGroup(COLLISION_GROUP_WEAPON) end
		end)
	end
end)