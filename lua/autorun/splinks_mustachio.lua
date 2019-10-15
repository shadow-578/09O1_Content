list.Set( "PlayerOptionsModel", "Splinks_Mustachio", "models/Splinks/Mustachio/Player_Mustachio.mdl" )
list.Set( "PlayerOptionsAnimations", "Splinks_Mustachio", { "idle_suitcase", "pose_standing_04" } )
player_manager.AddValidModel( "Splinks_Mustachio", "models/Splinks/Mustachio/Player_Mustachio.mdl" )
player_manager.AddValidHands( "Splinks_Mustachio", "models/Splinks/Mustachio/Arms_Mustachio.mdl", 0, "00000000" )


--Add NPC
local Category = "Mustachio"

local NPC = { 	Name = "Hostile Mustachio", 
				Class = "npc_combine_s",
				Model = "models/Splinks/Mustachio/Hostile_Mustachio.mdl",
				Health = "150",
				Squadname = "PLAGUE",
				Numgrenades = "4",
                                Category = Category    }

list.Set( "NPC", "Hostile_Mustachio", NPC )

local NPC = { 	Name = "Friendly Mustachio", 
				Class = "npc_citizen",
				Model = "models/Splinks/Mustachio/Friendly_Mustachio.mdl",
				Health = "700",
				KeyValues = { citizentype = 4 },
                                Category = Category    }

list.Set( "NPC", "Friendly_Mustachio", NPC )