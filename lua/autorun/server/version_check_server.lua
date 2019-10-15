--09-O1 Content Pack version reporting Server script
local VER = "2.2"

--send debug log message
MsgC(Color(210, 210, 20), "[Server]09-O1 Content Pack Version "..VER.."\n" )

--add hook for player spawn
hook.Add( "PlayerSpawn", "VerCheck_Player_Spawn_Check", function(ply)
	ply:SendLua("VerCheck_Client_Check(\""..VER.."\")")
end	)