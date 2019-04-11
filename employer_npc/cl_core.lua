surface.CreateFont("ENPC.Font21", { font = "Roboto", size = 22, weight = 500, extended = true })
surface.CreateFont("ENPC.Font18", { font = "Roboto", size = 19, weight = 300, extended = true })
surface.CreateFont("ENPC.Font16", { font = "Roboto", size = 16, weight = 300, extended = true })

local close_mat    = Material("job_employ/close.png", "noclamp smooth")
local settings_mat = Material("job_employ/settings.png", "noclamp smooth")
local clock_mat    = Material("job_employ/clock.png", "noclamp smooth")
local star_mat     = Material("job_employ/star.png", "noclamp smooth")
local lock_mat     = Material("job_employ/lock.png", "noclamp smooth")
local money_mat    = Material("job_employ/money.png", "noclamp smooth")

local function GetIconsTable(job)
	local tbl = {}

	if not ENPC:IsAvailableJob(LocalPlayer(), job) then
		table.insert(tbl, lock_mat)
	end

	local str, time, lvl = ENPC:IsBlockedBy(LocalPlayer(), job)
	local bought = ENPC:IsBoughtJob(LocalPlayer(), job)

	if time then table.insert(tbl, clock_mat) end
	if lvl then	table.insert(tbl, star_mat) end
	if not bought then table.insert(tbl, money_mat) end

	return tbl
end

function Derma_StringRequestCustom(whitelist, fnEnter, fnCancel)

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( ENPC:Translate("Add Job") )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )
	Window.Paint = function(slf, w, h)
		draw.RoundedBox(0, 0, 0, w, h, ENPC.Colors.header)
	end

	local InnerPanel = vgui.Create( "DPanel", Window )
	InnerPanel:SetPaintBackground( false )

	local NameLabel = vgui.Create("DLabel", InnerPanel)
	NameLabel:SetText(ENPC:Translate("Select Job")..":")
	NameLabel:SetPos(10, 10)
	NameLabel:SizeToContents()

	local DComboBox = vgui.Create( "DComboBox", InnerPanel )
	DComboBox:SetPos( 65, 7 )
	DComboBox:SetSize( 100, 20 )
	DComboBox:SetValue( ENPC:Translate("Jobs") )
	for k,v in pairs(RPExtraTeams) do
		if whitelist[v.name] then continue end
		DComboBox:AddChoice( v.name )
	end

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )
	ButtonPanel:SetPaintBackground( false )

	local Button = vgui.Create( "DButton", ButtonPanel )
	Button:SetText( ENPC:Translate("OK") )
	Button:SizeToContents()
	Button:SetTall( 20 )
	Button:SetWide( Button:GetWide() + 20 )
	Button:SetPos( 5, 5 )
	Button.DoClick = function() Window:Close() fnEnter( DComboBox:GetValue() ) end

	local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
	ButtonCancel:SetText( ENPC:Translate("Cancel") )
	ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( 20 )
	ButtonCancel:SetWide( Button:GetWide() + 20 )
	ButtonCancel:SetPos( 5, 5 )
	ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( DComboBox:GetValue() ) end end
	ButtonCancel:MoveRightOf( Button, 5 )

	ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

	local w, h = 135, 20

	Window:SetSize( w + 50, h + 25 + 75 + 10 )
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()

	return Window
end

local base_menu
local base

function ENPC:OpenSettingsMenu(ent, whitelist)
	if IsValid(base) then base:Remove() end
	if IsValid(base_menu) then base_menu:Remove() end

	base = vgui.Create("DFrame")
	base:SetSize(600, 625)
	base:Center()
	base:MakePopup()
	base:SetTitle(self:Translate("Settings"))
	base.Paint = function(slf, w, h)
		self:DrawBlurredPanel(slf)
		draw.RoundedBox(0, 0, 0, w, h, self.Colors.header)
	end

	base["ScrollPanel"] = vgui.Create("DScrollPanel", base)
	base["ScrollPanel"]:SetSize(base:GetWide(), base:GetTall()-25)
	base["ScrollPanel"]:SetPos(0, 25)
	base["ScrollPanel"].Paint = function(slf, w, h)
	end

	base["NameLabel"] = vgui.Create("DLabel", base["ScrollPanel"])
	base["NameLabel"]:SetText(self:Translate("Name of NPC"))
	base["NameLabel"]:SetPos(10, 20)
	base["NameLabel"]:SizeToContents()

	base["NameEntry"] = vgui.Create( "DTextEntry", base["ScrollPanel"] )
	base["NameEntry"]:SetPos( 75, 15 )
	base["NameEntry"]:SetSize( base:GetWide() -95, 25 )
	base["NameEntry"]:SetText( ent:GetCustomName() )

	base["ModelLabel"] = vgui.Create("DLabel", base["ScrollPanel"])
	base["ModelLabel"]:SetText(self:Translate("Model path"))
	base["ModelLabel"]:SetPos(10, 50)
	base["ModelLabel"]:SizeToContents()

	base["ModelEntry"] = vgui.Create( "DTextEntry", base["ScrollPanel"] )
	base["ModelEntry"]:SetPos( 75, 45 )
	base["ModelEntry"]:SetSize( base:GetWide() -95, 25 )
	base["ModelEntry"]:SetText( ent:GetModel() )

	base["NameLabel"] = vgui.Create("DLabel", base["ScrollPanel"])
	base["NameLabel"]:SetText(self:Translate("Jobs List")..":")
	base["NameLabel"]:SetPos(10, 75)
	base["NameLabel"]:SetFont("DermaLarge")
	base["NameLabel"]:SizeToContents()

	base["AvailableJob"] = vgui.Create("DListView", base["ScrollPanel"])
	base["AvailableJob"]:SetPos(5, 125)
	base["AvailableJob"]:SetSize(280, 420)
	base["AvailableJob"]:AddColumn(self:Translate("Available"))

	base["SelectedJob"] = vgui.Create("DListView", base["ScrollPanel"])
	base["SelectedJob"]:SetPos(315, 125)
	base["SelectedJob"]:SetSize(280, 420)
	base["SelectedJob"]:AddColumn(self:Translate("Selected"))

	for k,v in pairs(RPExtraTeams) do
		if self:InWhitelist(whitelist, v.name) then continue end
		base["AvailableJob"]:AddLine(v.name)
	end

	for k,v in pairs(whitelist) do
		base["SelectedJob"]:AddLine(k)
	end

	AddPriv = vgui.Create("DButton", base["ScrollPanel"])
	AddPriv:SetPos(287, 125)
	AddPriv:SetSize(25, 25)
	AddPriv:SetText(">")
	AddPriv.DoClick = function()
		for k,v in pairs(base["AvailableJob"]:GetSelected()) do
			local priv = v.Columns[1]:GetValue()
			base["SelectedJob"]:AddLine(priv)
			base["AvailableJob"]:RemoveLine(v.m_iID)
		end
	end

	RemPriv = vgui.Create("DButton", base["ScrollPanel"])
	RemPriv:SetPos(287, 155)
	RemPriv:SetSize(25, 25)
	RemPriv:SetText("<")
	RemPriv.DoClick = function()
		for k,v in pairs(base["SelectedJob"]:GetSelected()) do
			local priv = v.Columns[1]:GetValue()
			base["AvailableJob"]:AddLine(priv)
			base["SelectedJob"]:RemoveLine(v.m_iID)
		end
	end

	base["BtnSaveSettings"] = vgui.Create("DButton", base)
	base["BtnSaveSettings"]:SetPos(0,base:GetTall()-50)
	base["BtnSaveSettings"]:SetSize(base:GetWide(),50)
	base["BtnSaveSettings"]:SetText(self:Translate("Save"))
	base["BtnSaveSettings"]:SetFont("DermaLarge")
	base["BtnSaveSettings"]:SetTextColor(Color(255,255,255))
	base["BtnSaveSettings"].DoClick = function()
		local info = {
			name = base["NameEntry"]:GetValue(),
			model = base["ModelEntry"]:GetValue(),
		}
		info.whitelist = {}
		for k,v in pairs(base["SelectedJob"]:GetLines()) do
			info.whitelist[v:GetValue(1)] = true
		end
		net.Start("ENPC.SaveSettingsGS")
		net.WriteEntity(ent)
		net.WriteTable(info)
		net.SendToServer()

		base:Remove()
	end
	base["BtnSaveSettings"].Paint = function(slf, w, h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,100))

		local color = slf:IsHovered() and Color(255, 249, 149) or color_white
		slf:SetTextColor(Color(255,255,255,255))
	end
end

function ENPC:OpenJobPanel(job)
	if IsValid(base_menu["JobPanel"]) then base_menu["JobPanel"]:Remove() end

	local show_skin_menu

	base_menu["JobPanel"] = vgui.Create("DPanel", base_menu)
	base_menu["JobPanel"]:SetSize(580, base_menu:GetTall()-80)
	base_menu["JobPanel"]:SetPos(210, 70)
	base_menu["JobPanel"].Paint = function(slf, w, h)
		draw.RoundedBox(0, 0, 0, w, h, self.Colors.s_bg)
		draw.DrawText(job.name, "ENPC.Font21", w/2, 10, self:IsDarkColor(job.color), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		if istable(job.model) then
			draw.DrawText("- "..ENPC:Translate("model"), "ENPC.Font18", w/2 + 130, 118, Color( 200, 200, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		if show_skin_menu then
			draw.DrawText("- "..ENPC:Translate("skin"), "ENPC.Font18", w/2 + 130, 218, Color( 200, 200, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end

	local curModel = istable(job.model) and table.GetFirstValue(job.model) or job.model

	base_menu.icon = vgui.Create( "DModelPanel", base_menu["JobPanel"] )
	base_menu.icon:SetSize(base_menu["JobPanel"]:GetWide()/2+50, base_menu["JobPanel"]:GetWide()/2+50)
	base_menu.icon:SetPos(base_menu["JobPanel"]:GetWide()/5,0)
	base_menu.icon:SetModel( curModel )
	base_menu.icon.Angles = Angle(0,0,0)
	function base_menu.icon:DragMousePress()
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
	end
	function base_menu.icon:DragMouseRelease()
		self.Pressed = false
	end
	local rnd = math.random(1,4)
	function base_menu.icon:LayoutEntity( ent )
		if ( self.bAnimated ) then
			self:RunAnimation()
		end

		if ( self.Pressed ) then
			local mx, my = gui.MousePos()
			self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
			self.PressX, self.PressY = gui.MousePos()
		end

		ent:SetAngles( self.Angles )
		if ENPC.EnableRandomSequences then
			base_menu.icon.Entity:SetSequence(base_menu.icon.Entity:LookupSequence("pose_standing_0"..rnd))
		end
	end

	show_skin_menu = base_menu.icon.Entity:SkinCount() > 1

	if istable(job.model) and #job.model > 1 then
		base_menu["prevBtn"] = vgui.Create("DButton", base_menu["JobPanel"])
		base_menu["prevBtn"]:SetPos(150, 100)
		base_menu["prevBtn"]:SetSize(50, 50)
		base_menu["prevBtn"]:SetText("<")
		base_menu["prevBtn"]:SetTextColor(Color( 200, 200, 200 ))
		base_menu["prevBtn"]:SetFont("Trebuchet24")
		base_menu["prevBtn"].Paint = nil
		base_menu["prevBtn"].DoClick = function()
			local nextModel = table.FindPrev( job.model, curModel )
			base_menu.icon:SetModel( nextModel )
			curModel = nextModel

			show_skin_menu = base_menu.icon.Entity:SkinCount() > 1
			base_menu["prevBtn_s"]:SetVisible(show_skin_menu)
			base_menu["nextBtn_s"]:SetVisible(show_skin_menu)
		end

		base_menu["nextBtn"] = vgui.Create("DButton", base_menu["JobPanel"])
		base_menu["nextBtn"]:SetPos(base_menu["JobPanel"]:GetWide() - 50 -150, 100)
		base_menu["nextBtn"]:SetSize(50, 50)
		base_menu["nextBtn"]:SetText(">")
		base_menu["nextBtn"]:SetTextColor(Color( 200, 200, 200 ))
		base_menu["nextBtn"]:SetFont("Trebuchet24")
		base_menu["nextBtn"].Paint = nil
		base_menu["nextBtn"].DoClick = function()
			local nextModel = table.FindNext( job.model, curModel )
			base_menu.icon:SetModel( nextModel )
			curModel = nextModel


			show_skin_menu = base_menu.icon.Entity:SkinCount() > 1
			base_menu["prevBtn_s"]:SetVisible(show_skin_menu)
			base_menu["nextBtn_s"]:SetVisible(show_skin_menu)
		end
	end

	local cur_skin = 0

	base_menu["prevBtn_s"] = vgui.Create("DButton", base_menu["JobPanel"])
	base_menu["prevBtn_s"]:SetPos(150, 200)
	base_menu["prevBtn_s"]:SetSize(50, 50)
	base_menu["prevBtn_s"]:SetText("<")
	base_menu["prevBtn_s"]:SetTextColor(Color( 200, 200, 200 ))
	base_menu["prevBtn_s"]:SetFont("Trebuchet24")
	base_menu["prevBtn_s"]:SetVisible(show_skin_menu)
	base_menu["prevBtn_s"].Paint = nil
	base_menu["prevBtn_s"].DoClick = function()
		cur_skin = cur_skin - 1
		if cur_skin < 0 then
			cur_skin = base_menu.icon.Entity:SkinCount() -1
		end

		base_menu.icon.Entity:SetSkin( cur_skin )
	end

	base_menu["nextBtn_s"] = vgui.Create("DButton", base_menu["JobPanel"])
	base_menu["nextBtn_s"]:SetPos(base_menu["JobPanel"]:GetWide() - 50 -150, 200)
	base_menu["nextBtn_s"]:SetSize(50, 50)
	base_menu["nextBtn_s"]:SetText(">")
	base_menu["nextBtn_s"]:SetTextColor(Color( 200, 200, 200 ))
	base_menu["nextBtn_s"]:SetFont("Trebuchet24")
	base_menu["nextBtn_s"].Paint = nil
	base_menu["nextBtn_s"]:SetVisible(show_skin_menu)
	base_menu["nextBtn_s"].DoClick = function()
		cur_skin = cur_skin + 1
		if cur_skin < 0 then
			cur_skin = base_menu.icon.Entity:SkinCount() -1
		end

		base_menu.icon.Entity:SetSkin( cur_skin )
	end

	base_menu["descLabel"] = vgui.Create("DLabel", base_menu["JobPanel"])
	base_menu["descLabel"]:SetPos(40, base_menu["JobPanel"]:GetTall()/2+50)
	base_menu["descLabel"]:SetSize(base_menu["JobPanel"]:GetWide(), 100)
	base_menu["descLabel"]:SetText(job.description)
	base_menu["descLabel"]:SetFont("ENPC.Font16")
	base_menu["descLabel"]:SetAutoStretchVertical(true)
	base_menu["descLabel"]:SetWrap(true)
	base_menu["descLabel"]:SetTextColor(Color( 200, 200, 200 ))

	base_menu["selectBtn"] = vgui.Create("DButton", base_menu["JobPanel"])
	base_menu["selectBtn"]:SetPos(0, base_menu["JobPanel"]:GetTall()-40)
	base_menu["selectBtn"]:SetSize(base_menu["JobPanel"]:GetWide(), 40)
	base_menu["selectBtn"]:SetText("")
	base_menu["selectBtn"].DoClick = function(slf)
		if self:IsBlockedBy(LocalPlayer(), job) then return end
		if not self:IsAvailableJob(LocalPlayer(), job) then return end

		if not self:IsBoughtJob(LocalPlayer(), job) and self:IsJobNotRequired(LocalPlayer(), job) then
			net.Start("ENPC.BuyJob")
			net.WriteInt(job.team, 16)
			net.SendToServer()

			return
		end

		DarkRP.setPreferredJobModel(job.team, curModel)

		net.Start("ENPC.ChangeJobNPC")
		net.WriteInt(job.team, 16)
		net.WriteInt(base_menu.icon.Entity:GetSkin(), 16)
		net.SendToServer()

		base_menu:Remove()
	end
	base_menu["selectBtn"].Paint = function(slf, w, h)
		draw.RoundedBox(0, 0, 0, w, h, slf:IsHovered() and Color(52, 58, 64) or Color(0,0,0,100))

		local avail_color = slf:IsHovered() and color_white or Color(220,220,220,255)

		local can, message = self:IsAvailableJob(LocalPlayer(), job)
		if not can then
			draw.SimpleText( message, "ENPC.Font21", w/2, h/2+2, self.Colors.unavailable, 1, 1 )
		else
			local available, time, level = self:IsBlockedBy(LocalPlayer(), job)
			local bought, msg = self:IsBoughtJob(LocalPlayer(), job)
			local required_, msg1 = self:IsJobNotRequired(LocalPlayer(), job)

			if available then
				draw.SimpleText( self:Translate("Required").." "..available, "ENPC.Font21", w/2, h/2+2, self.Colors.unavailable, 1, 1 )
			elseif not required_ then
				draw.SimpleText( msg1, "ENPC.Font21", w/2, h/2+2, self.Colors.unavailable, 1, 1 )
			elseif not bought then
				draw.SimpleText( msg..": "..DarkRP.formatMoney(job.jobcost), "ENPC.Font21", w/2, h/2+2, avail_color, 1, 1 )
			else
				draw.SimpleText( self:Translate("Select"), "ENPC.Font21", w/2, h/2+2, avail_color, 1, 1 )
			end
		end
	end

end

function ENPC:OpenJobList(ent, whitelist)
	if IsValid(base) then base:Remove() end
	if IsValid(base_menu) then base_menu:Remove() end

	base_menu = vgui.Create("DFrame")
	base_menu:SetSize(800, 625)
	base_menu:Center()
	base_menu:MakePopup()
	base_menu:SetTitle("")
	base_menu:ShowCloseButton(false)
	base_menu.Paint = function(slf, w, h)
		self:DrawBlurredPanel(slf)
		draw.RoundedBox(0, 0, 0, w, h, self.Colors.bg)
		draw.RoundedBox(0, 0, 0, w, 60, self.Colors.s_bg)
		draw.RoundedBox(0, 0, 0, 200, 60, self.Colors.header)
		draw.SimpleText(ent:GetCustomName(), "ENPC.Font21", 100, 30, color_white, 1, 1)
	end

	base_menu["ExitBtn"] = vgui.Create("DButton", base_menu)
	base_menu["ExitBtn"]:SetPos(base_menu:GetWide() - 20 - 15, 30-10)
	base_menu["ExitBtn"]:SetSize(20, 20)
	base_menu["ExitBtn"]:SetText("")
	base_menu["ExitBtn"].DoClick = function()
		if base_menu then base_menu:Remove() end
	end
	base_menu["ExitBtn"].Paint = function(slf, w, h)
		self:DrawMaterial(close_mat, 0, 0, slf:IsHovered())
	end

	if LocalPlayer():IsSuperAdmin() then
		base_menu["SettingsBtn"] = vgui.Create("DButton", base_menu)
		base_menu["SettingsBtn"]:SetSize(20, 20)
		base_menu["SettingsBtn"]:SetPos(base_menu:GetWide() - 20 - 45, 30-10)
		base_menu["SettingsBtn"]:SetText("")
		base_menu["SettingsBtn"].Paint = function(slf, w, h)
			self:DrawMaterial(settings_mat, 0, 0, slf:IsHovered())
		end
		base_menu["SettingsBtn"].DoClick = function()
			self:OpenSettingsMenu(ent, whitelist)
		end
	end

	base_menu["ScrollPanel"] = vgui.Create("DScrollPanel", base_menu)
	base_menu["ScrollPanel"]:SetSize(200, base_menu:GetTall()-60)
	base_menu["ScrollPanel"]:SetPos(0, 60)
	base_menu["ScrollPanel"].Paint = function(slf, w, h)
		draw.RoundedBox(0, 0, 0, 200, h, self.Colors.s_bg)
	end

	base_menu["JobList"] = vgui.Create("DIconLayout", base_menu["ScrollPanel"])
	base_menu["JobList"]:SetSize( base_menu["ScrollPanel"]:GetWide(), base_menu["ScrollPanel"]:GetTall())
	base_menu["JobList"]:SetSpaceY( 0 )
	base_menu["JobList"]:SetSpaceX( 5 )

	local job_list = {}
	for k,v in pairs(RPExtraTeams) do
		if whitelist[v.name] then
			table.insert(job_list, v)
		end
	end

	for k,v in pairs(job_list) do
		base_menu["ColorJob"..k] = Color(97,97,97)
		base_menu["JobPanel"..k] = base_menu["JobList"]:Add("DPanel")
		base_menu["JobPanel"..k]:SetSize(base_menu["JobList"]:GetWide(), 45)
		base_menu["JobPanel"..k].last_w = 0
		base_menu["JobPanel"..k].Paint = function(slf, w, h)
			local iconsTbl = GetIconsTable(v)
			local offset = #iconsTbl > 0 and 10 or 2

			draw.RoundedBox(0, 0, 0, w, h-1, slf.is_hovered and Color(50,50,50,1) or Color(0,0,0,0))

			if slf.Selected then
				slf.last_w = Lerp(FrameTime()*10, slf.last_w, 5)
			else
				slf.last_w = Lerp(FrameTime()*10, slf.last_w, 0)
			end

			draw.RoundedBox(0, 0, 0, slf.last_w, h, self:IsDarkColor(v.color))

			if slf.Selected then
				draw.SimpleText(v.name, "ENPC.Font18", 15, h/2 - offset, self.Colors.f_list, 0, 1)

				local can, message = self:IsAvailableJob(LocalPlayer(), v)

				if not can then
					draw.SimpleText(message, "ENPC.Font16", 16, 21, self.Colors.f_list, 0, 0)
				else
					local available, time, level = self:IsBlockedBy(LocalPlayer(), v)
					local bought, msg = self:IsBoughtJob(LocalPlayer(), v)
					local required_, msg1 = self:IsJobNotRequired(LocalPlayer(), v)

					if available then
						draw.SimpleText(available, "ENPC.Font16", 16, 21, self.Colors.f_list, 0, 0)
					elseif not required_ then
						draw.SimpleText( msg1, "ENPC.Font16", 16, 21, self.Colors.f_list, 0, 0 )
					elseif not bought then
						draw.SimpleText(msg..": "..DarkRP.formatMoney(v.jobcost), "ENPC.Font16", 16, 21, self.Colors.f_list, 0, 0)
					end
				end
			else
				draw.SimpleText(v.name, "ENPC.Font18", 10, h/2 - offset, self.Colors.f_list, 0, 1)
			end

			surface.SetDrawColor(Color(0,0,0,75))
			surface.DrawLine(8, h-1, w-16, h-1)
		end

		base_menu["IconLayot"] = vgui.Create("DIconLayout", base_menu["JobPanel"..k])
		base_menu["IconLayot"]:SetSize( base_menu["JobPanel"..k]:GetWide()-20, base_menu["JobPanel"..k]:GetTall()-20)
		base_menu["IconLayot"]:SetPos( 10, 20 )
		base_menu["IconLayot"]:SetSpaceY( 0 )
		base_menu["IconLayot"]:SetSpaceX( 5 )

		for _,z in pairs(GetIconsTable(v)) do
			base_menu["Icon"] = base_menu["IconLayot"]:Add("DPanel")
			base_menu["Icon"]:SetSize(15, 15)
			base_menu["Icon"].Paint = function(slf, w, h)
				if not base_menu["JobPanel"..k].Selected then
					self:DrawMaterial(z, 0, 0, true)
				end
			end
		end

		base_menu["JobBtn"..k] = vgui.Create("DButton", base_menu["JobPanel"..k])
		base_menu["JobBtn"..k]:SetPos(0, 0)
		base_menu["JobBtn"..k]:SetSize(base_menu["JobPanel"..k]:GetWide(), base_menu["JobPanel"..k]:GetTall())
		base_menu["JobBtn"..k]:SetText("")
		base_menu["JobBtn"..k].Paint = function(slf, w, h)
			base_menu["JobPanel"..k].is_hovered = slf:IsHovered()
		end
		base_menu["JobBtn"..k].DoClick = function(slf)
			for _, but in pairs( base_menu["JobList"]:GetChildren() ) do
				but.Selected = false
			end
			base_menu["JobPanel"..k].Selected = true
			self:OpenJobPanel(v)
		end
	end

	if base_menu["JobBtn1"] then base_menu["JobBtn1"].DoClick() end
end

net.Receive("ENPC.OpenNPCInteractiveMenu", function()
	local ent = net.ReadEntity()
	local whitelist = net.ReadTable()

	ENPC:OpenJobList(ent, whitelist)
end)

net.Receive("ENPC.SyncJobs", function()
	local jobs = net.ReadTable()
	LocalPlayer().unlocked_jobs = jobs
end)

hook.Add( "Think", "ENPC.Think.Jobs", function()
	if not IsValid(LocalPlayer()) then return end

	net.Start("ENPC.PlayerIsLoaded")
	net.SendToServer()

	hook.Remove("Think", "ENPC.Think.Jobs")
end)
