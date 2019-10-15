AddCSLuaFile()
--[[
hook.Add( "ShouldCollide", "FuckOnTouch", function( a, b )
  if !IsValid(a) or !IsValid(b) then return end
  if !a.ttte and !b.ttte then return end
  if a:IsPlayer() or a:IsNPC() then return true end
  if b:IsPlayer() or b:IsNPC() then return true end
end )
]]

if SERVER then
  resource.AddWorkshop( "811718553" )
end

sound.Add( {
	name = "thomas_bell",
	channel = 19,
	volume = 1.0,
	level = 90,
	pitch = { 95, 110 },
	sound = "ttte/thomas_bell.wav"
} )

sound.Add( {
	name = "thomas_song_01",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_song_01.mp3"
} )

sound.Add( {
	name = "thomas_song_02",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_song_02.mp3"
} )

sound.Add( {
	name = "thomas_song_03",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_song_03.mp3"
} )

sound.Add( {
	name = "thomas_song_04",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_song_04.mp3"
} )

sound.Add( {
	name = "thomas_song_05",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_song_05.mp3"
} )
