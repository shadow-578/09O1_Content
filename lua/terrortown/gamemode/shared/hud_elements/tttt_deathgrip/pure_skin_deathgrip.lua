if SERVER then resource.AddFile("materials/vgui/ttt/icon_deathgrip.vmt") end

local base = "pure_skin_target"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base
HUDELEMENT.icon = Material("vgui/ttt/icon_deathgrip")

if CLIENT then -- CLIENT

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		huds.GetStored("pure_skin"):ForceElement(self.id)
	end

	function HUDELEMENT:Draw()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local tgt = ply.DeathGripPartner

		if HUDEditor.IsEditing then
			self:DrawComponent("- DeathGrip -")
		elseif tgt and IsValid(tgt) and ply:IsActive() then
			self:DrawComponent(tgt:Nick())
		end
	end
end
