local BC = _G[...]

-- 更新Buff/Debuff
hooksecurefunc('TargetFrame_UpdateAuras', function(self)
	BC:aura(self.unit)
end)

-- 切换目标立即更新战斗状态边框红光
hooksecurefunc('TargetFrame_Update', function(self)
	if self.unit ~= 'target' and self.unit ~= 'focus' then return end
	if self.flash then self.flash:Hide() end
	BC:update(self.unit)
	BC:update(self.unit .. 'target')
	BC:miniIcon(self.unit)
end)

for unit, frame in pairs({
	target = TargetFrame,
	focus = FocusFrame,
}) do
	-- 名字
	frame.name:SetWidth(120)
	frame.name:SetPoint('CENTER', -50, 18)

	-- 施法条
	frame.castBar = _G[frame:GetName() .. 'SpellBar']
	hooksecurefunc(frame.castBar, 'Show', function(self)
		if self.offsetY then self:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 26, self.offsetY) end
	end)

	frame.flash = _G[frame:GetName() .. 'Flash'] -- 战斗中边框发红光
	frame.statusBar = frame.nameBackground -- 状态栏
	frame.deadText:SetPoint('CENTER', frame.healthbar, 0, -4) -- 死亡
	frame.levelText:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE') -- 等级
	frame.pvpTime = _G[frame:GetName() .. 'pvpTime']

	-- 体力
	frame.healthbar.MiddleText = _G[frame:GetName() .. 'TextureFrameHealthBarText']
	local parent = frame.healthbar.MiddleText:GetParent()
	frame.healthbar.LeftText = parent:CreateFontString()
	frame.healthbar.LeftText:SetPoint('LEFT', frame.healthbar, 1, 0)
	frame.healthbar.RightText = parent:CreateFontString()
	frame.healthbar.RightText:SetPoint('RIGHT', frame.healthbar, -3, 0)
	frame.healthbar.SideText = parent:CreateFontString()
	frame.healthbar.SideText:SetPoint('RIGHT', frame.healthbar, 'LEFT', -3, 0)

	-- 法力
	frame.manabar.MiddleText = _G[frame:GetName() .. 'TextureFrameManaBarText']
	parent = frame.manabar.MiddleText:GetParent()
	frame.manabar.LeftText = parent:CreateFontString()
	frame.manabar.LeftText:SetPoint('LEFT', frame.manabar, 1, 0)
	frame.manabar.RightText = parent:CreateFontString()
	frame.manabar.RightText:SetPoint('RIGHT', frame.manabar, -3, 0)
	frame.manabar.SideText = parent:CreateFontString()
	frame.manabar.SideText:SetPoint('RIGHT', frame.manabar, 'LEFT', -3, 0)

	-- 威胁值
	frame.threatNumericIndicator.border = frame.threatNumericIndicator:CreateTexture(nil, 'OVERLAY')
	frame.threatNumericIndicator.border:SetAllPoints(frame.threatNumericIndicator)
	frame.threatNumericIndicator.border:SetTexCoord(0, 0.77, 0, 0.55)
	frame.threatNumericIndicator.text:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')

	frame.init = function()
		BC:aura(unit) -- 更新Buff/Debuff
		BC:miniIcon(unit) -- 更新小图标

		-- Quartz 施法条
		local QuartzCastBar = _G['Quartz3CastBar' .. unit:gsub('^%l', string.upper)]
		if QuartzCastBar then hooksecurefunc(QuartzCastBar, 'Show', function(self)
			if frame.castBar.offsetY then
				self:ClearAllPoints()
				self:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 15, frame.castBar.offsetY + 6)
			end
		end) end

		-- 威胁值
		frame.threatNumericIndicator.bg:SetTexture(BC:file(BC.barList[1]))
		frame.threatNumericIndicator.border:SetTexture(BC:file('TargetingFrame\\NumericThreatBorder'))
		frame.threatNumericIndicator:SetPoint('TOP', BC:getDB(unit, 'threatLeft') and -84 or -50, -5)
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
	totFrame.deadText:SetPoint('CENTER', totFrame.healthbar, 0.5, -4)

	-- 法力
	totFrame.manabar.MiddleText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.manabar.MiddleText:SetPoint('CENTER', totFrame.manabar, 0, -0.5)
	totFrame.manabar.SideText = totFrame.borderTexture:GetParent():CreateFontString()
	totFrame.manabar.SideText:SetPoint('LEFT', totFrame.manabar, 'RIGHT', 2, -0.5)

	BC[unit] = frame
	BC[unit .. 'target'] = totFrame
end
