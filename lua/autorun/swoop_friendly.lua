-- Don't try to edit this file if you're trying to add new NPCs.
-- Just make a new file and copy the format below.

local Category = "LittleBigPlanet"

local NPC = {
	Name = "Swoop (Friendly)",
	Class = "npc_citizen",
	Category = Category,
	Model = "models/player/Swoop.mdl",
	KeyValues = { citizentype = CT_UNIQUE },
}
list.Set( "NPC", "Swoop_npc", NPC )
