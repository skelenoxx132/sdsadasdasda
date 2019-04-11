resource.AddWorkshop("1156544861")

util.AddNetworkString("ENPC.OpenNPCInteractiveMenu")
util.AddNetworkString("ENPC.ChangeJobNPC")
util.AddNetworkString("ENPC.SyncJobs")
util.AddNetworkString("ENPC.PlayerIsLoaded")
util.AddNetworkString("ENPC.BuyJob")

hook.Add("playerCanChangeTeam", "ENPC.playerCanChangeTeam", function(ply, job, force)

	job = RPExtraTeams[job]

	if not force then
		if ENPC.DisableChangeUsed and ENPC.JobsUsed[job.name] then
			return false, ENPC:Translate("You should find NPC to change job")
		end

		if ENPC.DisableChangeTeam then
			return false, ENPC:Translate("You should find NPC to change job")
		end
	end
end)


hook.Add("ENPC.playerCanChangeTeam", "ENPC.playerCanChangeTeam", function(ply, job)

	job = RPExtraTeams[job]

	local time = ply.GetUTimeTotalTime and ply:GetUTimeTotalTime() or 0
	local level = RLS and ply:GetLevel() or 0
	local job_to_save = ENPC.StoreJobsBy == "command" and job.command or job.name

	if job.playtime and not ply:IsIgnoreRules("utime") and job.playtime > time then return false end
	if job.level and not ply:IsIgnoreRules("level") and job.level > level then return false end
	if job.customCheck and not ply:IsIgnoreRules("customcheck") and not job.customCheck(ply) then return false end
	if job.max and job.max ~= 0 and not ply:IsIgnoreRules("countlimit") and team.NumPlayers(job.team) >= job.max then return false end
	if job.jobcost and not ply:IsIgnoreRules("jobcost") and not ply:IsUnlocked(job_to_save) then return false end
	if job.requiredjob and not ply:IsIgnoreRules("jobcost") and not ENPC:IsOpenedJob(ply, ENPC:FindJobByName(job.requiredjob)) then return false end

	if SH_WHITELIST and not SH_WHITELIST:CanBecomeJob(ply, job.team) then
		return false, SH_WHITELIST.Language.not_whitelisted_for_job or "not_whitelisted_for_job"
	end

	return true
end)

net.Receive("ENPC.ChangeJobNPC", function(len, ply)
	local job_id = net.ReadInt(16)
	local skin_ = net.ReadInt(16)

	local result, msg = hook.Call("ENPC.playerCanChangeTeam", nil, ply, job_id)
	if result then
		ply:changeTeam(job_id, true)
		timer.Simple(0.1, function() ply:SetSkin(skin_) end)
	elseif msg then
		DarkRP.notify(ply, 1, 4, msg)
	end
end)

-- /*---------------------------------------------------------------------------
--  Buying Jobs
-- ---------------------------------------------------------------------------*/

local meta = FindMetaTable("Player")

function meta:SetUnlockedJobs(jobs)
	self.unlocked_jobs = jobs
	self:SyncJobs()
end

function meta:AddUnlockedJobs(job)
	self.unlocked_jobs[job] = true
	self:SyncJobs()
end

function meta:RemoveUnlockedJobs(job)
	self.unlocked_jobs[job] = nil
	self:SyncJobs()
end

function meta:SyncJobs()

	net.Start("ENPC.SyncJobs")
	net.WriteTable(self.unlocked_jobs)
	net.Send(self)

	MySQLite.query(string.format("UPDATE gs_employer_npc SET jobs = %s WHERE steamid = %s;",
		MySQLite.SQLStr(util.TableToJSON(self.unlocked_jobs)),
		MySQLite.SQLStr(self:SteamID())
	))
end

hook.Add("DatabaseInitialized", "ENPC.DatabaseInitialized", function()
	MySQLite.query("CREATE TABLE IF NOT EXISTS gs_employer_npc (steamid VARCHAR(255) PRIMARY KEY, jobs TEXT);")
end)

hook.Add( "PlayerIsLoaded", "ENPC.PlayerIsLoaded", function(ply)
	ply.unlocked_jobs = {} -- 76561198844156423

	local steamid = MySQLite.SQLStr(ply:SteamID())
	MySQLite.query(string.format("SELECT * FROM gs_employer_npc WHERE steamid = %s;", steamid), function(result)
		if result then
			local jobs = util.JSONToTable(result[1].jobs)
			ply:SetUnlockedJobs(jobs)
		else
			MySQLite.query(string.format("INSERT INTO gs_employer_npc(steamid, jobs) VALUES (%s, %s);",
				steamid,
				MySQLite.SQLStr('[]')
			))
			ply:SyncJobs()
		end
	end)
end)

net.Receive("ENPC.BuyJob", function(len,ply)
	local job_id = net.ReadInt(16)
	local job = RPExtraTeams[job_id]

	if ply:canAfford(job.jobcost) then

		ply:addMoney(-job.jobcost)

		local job_to_save = ENPC.StoreJobsBy == "command" and job.command or job.name
		ply:AddUnlockedJobs(job_to_save)

		DarkRP.notify(ply, 0, 4, ENPC:Translate("You unlocked").." "..job.name)
		ply:SendLua("surface.PlaySound('garrysmod/ui_click.wav')")
	else
		DarkRP.notify(ply, 1, 4, ENPC:Translate("You can't afford this job"))
	end
end)

net.Receive("ENPC.PlayerIsLoaded", function(len, ply)
	if ply.player_is_loaded then return end

	hook.Run("PlayerIsLoaded", ply)

	ply.player_is_loaded = true
end)
