local BC = _G[...]

for unit, frame in pairs({
	target = TargetFrame,
	focus = FocusFrame,
}) do
	-- 更新Buff/Debuff
	hooksecurefunc(frame, 'UpdateAuras', function(self)
		BC:aura(self.unit)
	end)

	-- 切换目标立即更新战斗状态边框红光
	hooksecurefunc(frame, 'Update', function(self)
		BC:update(self.unit)
		BC:update(self.unit .. 'target')
		BC:miniIcon(self.unit)
		if not BC.isClassic then
			frame.flash:SetTexCoord(0, 0.9453125, 0, 0.75)
			frame.flash:SetPoint('TOPLEFT', -6, -5)
		end
	end)

	-- 名字
	frame.name:SetWidth(120)
	frame.name:SetPoint('CENTER', -34, 14.5)

	-- 施法条
	frame.spellbar.Border:SetDrawLayer('OVERLAY')
	frame.spellbar.Icon:SetPoint('LEFT', -22, 0)
	frame.spellbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	frame.spellbar.IconBorder = frame.spellbar:CreateTexture(nil, 'BORDER')
	frame.spellbar.IconBorder:SetPoint('CENTER', frame.spellbar.Icon)
	frame.spellbar.IconBorder:SetSize(frame.spellbar.Icon:GetWidth() + 2, frame.spellbar.Icon:GetHeight() + 2)
	frame.spellbar.IconBorder:SetTexture(BC.texture .. 'Border')
	frame.spellbar.Text:SetDrawLayer('OVERLAY')
	frame.spellbar.Text:SetFont(STANDARD_TEXT_FONT, 13)
	frame.spellbar.Text:ClearAllPoints()
	frame.spellbar.Text:SetPoint('CENTER')
	frame.spellbar.Spark:SetSize(24, 24)
	frame.casting = function(self, offsetY)
		local offsetY = offsetY or self.yOffset or 0
		self.yOffset = offsetY
		self:SetScale(0.88)
		self:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 48, (offsetY - 4) / 0.88)
	end

	frame.flash = _G[frame:GetName() .. 'Flash'] -- 战斗中边框发红光
	frame.statusBar = frame.nameBackground -- 状态栏
	frame.statusBar:SetWidth(118)
	frame.Background:SetPoint('BOTTOMLEFT', 24, 30) -- 背景
	frame.deadText:SetPoint('CENTER', frame.healthbar, 0, -4) -- 死亡

	-- 等级
	frame.levelText:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE')
	frame.levelText:SetPoint('CENTER', 80, -19.5)

	-- 体力
	frame.healthbar.MiddleText = frame.textureFrame.HealthBarText
	frame.healthbar.MiddleText:SetPoint('CENTER', frame.healthbar, 0, -0.5)
	frame.healthbar.LeftText:SetPoint('LEFT', frame.healthbar, 1, -0.5)
	frame.healthbar.RightText:SetPoint('RIGHT', frame.healthbar, -3, -0.5)
	frame.healthbar.SideText = frame.healthbar:CreateFontString()
	frame.healthbar.SideText:SetPoint('RIGHT', frame.healthbar, 'LEFT', -3, -0.5)

	-- 法力
	frame.manabar.MiddleText = frame.textureFrame.ManaBarText
	frame.manabar.MiddleText:SetPoint('CENTER', frame.manabar, 0, -0.5)
	frame.manabar.LeftText:SetPoint('LEFT', frame.manabar, 1, -0.5)
	frame.manabar.RightText:SetPoint('RIGHT', frame.manabar, -3, -0.5)
	frame.manabar.SideText = frame.manabar:CreateFontString()
	frame.manabar.SideText:SetPoint('RIGHT', frame.manabar, 'LEFT', -3, -0.5)

	-- 威胁值
	frame.threatNumericIndicator:ClearAllPoints()
	frame.threatNumericIndicator:SetPoint('TOP', -64, -8)
	frame.threatNumericIndicator.border = frame.threatNumericIndicator:CreateTexture(nil, 'OVERLAY')
	frame.threatNumericIndicator.border:SetAllPoints(frame.threatNumericIndicator)
	frame.threatNumericIndicator.border:SetTexCoord(0, 0.77, 0, 0.55)
	frame.threatNumericIndicator.text:SetPoint('TOP', 0, -4.5)
	frame.threatNumericIndicator.text:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')

	frame.init = function()
		BC:aura(unit) -- 更新Buff/Debuff
		BC:miniIcon(unit) -- 更新小图标

		-- 威胁值
		frame.threatNumericIndicator.bg:SetTexture(BC:file(BC.barList[1]))
		frame.threatNumericIndicator.border:SetTexture(BC:file('TargetingFrame\\NumericThreatBorder'))

		-- 施法条
		frame.spellbar:SetStatusBarTexture(BC:file(BC.barList[1]))
		frame.spellbar.Border:SetTexture(BC:file(BC.barList[3]))
		frame.spellbar.BorderShield:SetTexture(BC:file(BC.barList[4]))
		if BC:getDB('global', 'dark') then
			frame.spellbar.IconBorder:SetVertexColor(0.1, 0.1, 0.1)
		else
			frame.spellbar.IconBorder:SetVertexColor(0.2, 0.2, 0.2)
		end
		frame.casting(frame.spellbar)
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

	if unit == 'focus' then
		hooksecurefunc(frame, 'SetSmallSize', function(self)
			BC:init(unit)
			self.healthbar.MiddleText:SetPoint('CENTER', frame.healthbar, 0, -0.5)
			totFrame:SetScale(1)
			BC:aura(unit)
		end)
	end

	-- 施法条位置
	hooksecurefunc(frame.spellbar, 'AdjustPosition', function(self)
		frame.casting(self)
	end)
	frame.spellbar:HookScript('OnEvent', function(self)
		frame.casting(self)
	end)

	BC[unit] = frame
	BC[unit .. 'target'] = totFrame
end
