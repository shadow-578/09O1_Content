if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("deathgrip/cl_init.lua")
end

if SERVER then
	include("deathgrip/init.lua")
else
	include("deathgrip/cl_init.lua")
end
