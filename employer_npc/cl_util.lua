function ENPC:IsDarkColor(color)
	local val = ((color.r*299)+(color.g*587)+(color.b*114))/1000
	if val < 75 then
		return {r = color.r+75, g = color.g+75, b = color.b+75, a = color.a}
	else
		return color
	end
end

function ENPC:DrawMaterial(mat, x, y, activated)
	local color = activated and ENPC.Colors.icons_a or ENPC.Colors.icons

	surface.SetMaterial(mat)
	surface.SetDrawColor(color)
	surface.DrawTexturedRect(x, y, 15, 15)
end

local blur = Material("pp/blurscreen")

function ENPC:DrawBlur(panel)
	local w, h = panel:GetWide(), panel:GetTall()

	render.ClearStencil()
	render.SetStencilEnable( true )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilTestMask( 1 )
	render.SetStencilWriteMask( 1 )

	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
	render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( 0, 0, w, h )

	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

		surface.SetMaterial( blur )
		surface.SetDrawColor( 255, 255, 255, 255 )

		for i = 0, 1, 0.33 do
			blur:SetFloat( '$blur', 5 *i )
			blur:Recompute()
			render.UpdateScreenEffectTexture()

			local x, y = panel:GetPos()

			surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
		end

	render.SetStencilEnable( false )
end

function ENPC:DrawBlurredPanel(panel)
	if ENPC.EnableBlur then
		ENPC.Colors.bg.a = 220
		ENPC.Colors.s_bg.a = 220
		ENPC.Colors.header.a = 220
		self:DrawBlur(panel)
	end
end
