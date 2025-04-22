local BC = _G[...]

-- 更新Buff/Debuff
hooksecurefunc('TargetFrame_UpdateAuras', function(self)
	BC:aura(self.unit)
end)

-- 切换目标立即更新战斗状态边框红光
hooksecurefunc('TargetFrame_Update', function(self)
	if self.flash then self.flash:Hide() end
	if self.unit == 'target' or self.unit == 'focus' then
		BC:update(self.unit)
		BC:update(self.unit .. 'target')
		BC:miniIcon(self.unit)
	end
end)

for unit, frame in pairs({
	target = TargetFrame,
}) do

	-- 名字
	frame.name:SetWidth(120)
	frame.name:SetPoint('CENTER', -50, 17.5)

	-- 施法条
	frame.castBar = _G[frame:GetName() .. 'SpellBar']
	hooksecurefunc(frame.castBar, 'Show', function(self)
		if self.offsetY then self:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 26, self.offsetY) end
	end)

	frame.flash = _G[frame:GetName() .. 'Flash'] -- 战斗中边框发红光
	frame.statusBar = frame.nameBackground -- 状态栏
	frame.levelText:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE') -- 等级
	frame.deadText:SetPoint('CENTER', frame.healthbar, 0, -4) -- 死亡

	-- 体力
	frame.healthbar.MiddleText = frame.textureFrame:CreateFontString()
	frame.healthbar.MiddleText:SetPoint('CENTER', frame.healthbar, 0, -.5)
	frame.healthbar.LeftText = frame.textureFrame:CreateFontString()
	frame.healthbar.LeftText:SetPoint('LEFT', frame.healthbar, 1, -.5)
	frame.healthbar.RightText = frame.textureFrame:CreateFontString()
	frame.healthbar.RightText:SetPoint('RIGHT', frame.healthbar, -3, -.5)
	frame.healthbar.SideText = frame.textureFrame:CreateFontString()
	frame.healthbar.SideText:SetPoint('RIGHT', frame.healthbar, 'LEFT', -3, -.5)

	-- 法力
	frame.manabar.MiddleText = frame.textureFrame:CreateFontString()
	frame.manabar.MiddleText:SetPoint('CENTER', frame.manabar, 0, -.5)
	frame.manabar.LeftText = frame.textureFrame:CreateFontString()
	frame.manabar.LeftText:SetPoint('LEFT', frame.manabar, 1, -.5)
	frame.manabar.RightText = frame.textureFrame:CreateFontString()
	frame.manabar.RightText:SetPoint('RIGHT', frame.manabar, -3, -.5)
	frame.manabar.SideText = frame.textureFrame:CreateFontString()
	frame.manabar.SideText:SetPoint('RIGHT', frame.manabar, 'LEFT', -3, -.5)

	-- 威胁值
	frame.threatNumericIndicator = CreateFrame('Frame', nil, frame)
	frame.threatNumericIndicator:SetSize(49, 18)
	frame.threatNumericIndicator:SetPoint('TOP', -84, -4.5)
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

	frame.init = function()
		BC:aura(unit) -- 更新Buff/Debuff
		BC:miniIcon(unit) -- 更新小图标

		-- Quartz 施法条
		local QuartzCastBar = _G['Quartz3CastBar' .. unit:gsub('^%l', string.upper)]
		if QuartzCastBar then
			hooksecurefunc(QuartzCastBar, 'Show', function(self)
				if frame.castBar.offsetY then
					self:ClearAllPoints()
					self:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 1, frame.castBar.offsetY + 7)
				end
			end)
		end

		-- 威胁值
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

	-- 法力
	totFrame.manabar.MiddleText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.manabar.MiddleText:SetPoint('CENTER', totFrame.manabar, 0, -.5)
	totFrame.manabar.SideText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.manabar.SideText:SetPoint('LEFT', totFrame.manabar, 'RIGHT', 2, -.5)

	-- 死亡
	totFrame.deadText:ClearAllPoints()
	totFrame.deadText:SetPoint('CENTER', totFrame.healthbar, .5, -4)

	BC[unit] = frame
	BC[unit .. 'target'] = totFrame
end
