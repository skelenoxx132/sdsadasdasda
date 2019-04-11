ENPC.Colors = {
	bg = Color(34, 37, 41),
	s_bg = Color(45, 49, 54),
	header = Color(57, 62, 68),

	f_list = Color(200,200,200),

	icons = Color(90,90,90),
	icons_a = Color(150,150,150),

	unavailable = Color(100,100,100)
}

ENPC.EnableRandomSequences = true -- Enable random sequences for player model
ENPC.EnableBlur = true -- Enable blur theme
ENPC.Lang = "fr" -- Now supported en, fr, ru, es, de, no

ENPC.StoreJobsBy = "name" -- Options how jobs will be stored in database: "name" and "command"

ENPC.DisableChangeTeam = true -- Disables change team via F4(ENPC.DisableChangeUsed need to be disabled)
ENPC.DisableChangeUsed = false -- Disables change only for job used in NPC(ENPC.DisableChangeTeam need to be disabled)

ENPC.Ranks = {  -- they ignore Utime and level rules
	-- ["superadmin"] = true,
	["vip"] = true,
}

ENPC.CanBypass = { -- change to false, to disable it
	["utime"] = true,
	["level"] = true,
	["customcheck"] = true,
	["countlimit"] = true,
	["jobcost"] = false, -- disables job required rights too
}
