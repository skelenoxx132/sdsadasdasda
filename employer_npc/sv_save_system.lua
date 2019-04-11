util.AddNetworkString("ENPC.SaveSettingsGS")

hook.Add("Initialize", "ENPC.Initialize", function()
	file.CreateDir("employer_npc/map")
end)

local function SpawnJobEmployers()
	local map = string.lower(game.GetMap())
	local data = {}
	if file.Exists( "employer_npc/map/"..map..".txt" ,"DATA") then
		data = util.JSONToTable(file.Read( "employer_npc/map/"..map..".txt" ))
	end
	for k,v in pairs(data) do
		local emp_npc = ents.Create(v.Class)
		emp_npc:SetPos(v.Pos)
		emp_npc:SetAngles(v.Angle)
		emp_npc:Spawn()
		emp_npc:SetMoveType(MOVETYPE_NONE)
		emp_npc:SetCustomName(v.Name)
		emp_npc:SetModel(v.Model)
		emp_npc.whitelist = v.WhiteList

		for job,_ in pairs(emp_npc.whitelist) do
			ENPC.JobsUsed[job] = true
		end
	end

	MsgN("Employer NPCs spawned. [ "..#data.." ] ")
end

concommand.Add("emp_npc_save", function(ply)

	if IsValid(ply) and not ply:IsSuperAdmin() then return end

	local tblSave = {}
	for k,v in pairs(ents.FindByClass("employer_npc")) do
		local tbl = {
			Class = v:GetClass(),
			Name = v:GetCustomName(),
			Model = v:GetModel(),
			WhiteList = v.whitelist,
			Pos = v:GetPos(),
			Angle = v:GetAngles(),
		}
		table.insert(tblSave, tbl)
		v:Remove()
	end


	local map = string.lower(game.GetMap())
	file.Write("employer_npc/map/"..map..".txt", util.TableToJSON(tblSave))


	if IsValid(ply) then ply:ChatPrint("NPCs saved.") end

	SpawnJobEmployers()
end)

hook.Add( "InitPostEntity", "ENPC.InitPostEntity", function()
	SpawnJobEmployers()
end)

hook.Add("PostCleanupMap", "ENPC.PostCleanupMap", function()
	SpawnJobEmployers()
end)

net.Receive("ENPC.SaveSettingsGS", function(len, ply)
	if not ply:IsSuperAdmin() then return end
	local ent = net.ReadEntity()
	local info = net.ReadTable()

	ent:SetCustomName(info.name)
	ent.whitelist = info.whitelist
	ent:SetModel(info.model)
	RunConsoleCommand("emp_npc_save")
end)
