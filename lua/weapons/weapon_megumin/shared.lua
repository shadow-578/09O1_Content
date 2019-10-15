AddCSLuaFile()
 
if (SERVER) then
	CreateConVar( "meguminstaff_voiceline", 1, FCVAR_ARCHIVE, "Plays a Megumin voiceline when casting an explosion.")
	CreateConVar( "meguminstaff_godmode", 1, FCVAR_ARCHIVE, "Allow the caster to be immune to the explosion.")
	CreateConVar( "meguminstaff_extraeffects", 1, FCVAR_ARCHIVE, "Allow additional explosion particle effects to play.")
	CreateConVar( "meguminstaff_ragdoll", 1, FCVAR_ARCHIVE, "Allow the caster to be ragdolled after casting the explosion.")
	CreateConVar( "meguminstaff_reraycast", 1, FCVAR_ARCHIVE, "Allow the caster to change the position the cast strikes (while the spell is beign cast)")

	CreateConVar( "meguminstaff_radius", 1400, FCVAR_ARCHIVE, "The radius explosion damage is dealt in.")
	CreateConVar( "meguminstaff_damage", 500, FCVAR_ARCHIVE, "The explosion damage dealt.")
	CreateConVar( "meguminstaff_ragdoll_length", 10, FCVAR_ARCHIVE, "The length of the ragdoll in seconds.")
end

if (CLIENT) then
	SWEP.PrintName			= "Explosion Staff"
	SWEP.Author				= "jaek"
	SWEP.Purpose 			= "A mage staff that comprises magical embers that ignite explosions."
	SWEP.Instructions 		= "PRIMARY: Cast explosion spell"
 
	SWEP.Slot 				= 4
	SWEP.SlotPos 			= 1
	SWEP.ViewModelFOV		= 75
	
	SWEP.BounceWeaponIcon	= false

	SWEP.ShowViewModel 		= false
	SWEP.ShowWorldModel 	= false

	SWEP.VElements = {
		["ball"] = { type = "Model", model = "models/XQM/Rails/gumball_1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "staff", pos = Vector(0, 0.317, 66.428), angle = Angle(0, 0, 0), size = Vector(0.239, 0.239, 0.239), color = Color(150, 0, 85, 0), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["ball+"] = { type = "Model", model = "models/XQM/Rails/gumball_1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "staff", pos = Vector(0, 0.317, 66.428), angle = Angle(0, 0, 0), size = Vector(0.219, 0.219, 0.219), color = Color(255, 0, 0, 0), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["staff"] = { type = "Model", model = "models/player/bozoxx/megumin/staff/meguminstaff.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-1.147, 1.378, 29.791), angle = Angle(180, 90, 7.5), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["ball"] = { type = "Model", model = "models/XQM/Rails/gumball_1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "staff", pos = Vector(0, 0.317, 66.428), angle = Angle(0, 0, 0), size = Vector(0.239, 0.239, 0.239), color = Color(150, 0, 85, 0), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["ball+"] = { type = "Model", model = "models/XQM/Rails/gumball_1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "staff", pos = Vector(0, 0.317, 66.428), angle = Angle(0, 0, 0), size = Vector(0.219, 0.219, 0.219), color = Color(255, 0, 0, 0), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["staff"] = { type = "Model", model = "models/player/bozoxx/megumin/staff/meguminstaff.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-3.623, -0.211, 27.493), angle = Angle(180, 75, 15), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	killicon.Add("weapon_megumin", "vgui/killicons/megumin/weapon_megumin", color_white)
end

print ("megustaff init abcdef")
local meguminPmLoc = "models/player/olddeath/megumin/megumin.mdl"

SWEP.Base = "weapon_tttbase"
SWEP.Kind = EQUIP2
SWEP.Spawnable			= true

SWEP.HoldType 				= "pistol"

SWEP.ViewModel 				= "models/weapons/c_stunstick.mdl"
SWEP.WorldModel 			= "models/weapons/w_stunbaton.mdl"
SWEP.UseHands				= true

SWEP.Primary.DefaultClip 	= 1
SWEP.Primary.ClipSize 		= 1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "none"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo 		= "none"

--cannot buy, you have to be choosen :P
SWEP.CanBuy = {}
SWEP.LimitedStock = true
SWEP.AllowDrop = true

SWEP.ExplosionCast = nil
SWEP.IsSpellActive = nil

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetDeploySpeed(1.1)

	PrecacheParticleSystem("bomb_explosion_huge")
	PrecacheParticleSystem("explosion_huge")
	PrecacheParticleSystem("explosion_silo")

	if CLIENT then
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels

		// init view model bone build function
		if IsValid(self:GetOwner()) then
			local vm = self:GetOwner():GetViewModel()
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

function SWEP:PreDrawViewModel(vm)
	if self.ShowViewModel == false then
		render.SetBlend(0)
	end
end

function SWEP:PostDrawViewModel(vm)
	if self.ShowViewModel == false then
		render.SetBlend(1)
	end
end

function SWEP:Holster()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end

	return true

end

function SWEP:OnRemove()
	timer.Destroy("explosioncast")
	timer.Destroy("explosion")
	timer.Destroy("explosioneffects")
	timer.Destroy("stopeffects")
	timer.Destroy("ragdoll")

	self.ExplosionCast = nil

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

		local owner = self:GetOwner()
		if owner:IsValid() then
			local boneindex = owner:LookupBone("valvebiped.bip01_r_hand")
			if boneindex then
				local pos, ang = owner:GetBonePosition(boneindex)
				if pos then
					if self.ExplosionCast then
						local rdelta = math.min(0.5, CurTime() - 5)

						local force = rdelta * 140
						local resist = force * 0.5

						pos = pos + ang:Up() * -36 + ang:Forward() * 14 + ang:Right() * 4

						local curvel = owner:GetVelocity() * 0.5
						local emitter = ParticleEmitter(pos)
						emitter:SetNearClip(24, 48)

						for i=1, math.min(16, math.ceil(FrameTime() * 200)) do
							local particle = emitter:Add("particles/fire_glow", pos)
							particle:SetColor(185, 0, 85)
							particle:SetVelocity(curvel + VectorRand():GetNormalized() * force)
							particle:SetDieTime(1)
							particle:SetStartAlpha(rdelta * 125 + 15)
							particle:SetEndAlpha(0)
							particle:SetStartSize(10)
							particle:SetEndSize(rdelta * 10 + 4)
							particle:SetAirResistance(resist)
						end
						emitter:Finish() emitter = nil collectgarbage("step", 64)
					end
				end
			end
		end

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

function SWEP:OnDrop()
	timer.Destroy("explosioncast")
	timer.Destroy("explosion")
	timer.Destroy("explosioneffects")
	timer.Destroy("stopeffects")
	timer.Destroy("ragdoll")
	
	--cannot drop staff
	self:Remove();
end

function SWEP:PrimaryAttack()
	if (not (self.Owner:GetModel() == meguminPmLoc) or self:Clip1() <= 0) and SERVER then
		--not worthy, remove weapon :P
		print("megu_not_worth_remm")
		--self.Owner:DropWeapon( self )
		self:Remove();
		return end
	--end

	local voiceline = cvars.Bool("meguminstaff_voiceline", false)
	local castingsound = voiceline and "weapons/megumin/explosioncast_vo.mp3" or "weapons/megumin/explosioncast.mp3"

	local godmode = cvars.Bool("meguminstaff_godmode", true)
	local exeffects = cvars.Bool("meguminstaff_extraeffects", true)

	local radius = cvars.Number("meguminstaff_radius", 1400)
	local damage = cvars.Number("meguminstaff_damage", 500)

	local tr = self.Owner:GetEyeTrace()
	if tr.HitSky then return end

	self:EmitSound("ambient/fire/mtov_flame2.wav")

	self:SetHoldType("magic")

	self.ExplosionCast = true
	self.IsSpellActive = true

	if tr then
		if CLIENT then
			self.VElements["ball"].color = Color(150, 0, 85, 255)
			self.VElements["ball+"].color = Color(255, 0, 0, 255)
			self.WElements["ball"].color = Color(150, 0, 85, 255)
			self.WElements["ball+"].color = Color(255, 0, 0, 255)

			self.VElements["ball"].material = "models/alyx/emptool_glow"
			self.VElements["ball+"].material = "models/props_lab/cornerunit_cloud"
			self.WElements["ball"].material = "models/alyx/emptool_glow"
			self.WElements["ball+"].material = "models/props_lab/cornerunit_cloud"
		end

		if SERVER then
			--for k, v in pairs(player.GetAll()) do
			--	--v:ChatPrint(self.Owner:Nick().." has begun casting an explosion spell.")
			--	v:EmitSound(castingsound)
			--end
			self.Owner:EmitSound(castingsound)
			self.Owner:PrintMessage(HUD_PRINTCENTER, "Explosion spell cast in 10 seconds")

			timer.Create("explosioncast", 10, 1, function()
				self:EmitSound("ambient/fire/mtov_flame2.wav")
				sound.Play("weapons/mortar/mortar_shell_incomming1.wav", tr.HitPos, 100, 100)
			end)
		end

		timer.Create("explosion", 11, 1, function()
			self:SetHoldType("pistol")
			self.ExplosionCast = nil

			if CLIENT then
				self.VElements["ball"].color = Color(150, 0, 85, 0)
				self.VElements["ball+"].color = Color(255, 0, 0, 0)
				self.WElements["ball"].color = Color(150, 0, 85, 0)
				self.WElements["ball+"].color = Color(255, 0, 0, 0)

				self.VElements["ball"].material = ""
				self.VElements["ball+"].material = ""
				self.WElements["ball"].material = ""
				self.WElements["ball+"].material = ""
			end

			if SERVER then
				for k, v in pairs(player.GetAll()) do
					v:EmitSound("ambient/explosions/exp1.wav")
				end
			end 

			timer.Create("explosioneffects", 0.6, 1, function()
				--retrace
				if GetConVar("meguminstaff_reraycast"):GetBool() then
					tr = self.Owner:GetEyeTrace()
					if tr.HitSky then return end
					if not tr then return end
				end
			
				if exeffects then
					ParticleEffect("bomb_explosion_huge", tr.HitPos, angle_zero, self.Owner)
					ParticleEffect("explosion_silo", tr.HitPos, angle_zero, self.Owner)
				end

				ParticleEffect("explosion_huge", tr.HitPos, angle_zero, self.Owner)

				if SERVER then
					if godmode then
						self.Owner:GodEnable()
						util.BlastDamage(self, self.Owner, tr.HitPos, radius, damage)
						self.Owner:GodDisable()
					else
						util.BlastDamage(self, self.Owner, tr.HitPos, radius, damage)
					end

					util.ScreenShake(tr.HitPos, 16, 230, 6, 16384)

					for k, v in pairs(player.GetAll()) do
						v:EmitSound("ambient/explosions/explode_4.wav")
						v:EmitSound("ambient/explosions/explode_6.wav")
						v:EmitSound("ambient/explosions/explode_9.wav")
						v:EmitSound("npc/env_headcrabcanister/explosion.wav")
					end

					timer.Create("ragdoll", 0.5, 1, function()
						self:Ragdoll()
					end)
					
					timer.Create("megu_spellunactive", cvars.Number("meguminstaff_ragdoll_length", 10) + 2, 1, function()
						--remove staff
						if not SERVER then return end
						self.Owner:DropWeapon( self )
						self:Remove();
					end)
				end

				timer.Create("stopeffects", 8, 1, function()
					for k, v in pairs(player.GetAll()) do
						v:StopParticles()
					end
				end)
			end)
		end)
	end
	
	self:TakePrimaryAmmo(1)
	self:SetNextPrimaryFire(CurTime() + 20)
end

function SWEP:SecondaryAttack()
end

//	pulled from ulx. they did it better than i would've.

function SWEP:Ragdoll()
	local ragdoll = cvars.Bool("meguminstaff_ragdoll", true)
	local length = cvars.Number("meguminstaff_ragdoll_length", 10)

	local owner = self:GetOwner()

	if ragdoll then
		if owner:InVehicle() then
			local vehicle = owner:GetParent()
			owner:ExitVehicle()
		end

		self:GetSpawnInfo(owner)

		local ragdoll = ents.Create( "prop_ragdoll" )
		ragdoll:SetPos(owner:GetPos())
		local velocity = owner:GetVelocity()
		ragdoll:SetAngles(owner:GetAngles())
		ragdoll:SetModel(owner:GetModel())
		ragdoll:Spawn()
		ragdoll:Activate()
		owner:SetParent(ragdoll)

		local j = 1
		while true do
			local phys_obj = ragdoll:GetPhysicsObjectNum( j )
			if phys_obj then
				phys_obj:SetVelocity( velocity )
				j = j + 1
			else
				break
			end
		end

		owner:Spectate( OBS_MODE_CHASE )
		owner:SpectateEntity( ragdoll )
		--owner:StripWeapons()

		owner:PrintMessage(HUD_PRINTCENTER, "Ragdolled for "..length.." seconds")
		owner:EmitSound("player/pl_fallpain"..(math.random(2) == 1 and 3 or 1)..".wav")

		timer.Create("unragdoll", length, 1, function()
			owner:SetParent()

			owner:UnSpectate()

			doSpawn(owner, true)

			local pos = ragdoll:GetPos()
			pos.z = pos.z + 10
			owner:SetPos( pos )
			owner:SetVelocity( ragdoll:GetVelocity() )
			local yaw = ragdoll:GetAngles().yaw
			owner:SetAngles( Angle( 0, yaw, 0 ) )
			ragdoll:Remove()
		end)
	end
end

function SWEP:GetSpawnInfo( ply )
	local result = {}

	local t = {}
	ply.SpawnInfo = t
	t.health = ply:Health()
	t.armor = ply:Armor()
	if ply:GetActiveWeapon():IsValid() then
		t.curweapon = ply:GetActiveWeapon():GetClass()
	end

	local weps = ply:GetWeapons()
	local data = {}
	for _, weapon in ipairs( weps ) do
		printname = weapon:GetClass()
		data[ printname ] = {}
		data[ printname ].clip1 = weapon:Clip1()
		data[ printname ].clip2 = weapon:Clip2()
		data[ printname ].ammo1 = ply:GetAmmoCount( weapon:GetPrimaryAmmoType() )
		data[ printname ].ammo2 = ply:GetAmmoCount( weapon:GetSecondaryAmmoType() )
	end
	t.data = data
end

local function doWeapons( ply, t )
	if not ply:IsValid() then return end -- Drat, missed 'em.

	--ply:StripAmmo()
	--ply:StripWeapons()
    --
	--for printname, data in pairs( t.data ) do
	--	ply:Give( printname )
	--	local weapon = ply:GetWeapon( printname )
	--	if not weapon == nil then
	--		weapon:SetClip1( data.clip1 )
	--		weapon:SetClip2( data.clip2 )
	--		ply:SetAmmo( data.ammo1, weapon:GetPrimaryAmmoType() )
	--		ply:SetAmmo( data.ammo2, weapon:GetSecondaryAmmoType() )
	--	end
	--end
    --
	--if t.curweapon then
	--	ply:SelectWeapon( t.curweapon )
	--end
end

function doSpawn( ply, bool )
	ply:Spawn()

	if bool and ply.SpawnInfo then
		local t = ply.SpawnInfo
		ply:SetHealth( t.health )
		ply:SetArmor( t.armor )
		timer.Simple( 0.1, function() doWeapons( ply, t ) end )
		ply.SpawnInfo = nil
	end
end
