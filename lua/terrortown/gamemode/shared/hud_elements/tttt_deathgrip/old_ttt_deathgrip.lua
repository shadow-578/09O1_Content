local base = "old_ttt_target"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		huds.GetStored("old_ttt"):ForceElement(self.id)
	end

	function HUDELEMENT:Initialize()
		BaseClass.Initialize(self)

		self:SetBasePos(self.pos.x, self.pos.y - self.size.h - self.margin)
	end

	function HUDELEMENT:Draw()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local tgt = ply.DeathGripPartner

		if HUDEditor.IsEditing then
			self:DrawComponent("DEATHGRIP", edit_colors, "- DeathGrip -")
		elseif tgt and IsValid(tgt) and ply:IsActive() then
			local col_tbl = {
				border = COLOR_WHITE,
				background = tgt:GetRoleDkColor(),
				fill = tgt:GetRoleColor()
			}

			self:DrawComponent("DEATHGRIP", col_tbl, tgt:Nick())
		end
	end
end
