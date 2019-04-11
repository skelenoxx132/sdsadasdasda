ENPC = ENPC or {}

-- Thanks aStonedPenguin for solution
local include_sv = (SERVER) and include or function() end
local include_cl = (SERVER) and AddCSLuaFile or include
local include_sh = function(f)
	include_sv(f)
	include_cl(f)
end

-- VGUI Elements loading
local files, _ = file.Find("employer_npc/vgui/*.lua", "LUA")

for _, f in ipairs(files) do
	include_cl("employer_npc/vgui/"..f)
end

-- System loading
include_sh("employer_npc/config_lang.lua")
include_sh("employer_npc/config.lua")
include_sh("employer_npc/sh_core.lua")
include_sv("employer_npc/sv_core.lua")
include_sv("employer_npc/sv_save_system.lua")
include_cl("employer_npc/cl_util.lua")
include_cl("employer_npc/cl_core.lua")
