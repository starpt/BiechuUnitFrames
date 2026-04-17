local BC = _G[...]
local frame = CreateFrame('Frame')

-- 等级
function frame:level(party)
	if not party or not party.levelText then return end
	local level = UnitLevel(party.unit)
	if BC:getDB('party', 'showLevel') and level > 0 then
		party.levelText:SetText(level)
		party.levelText:Show()
	else
		party.levelText:Hide()
	end
end

for id = 1, MAX_PARTY_MEMBERS do
	-- 队友
	local party = 'party' .. id
	BC[party] = PartyFrame['MemberFrame' .. id]
	BC[party].borderTexture = BC[party].PartyMemberOverlay.Texture -- 边框
	BC[party].pvpIcon = BC[party].PartyMemberOverlay.PVPIcon      -- PVP状态图标
	BC[party].flash = BC[party].Flash                             -- 战斗中边框发红光

	-- 等级文字
	BC[party].levelText = BC[party]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
	BC[party].levelText:SetPoint('BOTTOM', BC[party], 'BOTTOMLEFT', 6, 3)
	BC[party].levelText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')

	local parent = CreateFrame('Frame', nil, BC[party])
	parent:SetFrameLevel(4)

	-- 体力
	BC[party].healthbar.MiddleText = parent:CreateFontString()
	BC[party].healthbar.MiddleText:SetPoint('CENTER', BC[party].healthbar, 0, -.5)
	BC[party].healthbar.LeftText = parent:CreateFontString()
	BC[party].healthbar.LeftText:SetPoint('LEFT', BC[party].healthbar, 0, -.5)
	BC[party].healthbar.RightText = parent:CreateFontString()
	BC[party].healthbar.RightText:SetPoint('RIGHT', BC[party].healthbar, -1, -.5)
	BC[party].healthbar.SideText = parent:CreateFontString()
	BC[party].healthbar.SideText:SetPoint('LEFT', BC[party].healthbar, 'RIGHT', 2, -.5)

	-- 法力
	BC[party].manabar.MiddleText = parent:CreateFontString()
	BC[party].manabar.MiddleText:SetPoint('CENTER', BC[party].manabar)
	BC[party].manabar.LeftText = parent:CreateFontString()
	BC[party].manabar.LeftText:SetPoint('LEFT', BC[party].manabar)
	BC[party].manabar.RightText = parent:CreateFontString()
	BC[party].manabar.RightText:SetPoint('RIGHT', BC[party].manabar, -1, 0)
	BC[party].manabar.SideText = parent:CreateFontString()
	BC[party].manabar.SideText:SetPoint('LEFT', BC[party].manabar, 'RIGHT', 2, 0)

	-- 施法条
	BC[party].spellbar = CreateFrame('StatusBar', 'PartyFrame' .. id .. 'SpellBar', BC[party], 'CastingBarFrameTemplate')
	BC[party].spellbar:SetSize(94, 6)
	BC[party].spellbar.Border:SetDrawLayer('OVERLAY')
	BC[party].spellbar.Border:ClearAllPoints()
	BC[party].spellbar.Border:SetPoint('CENTER')
	BC[party].spellbar.Border:SetSize(126, 28)
	BC[party].spellbar.Border:SetAlpha(.8)
	BC[party].spellbar.Icon:ClearAllPoints()
	BC[party].spellbar.Icon:SetPoint('LEFT', -10.5, 0)
	BC[party].spellbar.Icon:SetSize(8, 8)
	BC[party].spellbar.Icon:SetTexCoord(.05, .95, .05, .95)
	BC[party].spellbar.Text:SetDrawLayer('OVERLAY')
	BC[party].spellbar.Text:SetFont(STANDARD_TEXT_FONT, 8)
	BC[party].spellbar.Text:ClearAllPoints()
	BC[party].spellbar.Text:SetPoint('CENTER')
	BC[party].spellbar.Spark:SetSize(24, 24)
	BC[party].spellbar:Hide()
	BC[party].spellbar:SetPoint('BOTTOMLEFT', 18, -13)

	-- 禁止施法完成后动画
	hooksecurefunc(BC[party].spellbar, 'FinishSpell', function(self)
		self.flash = nil
	end)
	hooksecurefunc(BC[party].spellbar, 'SetValue', function(self)
		self.Flash:Hide()
	end)

	-- 队友的宠物
	local partypet = party .. 'pet'
	BC[partypet] = BC[party].PetFrame
	BC[partypet].borderTexture = BC[partypet].Texture -- 边框

	-- 名字
	BC[partypet].name:ClearAllPoints()
	BC[partypet].name:SetPoint('TOPLEFT', 24, -15)

	parent = CreateFrame('Frame', nil, BC[partypet])
	parent:SetFrameLevel(5)

	-- 体力
	BC[partypet].healthbar:SetFrameLevel(1)
	BC[partypet].healthbar.MiddleText = parent:CreateFontString()
	BC[partypet].healthbar.MiddleText:SetPoint('CENTER', BC[partypet].healthbar, 0, .5)
	BC[partypet].healthbar.SideText = parent:CreateFontString()
	BC[partypet].healthbar.SideText:SetPoint('LEFT', BC[partypet].healthbar, 'RIGHT', 2, .5)

	-- 法力
	BC[partypet].manabar = CreateFrame('StatusBar', nil, BC[partypet], 'TextStatusBar')
	BC[partypet].manabar:SetFrameLevel(1)
	BC[partypet].manabar:SetSize(35, 4)
	BC[partypet].manabar:SetPoint('TOPLEFT', 23, -10)
	BC[partypet].manabar.unit = partypet
	BC[partypet].manabar.MiddleText = parent:CreateFontString()
	BC[partypet].manabar.MiddleText:SetPoint('CENTER', BC[partypet].manabar, 0, -1)
	BC[partypet].manabar.SideText = parent:CreateFontString()
	BC[partypet].manabar.SideText:SetPoint('LEFT', BC[partypet].manabar, 'RIGHT', 2, -1)

	-- 队友的目标
	local partytarget = party .. 'target'
	BC[partytarget] = CreateFrame('Button', 'Party' .. id .. 'TargetFrame', UIParent, 'SecureUnitButtonTemplate')
	BC[partytarget]:SetSize(100, 45)
	BC[partytarget]:SetFrameLevel(3)
	BC[partytarget].unit = partytarget

	-- 边框
	BC[partytarget].borderTexture = BC[partytarget]:CreateTexture()
	BC[partytarget].borderTexture:SetTexCoord(1, 0, 1, 1, 0, 0, 0, 1) -- 水平反转
	BC[partytarget].borderTexture:SetPoint('TOP')

	-- 名字
	BC[partytarget].name = BC[partytarget]:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	BC[partytarget].name:SetPoint('BOTTOMRIGHT', -32, 33)

	-- 头像
	BC[partytarget].portrait = BC[partytarget]:CreateTexture(nil, 'BORDER')
	BC[partytarget].portrait:SetSize(37, 37)
	BC[partytarget].portrait:SetPoint('RIGHT', 9, -1)

	-- 体力
	BC[partytarget].healthbar = CreateFrame('StatusBar', nil, BC[partytarget], 'TextStatusBar')
	BC[partytarget].healthbar:SetSize(46, 7)
	BC[partytarget].healthbar:SetPoint('TOPLEFT', 24, -14)
	BC[partytarget].healthbar:SetFrameLevel(1)
	BC[partytarget].healthbar.unit = partytarget

	BC[partytarget].healthbar.MiddleText = BC[partytarget]:CreateFontString()
	BC[partytarget].healthbar.MiddleText:SetPoint('CENTER', BC[partytarget].healthbar, 0, -1)
	BC[partytarget].healthbar.SideText = BC[partytarget]:CreateFontString()
	BC[partytarget].healthbar.SideText:SetPoint('RIGHT', BC[partytarget].healthbar, 'LEFT', -3, -1)

	-- 法力
	BC[partytarget].manabar = CreateFrame('StatusBar', nil, BC[partytarget], 'TextStatusBar')
	BC[partytarget].manabar:SetSize(46, 7)
	BC[partytarget].manabar:SetPoint('TOPLEFT', 24, -23)
	BC[partytarget].manabar:SetFrameLevel(1)
	BC[partytarget].manabar.unit = partytarget

	BC[partytarget].manabar.MiddleText = BC[partytarget]:CreateFontString()
	BC[partytarget].manabar.MiddleText:SetPoint('CENTER', BC[partytarget].manabar, 0, -.5)
	BC[partytarget].manabar.SideText = BC[partytarget]:CreateFontString()
	BC[partytarget].manabar.SideText:SetPoint('RIGHT', BC[partytarget].manabar, 'LEFT', -3, -.5)

	-- 鼠标提示
	BC[partytarget]:SetScript('OnEnter', function(self)
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetUnit(self.unit)
		GameTooltip:Show()
	end)
	BC[partytarget]:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
	end)
	SecureUnitButton_OnLoad(BC[partytarget], partytarget) -- 点击选择

	BC[party].init = function()
		frame:level(BC[party]) -- 等级
		BC:aura(party)       -- Buff/Debuff

		-- 显示施法条
		if BC:getDB('party', 'showCastBar') then
			BC[party].spellbar:SetStatusBarTexture(BC:file(BC.barList[1]))
			BC[party].spellbar.Border:SetTexture(BC:file(BC.barList[3]))
			BC[party].spellbar.BorderShield:SetTexture(BC:file(BC.barList[4]))
			BC[party].spellbar:SetUnit(party, false, true) -- unit, showTradeSkills, showShield
		else
			BC[party].spellbar:SetUnit(nil)
		end
		-- 定位
		if id > 1 and not InCombatLockdown() then
			local offsetY = ceil((MAX_TARGET_BUFFS + MAX_TARGET_DEBUFFS) / BC:getDB('party', 'auraRows')) * (BC:getDB('party', 'auraSize') + 2)
			BC[party]:SetPoint('TOPLEFT', BC['party' .. id - 1], 0, -42 - offsetY - (showCastBar and 18 or 0))
		end
	end
end

for _, event in pairs({
	'UNIT_AURA',         -- Buff/Debuff变化
	'UNIT_LEVEL',        -- 升级
	'GROUP_ROSTER_UPDATE' -- 团队变更
}) do
	frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(self, event, unit)
	local party = type(unit) == 'string' and unit:match('^party%d$')
	if event == 'UNIT_AURA' then
		if party then BC:aura(party) end
	elseif event == 'UNIT_LEVEL' then
		if party and BC[party] then self:level(BC[party]) end
	elseif event == 'GROUP_ROSTER_UPDATE' then
		for id = 1, MAX_PARTY_MEMBERS do
			BC:update('party' .. id)
			BC:update('party' .. id .. 'target')
			self:level(BC['party' .. id])
		end
	end
end)

frame:SetScript('OnUpdate', function(self, elapsed)
	if GetNumSubgroupMembers() == 0 then return end
	self.timer = (self.timer or 0) + elapsed
	if self.timer < .1 then return end
	self.timer = 0

	for id = 1, GetNumSubgroupMembers() do
		BC:bar(BC['party' .. id .. 'target'].healthbar)
		BC:bar(BC['party' .. id .. 'target'].manabar)
		BC:bar(BC['party' .. id .. 'pet'].healthbar)
		BC:bar(BC['party' .. id .. 'pet'].manabar)
	end
end)
