CreateConVar("pm_lef_disable", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "If enabled, the player model is disabled")
if GetConVar("pm_lef_disable"):GetBool() then return end

player_manager.AddValidModel( "Lefering", "models/player/lefpm/barley.mdl" )
 
list.Set( "PlayerOptionsModel",  "Lefering", "models/player/lefpm/barley.mdl" )
--Add NPC
local Category = "Vengeance"

local NPC = { 	Name = "Lefering", 
				Class = "npc_citizen",
				Model = "models/player/lefpm/barley.mdl",
				Health = "10000000",
				KeyValues = { citizentype = 4 },
                                Category = Category    }

list.Set( "NPC", "lefering", NPC )