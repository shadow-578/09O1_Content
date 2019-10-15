--Customized Ricardo PlayerModel with SOUND abilitys added
--based on https://steamcommunity.com/sharedfiles/filedetails/?id=1568428617 (Model)

CreateConVar("pm_ricardo_debug", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateConVar("pm_ricardo_exclusive", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateConVar("pm_ricardo_killswitch", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
local ricardoSoundFX = Sound("ugotthat_loop_edit.mp3")
local ricardoModelLoc = "models/player/ricardo.mdl"
print("Ricardo PM INIT abcd")


--original PlayerModel code START
list.Set( "PlayerOptionsModel",  "RICARDO", ricardoModelLoc)
player_manager.AddValidModel( "RICARDO", ricardoModelLoc);
--original PlayerModel code END

local function dbprint(msg) 
	if GetConVar("pm_ricardo_debug"):GetBool() then
		print(msg)
	end
end

if CLIENT then
	local keyTapFlag = false;
	local lastKeyState = false
	local notifyOnlyOnceFlag = false
	
	hook.Add("Think", "RicardoClientKeyCheckHook", function()
		if not IsValid(LocalPlayer()) then return end

		if not (LocalPlayer():GetModel() == ricardoModelLoc) and GetConVar("pm_ricardo_exclusive"):GetBool() then
			return end
		

		local keyState = input.IsKeyDown(KEY_B)

		if keyState then		
			if not keyTapFlag then
				--do shit once
			    lastKeyState = not lastKeyState
		       
			    dbprint("[Ricardo]KeyState change occured on CLIENT (new KeyState is "..tostring(keyState).."), sending NetMSG...")
			    net.Start("RicardoClientKeyStateChange")
			    net.WriteBool(lastKeyState)
			    net.SendToServer()
			end
			keyTapFlag = true
		else
			keyTapFlag = false
		end

		if LocalPlayer():GetModel() == ricardoModelLoc and not notifyOnlyOnceFlag then
			notifyOnlyOnceFlag = true
			LocalPlayer():ChatPrint("Have fun with Ricardo by tapping B :P")
		end	
	end)
end

if SERVER then
	util.AddNetworkString("RicardoClientKeyStateChange") 
	local readySounds = readySounds or {} 

	net.Receive("RicardoClientKeyStateChange", function(len, ply)
		if GetConVar("pm_ricardo_killswitch"):GetBool() then return end

		if not IsValid(ply) then return end
		
		--check player model here
		if not (ply:GetModel() == ricardoModelLoc) and GetConVar("pm_ricardo_exclusive"):GetBool() then
			return end
		--end
		
		local newKeyState = net.ReadBool()
		dbprint("[Ricardo]Received KeyStateChange NetMSG from "..ply:GetName()..". New state is "..tostring(newKeyState)..".")
		
		if readySounds[ply:SteamID()] == nil then
			--no sound for player, creat...
			readySounds[ply:SteamID()] = CreateSound(ply, ricardoSoundFX)	
			dbprint("[Ricardo]Creating sound entity for "..ply:GetName().."...")			
		end
		 		
		if newKeyState then
			if not readySounds[ply:SteamID()]:IsPlaying() then
				readySounds[ply:SteamID()]:Play()
				ply:DoAnimationEvent( ACT_GMOD_TAUNT_DANCE, 1642)

				--ensure that the player dances the WHOLE time (PERFECTLY timed here, WHY am i doing this?!)
				timer.Create(ply:EntIndex().."ricardo_dance_timer", 1, 7.125, function()
					if readySounds[ply:SteamID()]:IsPlaying() then
						ply:DoAnimationEvent( ACT_GMOD_TAUNT_DANCE, 1642)
					end
				end)
			end			
		else
			if readySounds[ply:SteamID()]:IsPlaying() then
				readySounds[ply:SteamID()]:Stop()
				timer.Stop(ply:EntIndex().."ricardo_dance_timer")

				--gmod feckery: Reset animation with 100ms delay so gmod has time to stop the dance repeat timer...
				timer.Simple(0.1, function()
					ply:DoAnimationEvent(ACT_RESET, 0)
				end)
			end
		end
	end)
end