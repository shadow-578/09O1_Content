--Add Playermodel
player_manager.AddValidModel( "Monika", "models/player/monika.mdl" )
player_manager.AddValidHands( "Monika", "models/arms/monika__arms.mdl", 0, "00000000" )

local Category = "[ULTIMATE] Doki Doki Literature Club"

local NPC =
{
	Name = "Monika (Friendly)",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Weapons = { "weapon_smg1", "weapon_pistol" },
	Model = "models/npc/monika_f.mdl",
	Category = Category
}

list.Set( "NPC", "monika_friendly", NPC )

local NPC =
{
	Name = "Monika (Enemy)",
	Class = "npc_combine_s",
	Numgrenades = "4",
	Model = "models/npc/monika_e.mdl",
	Weapons = { "weapon_stunstick" },
	Category = Category
}

list.Set( "NPC", "monika_enemy", NPC )
