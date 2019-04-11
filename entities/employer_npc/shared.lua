ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "JobNPC"
ENT.Author = "roni_sl"
ENT.Category = "Job Employers"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "CustomName")
end
