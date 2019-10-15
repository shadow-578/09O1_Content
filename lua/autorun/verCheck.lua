--09-O1 Content Pack version reporting
local VER = "2.1"

local function VerCheck_Server_Init()
	--Create ConVar that is replicated on the client
	CreateConVar("gm_content_version", VER, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "The content version running on the server.")

	--send debug log message
	MsgC(Color(210, 210, 20), "[Server]09-O1 Content Pack Version "..VER.."\n" )
	
	--add hook for player spawn
	hook.Add( "PlayerSpawn", "VerCheck_Player_Spawn_Check", function(ply)
		ply:SendLua("VerCheck_Client_Check()")
	end	)
end

local function VerCheck_Client_Init()
	--Create ConVar that is later replicated on the client
	CreateConVar("gm_content_version", "ERROR", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "The content version running on the server.")

	--debug print local version
	MsgC(Color(210, 210, 20), "[Client]09-O1 Content Pack Version "..VER.."\n" )
end

function VerCheck_Client_Check()
	if not CLIENT then return end
	
	--Get Version synced from Server
	local S_VER = GetConVar("gm_content_version"):GetString()
	
	--check version
	if not (VER == S_VER) then
		--version missmatch:
		--report in console
		MsgC(Color(250, 70, 0), "09-O1 Content Pack Version Mismatch!\n")
		MsgC(Color(250, 70, 0), "-Version     :\n"..VER)
		MsgC(Color(250, 70, 0), "-Version CVAR:\n"..S_VER)
		
		--give warning in chat
		chat.AddText(Color(250, 70, 0), "Du hast Version "..VER.." des 09-O1 Content Packs installiert, der Server verwendet jedoch Version "..S_VER.."!")
	end
end

--run init
if CLIENT then
	VerCheck_Client_Init()
end

if SERVER then
	VerCheck_Server_Init()
end