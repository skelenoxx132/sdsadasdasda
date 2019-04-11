local CATEGORY_NAME = "EmployerNPC"

function ulx.addwhitelist( calling_ply, target_ply, job_name )
	
	target_ply:AddUnlockedJobs(job_name)

	ulx.fancyLogAdmin( calling_ply, "#A added #T to whitelist #s", target_ply, job_name )
end
local addwhitelist = ulx.command( CATEGORY_NAME, "ulx addwhitelist", ulx.addwhitelist, nil, false, false, true )
addwhitelist:addParam{ type=ULib.cmds.PlayerArg }
addwhitelist:addParam{ type=ULib.cmds.StringArg}
addwhitelist:defaultAccess( ULib.ACCESS_SUPERADMIN )
addwhitelist:help( "Add a user to specified whitelist." )

function ulx.removewhitelist( calling_ply, target_ply, job_name )
	
	target_ply:RemoveUnlockedJobs(job_name)

	ulx.fancyLogAdmin( calling_ply, "#A removed #T from whitelist #s", target_ply, job_name )
end
local removewhitelist = ulx.command( CATEGORY_NAME, "ulx removewhitelist", ulx.removewhitelist, nil, false, false, true )
removewhitelist:addParam{ type=ULib.cmds.PlayerArg }
removewhitelist:addParam{ type=ULib.cmds.StringArg}
removewhitelist:defaultAccess( ULib.ACCESS_SUPERADMIN )
removewhitelist:help( "Remove user from specified whitelist." )