--Add Playermodel
player_manager.AddValidModel( "Felix Argyle", "models/player/shi/Felix_Argyle.mdl" )
player_manager.AddValidHands( "Felix Argyle", "models/weapons/Felix_Argyle_Arms.mdl", 0, "00000000" )

--Add NPC
local NPC =
{
	Name = "Felix Argyle",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Model = "models/player/shi/Felix_NPC.mdl",
	Category = "Re:Zero"
}

list.Set( "NPC", "npc_Felix_Argyle", NPC )
