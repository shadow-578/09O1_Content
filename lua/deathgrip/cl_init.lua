local function DeathGripRoundInfoMessage()
	chat.AddText(COLOR_WHITE, "A dark voice whispers: Two players, bound by their soul, will die together!")
	chat.PlaySound()
end
net.Receive("TTT2DeathgripAnnouncement", DeathGripRoundInfoMessage)

local function DeathGripDeathInfoMessage()
	chat.AddText(COLOR_WHITE, "A dark voice whispers: The DeathGrip demanded its tribute and took their souls!")
	chat.PlaySound()
end
net.Receive("TTT2DeathgripAnnouncementDeath", DeathGripDeathInfoMessage)

local function DeathGripReset()
	MsgN("[TTT2][DeathGrip] Reset DeathGrip...")
	LocalPlayer().DeathGripPartner = nil
end
net.Receive("TTT2DeathgripReset", DeathGripReset)

local function DeathGripPartner()
	local partner = net.ReadEntity()
	if partner ~= nil and partner ~= "NULL" then
		LocalPlayer().DeathGripPartner = partner
		MsgN("[TTT2][DeathGrip] You were selected by the DeathGrip. And your soul was bound to " .. partner:Nick())
	end
end
net.Receive("TTT2DeathgripPartner", DeathGripPartner)
