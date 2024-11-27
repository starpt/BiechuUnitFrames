local addonName = ...
local BC = _G[addonName]

-- 更新Buff/Debuff
hooksecurefunc('TargetFrame_UpdateAuras', function(self)
	if self.unit == 'target' then
		BC:aura(self.unit) -- 更新Buff/Debuff
	end
end)

-- 切换目标立即更新战斗状态边框红光
hooksecurefunc('TargetFrame_Update', function(self)
	if self.unit ~= 'target' then return end
	if self.flash then self.flash:Hide() end
	BC:update(self.unit)
	BC:update(self.unit .. 'target')
end)

-- 等级
hooksecurefunc('TargetFrame_UpdateLevelTextAnchor', function(self)
	if self.levelText then self.levelText:SetPoint('CENTER', 62.5, -16) end
end)

for unit, frame in pairs({
	target = TargetFrame,
}) do

	-- 名字
	frame.name:SetWidth(120)
	frame.name:SetPoint('CENTER', -50, 17.5)

	-- 战斗中边框发红光
	frame.flash = _G[frame:GetName() .. 'Flash']
	if not frame.flash then
		frame.flash = frame:CreateTexture()
		frame.flash.unit = unit
		frame.flash:SetPoint('TOPLEFT', frame, -24, 0)
		frame.flash:SetSize(242, 93)
		frame.flash:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-Flash')
		frame.flash:SetTexCoord(0, 0.9453125, 0, 0.181640625)
	end
	hooksecurefunc(frame.flash, 'Hide', function(self)
		if BC:getDB(self.unit, 'combatFlash') and UnitAffectingCombat(self.unit) then
			self:SetVertexColor(1, 0, 0)
			self:SetAlpha(.7)
			if not self:IsVisible() then self:Show() end
		else
			self:SetAlpha(0)
		end
	end)

	-- 施法条
	frame.castBar = _G[frame:GetName() .. 'SpellBar']
	hooksecurefunc(frame.castBar, 'Show', function(self)
		if self.offsetY then
			self:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 25.5, self.offsetY)
		end
	end)

	frame.statusBar = frame.nameBackground -- 状态栏
	frame.levelText:SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE') -- 等级

	-- 体力
	frame.healthbar.MiddleText = frame.textureFrame:CreateFontString()
	frame.healthbar.MiddleText:SetPoint('CENTER', frame.healthbar, 0, -.5)
	frame.healthbar.LeftText = frame.textureFrame:CreateFontString()
	frame.healthbar.LeftText:SetPoint('LEFT', frame.healthbar, 1, -.5)
	frame.healthbar.RightText = frame.textureFrame:CreateFontString()
	frame.healthbar.RightText:SetPoint('RIGHT', frame.healthbar, -3, -.5)
	frame.healthbar.SideText = frame.textureFrame:CreateFontString()
	frame.healthbar.SideText:SetPoint('RIGHT', frame.healthbar, 'LEFT', -3, -.5)

	-- 死亡
	frame.deadText:SetPoint('CENTER', frame.healthbar, 0, -4)

	-- 法力
	frame.manabar.MiddleText = frame.textureFrame:CreateFontString()
	frame.manabar.MiddleText:SetPoint('CENTER', frame.manabar, 0, -.5)
	frame.manabar.LeftText = frame.textureFrame:CreateFontString()
	frame.manabar.LeftText:SetPoint('LEFT', frame.manabar, 1, -.5)
	frame.manabar.RightText = frame.textureFrame:CreateFontString()
	frame.manabar.RightText:SetPoint('RIGHT', frame.manabar, -3, -.5)
	frame.manabar.SideText = frame.textureFrame:CreateFontString()
	frame.manabar.SideText:SetPoint('RIGHT', frame.manabar, 'LEFT', -3, -.5)

	-- 威胁
	if not frame.threatNumericIndicator then
		frame.threatNumericIndicator = CreateFrame('Frame', nil, frame)
		frame.threatNumericIndicator:SetSize(49, 18)
		frame.threatNumericIndicator:SetPoint('TOP', -84, -5)
		frame.threatNumericIndicator:Hide()
		frame.threatNumericIndicator.bg = frame.threatNumericIndicator:CreateTexture(nil, 'BACKGROUND')
		frame.threatNumericIndicator.bg:SetSize(37, 14)
		frame.threatNumericIndicator.bg:SetPoint('TOP', 0, -3)
		frame.threatNumericIndicator.border = frame.threatNumericIndicator:CreateTexture(nil, 'BORDER')
		frame.threatNumericIndicator.border:SetAllPoints(frame.threatNumericIndicator)
		frame.threatNumericIndicator.border:SetTexCoord(0, .77, 0, .55)
		frame.threatNumericIndicator.text = frame.threatNumericIndicator:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
		frame.threatNumericIndicator.text:SetPoint('CENTER', 0, -1)
		frame.threatNumericIndicator.text:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
	end

	frame.init = function()
		BC:aura(frame.unit) -- 更新Buff/Debuff

		-- 威胁
		frame.threatNumericIndicator.bg:SetTexture(BC:file(BC.barList[1]))
		frame.threatNumericIndicator.border:SetTexture(BC:file('TargetingFrame\\NumericThreatBorder'))
	end

	-- 目标的目标
	local totFrame = _G[frame:GetName() .. 'ToT']
	totFrame.borderTexture = _G[totFrame:GetName() .. 'TextureFrameTexture']

	-- 体力
	totFrame.healthbar.MiddleText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.healthbar.MiddleText:SetPoint('CENTER', totFrame.healthbar)
	totFrame.healthbar.SideText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.healthbar.SideText:SetPoint('LEFT', totFrame.healthbar, 'RIGHT', 2, 0)

	-- 死亡
	totFrame.deadText:ClearAllPoints()
	totFrame.deadText:SetPoint('CENTER', totFrame.healthbar, .5, -4)

	-- 法力
	totFrame.manabar.MiddleText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.manabar.MiddleText:SetPoint('CENTER', totFrame.manabar, 0, -.5)
	totFrame.manabar.SideText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.manabar.SideText:SetPoint('LEFT', totFrame.manabar, 'RIGHT', 2, -.5)

	BC[unit] = frame
	BC[unit .. 'target'] = totFrame
end
