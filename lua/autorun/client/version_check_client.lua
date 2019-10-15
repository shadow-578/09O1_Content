--09-O1 Content Pack version reporting Client script
local VER = "2.6"

--debug print local version
MsgC(Color(210, 210, 20), "[Client]09-O1 Content Pack Version "..VER.."\n" )

--called via network on player spawn
function VerCheck_Client_Check(S_VER)
	if not CLIENT then return end
	
	print("Checking Content Version...")
	if not (VER == S_VER) then
		--version missmatch:
		--report in console
		MsgC(Color(250, 70, 0), "09-O1 Content Pack Version Mismatch!\n")
		MsgC(Color(250, 70, 0), "-Client Version:"..VER.."\n")
		MsgC(Color(250, 70, 0), "-Server Version:"..S_VER.."\n")
		
		--give warning in chat
		chat.AddText(Color(250, 70, 0), "Du hast Version "..VER.." des 09-O1 Content Packs installiert, der Server verwendet jedoch Version "..S_VER.."!")
	end
end