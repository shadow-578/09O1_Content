player_manager.AddValidModel( "Psycho Andreas",                  "models/player/andreas/barley.mdl" )
 
list.Set( "PlayerOptionsModel",  "Psycho Andreas",                   "models/player/andreas/barley.mdl" )
--Add NPC
local Category = "Vengeance"

local NPC = { 	Name = "Psycho Andreas", 
				Class = "npc_citizen",
				Model = "models/player/andreas/barley.mdl",
				Health = "10000000",
				KeyValues = { citizentype = 4 },
                                Category = Category    }

list.Set( "NPC", "andreas", NPC )