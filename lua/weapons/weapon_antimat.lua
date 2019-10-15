if CLIENT then // This is where the cl_init.lua stuff goes
 
	SWEP.PrintName = "Anti-Materiel Rifle"
 
	SWEP.DrawAmmo = true
 
	SWEP.DrawCrosshair = false
end
 
SWEP.Base = "weapon_tttbase"
 
SWEP.Spawnable = true 
SWEP.Kind = WEAPON_HEAVY
SWEP.AdminSpawnable = true 
SWEP.AutoSpawnable = false

SWEP.HoldType = "ar2"
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = true
SWEP.ViewModel = "models/weapons/v_epic_awp.mdl"
SWEP.WorldModel = "models/maxib123/antimaterialrifle.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["v_weapon.Right_Arm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 1.904, 0), angle = Angle(0, 0, 0) },
	["v_weapon.awm_parent"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0.5), angle = Angle(0, 0, 0) }
}
SWEP.VElements = {
	["pipboy"] = { type = "Model", model = "models/llama/pipboy3000.mdl", bone = "v_weapon.Right_Arm", rel = "", pos = Vector(-9.546, -2.274, 0.593), angle = Angle(-41.932, -103.295, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["weapon"] = { type = "Model", model = "models/maxib123/antimaterialrifle.mdl", bone = "v_weapon.awm_parent", rel = "", pos = Vector(-0.456, -2.274, -9.546), angle = Angle(176.932, -93.069, -88.977), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["snipa"] = { type = "Model", model = "models/maxib123/antimaterialrifle.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-4.092, 0.274, 0.455), angle = Angle(90, -90, -6), size = Vector(1.059, 1.23, 1.343), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.Slot = 2
SWEP.SlotPos = 2

SWEP.Primary.Damage = 75
SWEP.Primary.ClipSize = 4 
SWEP.Primary.DefaultClip = 4
SWEP.Primary.ClipMax = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Recoil = 2
SWEP.Primary.Spread = 0.001
SWEP.Primary.Force = 50
SWEP.Secondary.Sound = Sound("Default.Zoom")
--SWEP.Primary.NumBullets = 1
SWEP.Primary.Delay = 1.50

SWEP.HeadshotMultiplier = 8

SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.Secondary.Delay = 0

function SWEP:PreDrop()
    self.Weapon:SetNWBool("Scoped", false)
    self:SetZoom(false)
    self:SetIronsights(false)
    return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
 
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end
 
	if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		if self.Weapon:GetNWBool("Scoped") then
		self.Weapon:SetNWBool("Scoped", false)
		self.Owner:GetViewModel():SetNoDraw(false)
		self.Owner:SetFOV( 0, 0.2 )	
		--self.MouseSensitivity = 1	
		timer.Simple(6.0, function()
		self.Weapon:SetNWBool("Scoped", true)
		end)
		timer.Simple(6.0, function()
		self.Owner:GetViewModel():SetNoDraw(true)
		end)
		timer.Simple(6.0, function()
		self.Owner:SetFOV( 10, 0.25 )
		end)
		end
		self:DefaultReload( ACT_VM_RELOAD )
                local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
                self.ReloadingTime = CurTime() + AnimationTime
                self:SetNextPrimaryFire(CurTime() + AnimationTime)
                self:SetNextSecondaryFire(CurTime() + AnimationTime)
    timer.Simple(1.0, function()
      self:EmitSound("weapons/riflesniper/wpn_sniperrifle_reloadpt1.wav")
		end)
		timer.Simple(2.0, function()
      self:EmitSound("weapons/riflesniper/wpn_sniperrifle_reloadpt2.wav")
		end)
		timer.Simple(3.0, function()
      self:EmitSound("weapons/riflesniper/wpn_sniperrifle_reloadpt3.wav")
		end)
		timer.Simple(3.2, function()
      self:EmitSound("weapons/riflesniper/wpn_sniperrifle_reloadpt4.wav")
		end)
		
 
	end
 
end


 
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self:SetIronsights( false )
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)		
  self.ShowWorldModel = false
    return true
end 
 
function SWEP:Think()
    self.ShowWorldModel = false
end
 
function SWEP:PrimaryAttack()

	if not FireSnd then FireSnd = {} end

	FireSnd[ 1 ] = "weapons/rifleantimat/wpn_antimaterialrifle_fire_2d_01.wav"
	FireSnd[ 2 ] = "weapons/rifleantimat/wpn_antimaterialrifle_fire_2d_02.wav"

	if ( !self:CanPrimaryAttack() ) then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:EmitSound(FireSnd[math.random(1, #FireSnd)])
	timer.Simple(0.7, function()
	self:EmitSound("weapons/rifleantimat/wpn_antimaterialrifle_reload.wav")
	end)
	self:FireBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumBullets, self.Primary.Spread)
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self.Owner:ViewPunch( Angle( -1, 0, 0 ) )
	self.Owner:MuzzleFlash()
end

function SWEP:SecondaryAttack()	
	if not self.Weapon:GetNWBool("Scoped") then
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)	
	self.Weapon:SetNWBool("Scoped", true)
	self.Owner:GetViewModel():SetNoDraw(true)
	self.Owner:SetFOV(20, 0.3)
	elseif self.Weapon:GetNWBool("Scoped") then
	self.Weapon:SetNWBool("Scoped", false)
	self.Owner:GetViewModel():SetNoDraw(false)
	self.Owner:SetFOV( 0, 0.2 )
	end
  self:EmitSound(self.Secondary.Sound)
end

function SWEP:AdjustMouseSensitivity()
  return (self.Weapon:GetNWBool("Scoped") and 0.2) or nil
end

function SWEP:CanPrimaryAttack()

	if ( self:Clip1() <= 0 ) then
 
//		self:EmitSound(self.NoAmmoSound)
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		self:SetNextSecondaryFire( CurTime() + 0.2 )
		self:Reload()
		return false
	end
	
	if self.Owner:WaterLevel() >= 3 then
		return false
	end
	
	return true
	
end

function SWEP:Initialize()

	// other initialize code goes here
	self:SetWeaponHoldType( self.HoldType )
	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	if self.Weapon:GetNWBool("Scoped") then
	self.Weapon:SetNWBool("Scoped", false)
	self:SetIronsights( false )	
  self:SetZoom(false)
	end
	return true
end

function SWEP:SetZoom(state)
    if CLIENT then
       return
    elseif IsValid(self.Owner) and self.Owner:IsPlayer() then
       if state then
          self.Owner:SetFOV(20, 0.3)
       else
          self.Owner:SetFOV(0, 0.2)
       end
    end
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
      self.ShowWorldModel = true
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

function SWEP:FireBullet(dmg, recoil, numbul, cone)

	numbul 		= numbul or 1
	cone 		= cone or 0.01

	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(cone, cone, 0)
	bullet.Tracer 	= math.random(1,4)
	if bullet.Num > 2 then
	bullet.Force 	= 0.1 * dmg
	else
	bullet.Force 	= 0.25 * dmg
	end
	bullet.Damage 	= dmg
	bullet.Attacker = self.Owner
	
	self:FireBullets(bullet)

	if ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
		local eyeang = self.Owner:EyeAngles()
		if self.Weapon:GetNWBool("Iron") then
		eyeang.pitch = eyeang.pitch - recoil/1.75
		else
		eyeang.pitch = eyeang.pitch - recoil
		end
		self.Owner:SetEyeAngles(eyeang)
	end
	
	util.ScreenShake(self.Owner:GetPos() + Vector(0,0,27), 0.75*self.Primary.Recoil, 1, 0.75, 60)
	
	if self.Primary.Automatic == true then
	if self.Primary.Delay <= 0.066 then
	if self.Primary.Recoil < 1.5 then
	if self.Weapon:GetNWBool("Iron") then
	self.Primary.Recoil = self.Primary.Recoil + 0.04 * 0.6
	else
	self.Primary.Recoil = self.Primary.Recoil + 0.05 * 0.6
	end
	end
	if self.Primary.Recoil > 0.75 then
	util.ScreenShake(self.Owner:GetPos() + Vector(0,0,27), 1.6*self.Primary.Recoil, 1, 0.7, 60)
	end
	else
	if self.Primary.Recoil < 2.5 then
	if self.Weapon:GetNWBool("Iron") then
	self.Primary.Recoil = self.Primary.Recoil + 0.04
	else
	self.Primary.Recoil = self.Primary.Recoil + 0.05
	end
	end
	if self.Primary.Recoil > 0.75 then
	util.ScreenShake(self.Owner:GetPos() + Vector(0,0,27), 0.95*self.Primary.Recoil, 1, 0.7, 60)
	end
	end
	self.UnCoil = CurTime() + 0.5
	end
end

function SWEP:DrawHUD()
	if (CLIENT) then
	
	local Scale = ScrH()/480
	local w, h = 320*Scale, 240*Scale
	local cx, cy = ScrW()/2, ScrH()/2
	local scope_sniper_lr = surface.GetTextureID("sprites/scopes/scope_spring_lr")
	local scope_sniper_ll = surface.GetTextureID("sprites/scopes/scope_spring_ll")
	local scope_sniper_ul = surface.GetTextureID("sprites/scopes/scope_spring_ul")
	local scope_sniper_ur = surface.GetTextureID("sprites/scopes/scope_spring_ur")
	local SNIPERSCOPE_MIN = -0.75
	local SNIPERSCOPE_MAX = -2.782
	local SNIPERSCOPE_SCALE = 0.4
	--gets the center of the screen
	local x = ScrW() / 2.0
	local y = ScrH() / 2.0
 
	--set the drawcolor
	surface.SetDrawColor( 0, 0, 0, 255 )
 	local gap = 0
	local length = gap + 9999
	
	if self:GetNWBool("Scoped") then 

	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
	render.UpdateRefractTexture()
	surface.SetDrawColor(255,255,255,255)
	surface.SetTexture(scope_sniper_lr) surface.DrawTexturedRect(cx    , cy    , w, h)
	surface.SetTexture(scope_sniper_ll) surface.DrawTexturedRect(cx - w    , cy    , w, h)
	surface.SetTexture(scope_sniper_ul) surface.DrawTexturedRect(cx - w    , cy - h    , w, h)
	surface.SetTexture(scope_sniper_ur) surface.DrawTexturedRect(cx    , cy - h    , w, h)
	surface.SetDrawColor(0,0,0,255)
	if cx-w > 0 then
	surface.DrawRect(0, 0, cx-w, ScrH())
	surface.DrawRect(cx+w, 0, cx-w, ScrH())
	end
	end
end
end

function SWEP:SetIronsights( b )

	self.Weapon:SetNetworkedBool( "Ironsights", b )

end

function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0

	if ( !bIron && fIronTime < CurTime() - self.IronSightTime ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if ( fIronTime > CurTime() - self.IronSightTime ) then
	
		Mul = math.Clamp( (CurTime() - fIronTime) / self.IronSightTime, 0, 1 )
		
		if (!bIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.IronSightsPos
	
	if ( self.IronSightsAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
	
end

util.PrecacheSound("weapons/rifleantimat/wpn_antimaterialrifle_fire_2d_01.wav")
util.PrecacheSound("weapons/rifleantimat/wpn_antimaterialrifle_fire_2d_02.wav")
util.PrecacheSound("weapons/riflesniper/wpn_sniperrifle_reloadpt1.wav")
util.PrecacheSound("weapons/riflesniper/wpn_sniperrifle_reloadpt1.wav")
util.PrecacheSound("weapons/riflesniper/wpn_sniperrifle_reloadpt3.wav")
util.PrecacheSound("weapons/riflesniper/wpn_sniperrifle_reloadpt4.wav")