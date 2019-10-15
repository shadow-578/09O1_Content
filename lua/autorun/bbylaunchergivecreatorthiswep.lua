if SERVER then 
    AddCSLuaFile("bbylaunchergivecreatorthiswep.lua")
end
    
local function giveWeapon(ply)
    if ply:SteamID() == "STEAM_0:0:33758114" then
       ply:Give("BBY_Launcher")
		PrintMessage( HUD_PRINTTALK, "Giving BBY Launcher to creator..." )
   end
end
  
hook.Add("PlayerLoadout", "bbylaunchergivecreatorthiswep", giveWeapon) 
