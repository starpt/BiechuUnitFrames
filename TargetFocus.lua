local addonName = ...
local BC = _G[addonName]

-- 切换目标立即更新战斗状态边框红光
hooksecurefunc('TargetFrame_Update', function(self)
	if self.flash then self.flash:Hide() end
	BC:update(self.unit)
end)

-- 等级
hooksecurefunc('TargetFrame_UpdateLevelTextAnchor', function(self)
	if self.levelText then self.levelText:SetPoint('CENTER', 63, -16.5) end
end)

-- 更新Buff/Debuff
hooksecurefunc('TargetFrame_UpdateAuras', function(self)
	if self.unit == 'target' or self.unit == 'focus' then
		BC:aura(self.unit)
	end
end)

for unit, frame in pairs({
	target = TargetFrame,
	focus = FocusFrame,
}) do

	-- 名字
	frame.name:SetWidth(120)
	frame.name:SetPoint('CENTER', -50, 17.5)

	frame.flash = _G[frame:GetName() .. 'Flash'] -- 战斗中边框发红光
	frame.statusBar = frame.nameBackground -- 状态栏

	-- 体力
	frame.healthbar.MiddleText = frame.textureFrame.HealthBarText
	frame.healthbar.MiddleText:SetPoint('CENTER', frame.healthbar, 'CENTER', 0, -.5)
	frame.healthbar.LeftText:SetPoint('LEFT', frame.healthbar, 'LEFT', 1, -.5)
	frame.healthbar.RightText:SetPoint('RIGHT', frame.healthbar, 'RIGHT', -3, -.5)
	frame.healthbar.SideText = frame.healthbar:CreateFontString()
	frame.healthbar.SideText:SetPoint('RIGHT', frame.healthbar, 'LEFT', -3, -.5)

	-- 法力
	frame.manabar.MiddleText = frame.textureFrame.ManaBarText
	frame.manabar.MiddleText:SetPoint('CENTER', frame.manabar, 'CENTER', 0, -.5)
	frame.manabar.LeftText:SetPoint('LEFT', frame.manabar, 'LEFT', 1, -.5)
	frame.manabar.RightText:SetPoint('RIGHT', frame.manabar, 'RIGHT', -3, -.5)
	frame.manabar.SideText = frame.manabar:CreateFontString()
	frame.manabar.SideText:SetPoint('RIGHT', frame.manabar, 'LEFT', -3, -.5)

	-- 威胁
	frame.threatNumericIndicator.border = frame.threatNumericIndicator:CreateTexture()
	frame.threatNumericIndicator.border:SetAllPoints(frame.threatNumericIndicator)
	frame.threatNumericIndicator.border:SetTexCoord(0, .77, 0, .55)
	frame.threatNumericIndicator.text:ClearAllPoints()
	frame.threatNumericIndicator.text:SetPoint('CENTER', 0, -2)

	frame.init = function()
		local font = BC:getDB('global', 'valueFont')
		frame.levelText:SetFont(font, 13, 'OUTLINE') -- 等级
		BC:aura(frame.unit)

		-- 威胁
		frame.threatNumericIndicator.text:SetFont(font, 13, 'OUTLINE')
		frame.threatNumericIndicator.bg:SetTexture(BC:file(BC.barList[1]))
		frame.threatNumericIndicator.border:SetTexture(BC:file('TargetingFrame\\NumericThreatBorder'))
		if BC:getDB(frame.unit, 'threatLeft') then
			frame.threatNumericIndicator:SetPoint('TOP', -84, -4)
		else
			frame.threatNumericIndicator:SetPoint('TOP', -50, -4)
		end
	end

	-- 目标的目标
	local totFrame = _G[frame:GetName() .. 'ToT']
	totFrame.borderTexture = _G[totFrame:GetName() .. 'TextureFrameTexture']

	-- 体力
	totFrame.healthbar.MiddleText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.healthbar.MiddleText:SetPoint('CENTER', totFrame.healthbar, 'CENTER')
	totFrame.healthbar.SideText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.healthbar.SideText:SetPoint('LEFT', totFrame.healthbar, 'RIGHT', 2, 0)

	-- 法力
	totFrame.manabar.MiddleText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.manabar.MiddleText:SetPoint('CENTER', totFrame.manabar, 'CENTER', 0, -.5)
	totFrame.manabar.SideText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.manabar.SideText:SetPoint('LEFT', totFrame.manabar, 'RIGHT', 2, -.5)

	BC[unit] = frame
	BC[unit .. 'target'] = totFrame
end