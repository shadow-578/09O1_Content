player_manager.AddValidModel("Megumin","models/player/olddeath/megumin/megumin.mdl")
player_manager.AddValidHands("Megumin","models/player/olddeath/megumin/megumin_c_arms.mdl",0,"10000000")
local meguPmLoc = "models/player/olddeath/megumin/megumin.mdl"
local repWeapon = "weapon_ttt_sipistol"

print("meguinit abcd")

hook.Add("TTTOrderedEquipment", "ddfjldfsaljsdafjsskl", function(ply, id, is_item)
	if not IsValid(ply) then return end

	--megumin has her own "silenced" pistol :P
	if tostring(id) == repWeapon and ply:GetModel() == meguPmLoc then	
		local spi = ply:GetWeapon(repWeapon)
		if spi == nil then return end
		
		ply:DropWeapon(spi);
		spi:Remove();
		
		ply:Give("weapon_megumin")
	end
	
end)