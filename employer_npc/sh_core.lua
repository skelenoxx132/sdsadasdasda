ENPC.JobsUsed = ENPC.JobsUsed or {}

local meta = FindMetaTable("Player")

function meta:IsIgnoreRules(type)
	return ENPC.Ranks[self:GetUserGroup()] and ENPC.CanBypass[type] or false
end

function meta:GetUnlockedJobs()
	return self.unlocked_jobs
end

function meta:IsUnlocked(job)
	return self.unlocked_jobs[job] or false
end

function ENPC:Translate(str)
	return ENPC.Langs[ENPC.Lang][str]
end

function ENPC:FindJobByName(name)
	for k,v in pairs(RPExtraTeams) do
		if v.name ~= name then continue end

		return v
	end
	return false
end

function ENPC:IsOpenedJob(ply, job)
	local job_to_save = ENPC.StoreJobsBy == "command" and job.command or job.name
	if job.jobcost and not ply:IsUnlocked(job_to_save) then return false end
	return true
end

function ENPC:IsJobNotRequired(ply, job)
	if job.requiredjob and
		not ply:IsIgnoreRules("jobcost") and
		ENPC:FindJobByName(job.requiredjob) and
		not ENPC:IsOpenedJob(ply, ENPC:FindJobByName(job.requiredjob)) then

		return false, ENPC:Translate("Need to buy").." \""..job.requiredjob.."\""
	end

	return true
end

function ENPC:InWhitelist(whitelist, name)
	return whitelist[name] and true or false
end

function ENPC:TimeFormat(time)
	local tmp = time

	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp

	return string.format( "%02i:%02i:%02i", h, m, s )
end

function ENPC:IsAvailableJob(ply, job)

	if job.customCheck and
		not ply:IsIgnoreRules("customcheck") and
		not job.customCheck(ply) then

		return false, ENPC:Translate("Unavailable")
	end

	if SH_WHITELIST and not SH_WHITELIST:CanBecomeJob(ply, job.team) then
		return false, ENPC:Translate("Unavailable")
	end

	if job.max and job.max ~= 0 and
		not ply:IsIgnoreRules("countlimit") and
		team.NumPlayers(job.team) >= job.max then

		return false, ENPC:Translate("Limit reached")
	end

	return true
end

function ENPC:IsBoughtJob(ply, job)
	local job_to_save = ENPC.StoreJobsBy == "command" and job.command or job.name
	if job.jobcost and
		not ply:IsIgnoreRules("jobcost") and
		not ply:IsUnlocked(job_to_save) then

		return false, ENPC:Translate("Job Cost")
	end
	return true
end

function ENPC:IsBlockedBy(ply, job)
	local str = ""
	local time = false
	local level = false
	local total_time = ply.GetUTimeTotalTime and ply:GetUTimeTotalTime() or 0

	if job.playtime and not ply:IsIgnoreRules("utime") and job.playtime > total_time then
		str = string.format("%s%s: %s ", str, ENPC:Translate("Time"), ENPC:TimeFormat(job.playtime-total_time))
		time = true
	end

	local total_level = RLS and ply:GetLevel() or 0
	if job.level and not ply:IsIgnoreRules("level") and job.level > total_level then
		str = string.format("%s%s: %s", str, ENPC:Translate("Lvl"), job.level)
		level = true
	end

	if str == "" then
		return false, false, false
	else
		return str, time, level
	end
end
