util.AddNetworkString("TTT2DeathgripAnnouncement")
util.AddNetworkString("TTT2DeathgripPartner")
util.AddNetworkString("TTT2DeathgripAnnouncementDeath")
util.AddNetworkString("TTT2DeathgripReset")

local deathgrip_enabled = CreateConVar("ttt2_deathgrip", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
local deathgrip_min_players = CreateConVar("ttt2_deathgrip_min_players", "4", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
local deathgrip_chance = CreateConVar("ttt2_deathgrip_chance", "0.5", {FCVAR_NOTIFY, FCVAR_ARCHIVE})

hook.Add("TTT2SyncGlobals", "TTT2DeathgripSyncGlobals", function()
	SetGlobalBool("ttt2_deathgrip", deathgrip_enabled:GetBool())
	SetGlobalInt("ttt2_deathgrip_min_players", deathgrip_min_players:GetInt())
	SetGlobalFloat("ttt2_deathgrip_chance", deathgrip_chance:GetFloat())
end)

local function ResetDeathGrip()
	local plys = player.GetAll()
	for _, v in ipairs(plys) do
		v.DeathGripPartner = nil
	end

	net.Start("TTT2DeathgripReset")
	net.Broadcast()
end

cvars.AddChangeCallback(deathgrip_enabled:GetName(), function(name, old, new)
	SetGlobalBool(name, tobool(new))
	if tobool(new) == false then
		ResetDeathGrip()
	end
end, "TTT2DeathGripEnabledChange")

cvars.AddChangeCallback(deathgrip_min_players:GetName(), function(name, old, new)
	SetGlobalInt(name, new)
end, "TTT2DeathGripMinPlayersChange")

cvars.AddChangeCallback(deathgrip_chance:GetName(), function(name, old, new)
	SetGlobalFloat(name, new)
end, "TTT2DeathGripChanceChange")

local function NotifyPlayerDeathgrip(ply)
	net.Start("TTT2DeathgripPartner")
	net.WriteEntity(ply.DeathGripPartner)
	net.Send(ply)
end

local function AnnounceDeathgrip()
	net.Start("TTT2DeathgripAnnouncement")
	net.Broadcast()
end

local function AnnounceDeathgripDeath()
	net.Start("TTT2DeathgripAnnouncementDeath")
	net.Broadcast()
end

local function SelectDeathgripPlayers()
	if not TTT2 or not GetGlobalBool("ttt2_deathgrip", false) or math.random(0, 1) < GetGlobalFloat("ttt2_deathgrip_chance", 0.5) then return end

	local players = util.GetFilteredPlayers(function (ply)
		return ply:IsTerror() and (not SHINIGAMI or not ply:IsShinigami())
	end)

	-- minimum 2 players to work
	if #players < 2 or #players < GetGlobalInt("ttt2_deathgrip_min_players", 4) then return end

	local p1index = math.random(1, #players)
	local p1 = players[p1index]
	table.remove(players, p1index)
	local p2index = math.random(1, #players)
	local p2 = players[p2index]

	--Set DeathGrip relation
	p1.DeathGripPartner = p2
	p2.DeathGripPartner = p1

	NotifyPlayerDeathgrip(p1)
	NotifyPlayerDeathgrip(p2)

	AnnounceDeathgrip()
end

local function OnPlayerDisconnected(ply)
	if ply.DeathGripPartner then
		ResetDeathGrip()
	end
end

local function OnPlayerDeath(ply, inflictor, attacker)
	if ply.DeathGripPartner ~= nil and IsValid(ply.DeathGripPartner) then
		if ply.DeathGripPartner:IsTerror() and ( attacker:IsPlayer() or inflictor:IsPlayer() ) and attacker ~= play and inflictor ~= ply then

			-- kill the other player
			local dmginfo = DamageInfo()
		    dmginfo:SetDamage(10000)
		    dmginfo:SetAttacker(game.GetWorld())
		    dmginfo:SetDamageType(DMG_GENERIC)
		    ply.DeathGripPartner:TakeDamageInfo(dmginfo)

			MsgN("[TTT2][DeathGrip] Killed the DeathGrip Partner.")

			AnnounceDeathgripDeath()
		end
		MsgN("[TTT2][DeathGrip] Reset DeathGrip after death...")
		ResetDeathGrip()
	end
end
hook.Add("PlayerDisconnected", "TTT2RemoveDeathGrip", OnPlayerDisconnected)
hook.Add("TTTBeginRound", "TTT2DeathGripSelectPlayers", SelectDeathgripPlayers)
hook.Add("TTTPrepareRound", "TTT2DeathGripReset", ResetDeathGrip)
hook.Add("TTTEndRound", "TTT2DeathGripReset", ResetDeathGrip)
hook.Add("PlayerDeath", "TTT2DeathGripDeathCheck", OnPlayerDeath)
