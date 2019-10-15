 /*
	Addon by FYK
 */
 
 player_manager.AddValidModel( "Sunshine Mario",     "models/player/assasinge/sunshine.mdl" );
 list.Set( "PlayerOptionsModel", "Sunshine Mario",   "models/player/assasinge/sunshine.mdl" );
 player_manager.AddValidHands( "Sunshine Mario", "models/player/assasinge/c_arms_sunshine.mdl", 0, "00000000" )
 
 local Category = "Super Mario Odyssey NPCs" 
 
 local NPC = {   Name = "Sunshine Mario",
                Class = "npc_citizen",
                Model = "models/player/assasinge/sunshine.mdl", 
                Health = "100", 
                KeyValues = { citizentype = 4 }, 
                Weapons = { "weapons_smg1" }, 
                Category = Category }
                               
list.Set( "NPC", "npc_suns_ally", NPC )

local Category = "Super Mario Odyssey NPCs" 
 
local NPC = {   Name = "Sunshine Mario Hostile", 
                Class = "npc_combine",
                Model = "models/player/assasinge/sunshine.mdl", 
                Health = "100", 
                Weapons = { "weapons_smg1" }, 
                Category = Category }
list.Set( "NPC", "npc_suns_hostile", NPC )