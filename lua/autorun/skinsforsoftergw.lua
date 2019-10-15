AddCSLuaFile()

--新浪微博：@戈登走過去

Category = "Softer Minecraft Player"

local NPC = {   
Name = "Good Steve", 
Class = "npc_citizen",
Weapons = { "weapon_smg1", "weapon_ar2" },
Model = "models/skinsforsoftergwsteve.mdl",
Category =  Category ,
KeyValues = { citizentype = 4 },
}
list.Set( "NPC", "npc_sstevegw1", NPC )

local NPC = {
Name = "Bad Steve", 
Class = "npc_combine_s",
Weapons = { "weapon_smg1", "weapon_ar2" },
Model = "models/skinsforsoftergwsteve2.mdl",
Category =  Category ,
KeyValues = { SquadName = "overwatch", Numgrenades = 5 }
}
list.Set( "NPC", "npc_sstevegw2", NPC )

local NPC = {   
Name = "Good Alex", 
Class = "npc_citizen",
Weapons = { "weapon_smg1", "weapon_ar2" },
Model = "models/skinsforsoftergwalex.mdl",
Category =  Category ,
KeyValues = { citizentype = 4 },
}
list.Set( "NPC", "npc_sstevegw3", NPC )

local NPC = {
Name = "Bad Alex", 
Class = "npc_combine_s",
Weapons = { "weapon_smg1", "weapon_ar2" },
Model = "models/skinsforsoftergwalex2.mdl",
Category =  Category ,
KeyValues = { SquadName = "overwatch", Numgrenades = 5 }
}
list.Set( "NPC", "npc_sstevegw4", NPC )


list.Set( "PlayerOptionsModel", "Softer Minecraft Player", "" )
player_manager.AddValidModel( "Softer Minecraft Player", "models/skinsforsoftergwpm.mdl" )
--手臂，懶得做！







