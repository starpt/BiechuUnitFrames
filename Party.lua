local addonName = ...
local BC = _G[addonName]
local frame = CreateFrame('Frame')

-- 等级
function frame:level(party)
	local level = UnitLevel(party.unit)
	if BC:getDB('party', 'showLevel') and level > 0 then
		party.levelText:SetText(level)
		party.levelText:Show()
	else
		party.levelText:Hide()
	end
end

-- 超出范围半透明
local resSpell, rangeSpell
if BC.class == 'PALADIN' then
	resSpell = GetSpellInfo(7328)
	rangeSpell = GetSpellInfo(635)
elseif BC.class == 'PRIEST' then
	resSpell = GetSpellInfo(2006)
	rangeSpell = GetSpellInfo(2050)
elseif BC.class == 'SHAMAN' then
	resSpell = GetSpellInfo(2008)
	rangeSpell = GetSpellInfo(331)
elseif BC.class == 'DRUID' then
	resSpell = GetSpellInfo(20484)
	rangeSpell = GetSpellInfo(5185)
end
<<<<<<< HEAD
function frame:range(unit) -- 是否在范围内
	return UnitIsDead(unit) and resSpell and IsSpellInRange(resSpell, unit) == 1 or rangeSpell and IsSpellInRange(rangeSpell, unit) == 1 or UnitInRange(unit)
end
function frame:alpha() -- 半透明
=======
function frame:range(unit)
	return UnitIsDead(unit) and resSpell and IsSpellInRange(resSpell, unit) == 1 or rangeSpell and IsSpellInRange(rangeSpell, unit) == 1 or UnitInRange(unit)
end
function frame:alpha()
>>>>>>> 8447105b03be850e32767cca2b240a2d100e5c38
	for id = 1, MAX_PARTY_MEMBERS do
		local party = 'party' .. id
		local alpha = self:range(party) and 1 or .5
		if UnitExists(party) then BC[party]:SetAlpha(alpha) end
		if UnitExists(party .. 'target') then BC[party .. 'target']:SetAlpha(alpha) end
		if UnitExists(party .. 'pet') then BC[party .. 'pet']:SetAlpha(alpha) end
	end
end

-- 小队背景 允许拖动
hooksecurefunc('UpdatePartyMemberBackground', function(self)
	if not PartyMemberBackground then return end
	local numMembers = GetNumSubgroupMembers()
	if numMembers > 0 then
		PartyMemberBackground:SetPoint('BOTTOMLEFT', 'PartyMemberFrame' .. numMembers, -5, -5)
		for id = 1, MAX_PARTY_MEMBERS do
			BC:update('party' .. id)
		end
	end
end)

-- 禁止队友施法完成后动画
hooksecurefunc('CastingBarFrame_OnEvent', function(self, event, unit)
	if type(unit) == 'string' and unit:match('^party%d$') then self.flash = nil end
end)
hooksecurefunc('CastingBarFrame_FinishSpell', function(self)
	if type(self.unit) == 'string' and self.unit:match('^party%d$') then self.flash = nil end
end)

-- 队伍友的宠物变化
hooksecurefunc('PartyMemberFrame_UpdatePet', function(self)
	if UnitIsConnected(self.unit) then BC:init(self.unit .. 'pet') end
end)

for id = 1, MAX_PARTY_MEMBERS do
	-- 队友
	local party = 'party'.. id
	BC[party] = _G['PartyMemberFrame'.. id]
	BC[party].borderTexture = _G['PartyMemberFrame'.. id .. 'Texture'] -- 边框
	BC[party].pvpIcon = _G['PartyMemberFrame'..id..'PVPIcon'] -- PVP状态图标

	-- 战斗中边框发红光
	BC[party].flash = _G['PartyMemberFrame'.. id .. 'Flash']
	if not BC[party].flash then
		BC[party].flash = BC[party]:CreateTexture()
		BC[party].flash.unit = unit
		BC[party].flash:SetPoint('TOPLEFT', BC[party], -24, 0)
		BC[party].flash:SetSize(242, 93)
		BC[party].flash:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-Flash')
		BC[party].flash:SetTexCoord(0, 0.9453125, 0, 0.181640625)
	end
	hooksecurefunc(BC[party].flash, 'Hide', function(self)
		if BC:getDB('party', 'combatFlash') and UnitAffectingCombat(self.unit) then
			self:SetVertexColor(1, 0, 0)
			self:SetAlpha(.7)
			if not self:IsVisible() then self:Show() end
		else
			self:SetAlpha(0)
		end
	end)


	-- 等级文字
	BC[party].levelText = BC[party]:CreateFontString(BC[party]:GetName() .. 'Level', 'OVERLAY', 'GameNormalNumberFont')
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

	-- 法力条暗黑模式
	hooksecurefunc(BC[party].manabar, 'SetStatusBarTexture', function(self)
		local unit = type(self.unit) == 'string' and self.unit:match('^party%d$')
		local texture = self:GetStatusBarTexture() and self:GetStatusBarTexture():GetTexture()
		if not unit or not texture then return end
		if type(texture) == 'number' and texture > 0 and BC:getDB('global', 'dark') then
			BC:dark(unit)
		end
	end)

	-- 施法条
	BC[party].castBar = CreateFrame('StatusBar', BC[party]:GetName() .. 'CastBar', BC[party], 'SmallCastingBarFrameTemplate')
	BC[party].castBar:SetSize(94, 6)
	BC[party].castBar.Border:SetDrawLayer('OVERLAY')
	BC[party].castBar.Border:ClearAllPoints()
	BC[party].castBar.Border:SetPoint('CENTER')
	BC[party].castBar.Border:SetSize(126, 28)
	BC[party].castBar.Border:SetAlpha(.8)
	BC[party].castBar.Icon:ClearAllPoints()
	BC[party].castBar.Icon:SetPoint('LEFT', -10.5, 0)
	BC[party].castBar.Icon:SetSize(8, 8)
	BC[party].castBar.Icon:SetTexCoord(.05, .95, .05, .95)
	BC[party].castBar.Text:SetDrawLayer('OVERLAY')
	BC[party].castBar.Text:ClearAllPoints()
	BC[party].castBar.Text:SetPoint('CENTER')
	BC[party].castBar.Spark:SetSize(24, 24)
	BC[party].castBar:Hide()
	BC[party].castBar:SetPoint('BOTTOMLEFT', 18, -13)
	CastingBarFrame_SetUnit(BC[party].castBar, party)

	-- 队友的宠物
	local partypet = party .. 'pet'
	BC[partypet] = _G['PartyMemberFrame'.. id .. 'PetFrame']
	BC[partypet].borderTexture = _G['PartyMemberFrame'.. id .. 'PetFrameTexture'] -- 边框
	BC[partypet]:SetAlpha(0)
	BC[partypet]:Show()

	-- 名字
	BC[partypet].name:ClearAllPoints()
	BC[partypet].name:SetPoint('TOPLEFT', 24, -15)

	parent = CreateFrame('Frame', nil, BC[partypet])
	parent:SetFrameLevel(5)

	-- 体力
	BC[partypet].healthbar.MiddleText = parent:CreateFontString()
	BC[partypet].healthbar.MiddleText:SetPoint('CENTER', BC[partypet].healthbar, 0, .5)
	BC[partypet].healthbar.SideText = parent:CreateFontString()
	BC[partypet].healthbar.SideText:SetPoint('LEFT', BC[partypet].healthbar, 'RIGHT', 2, .5)

	-- 法力
	BC[partypet].manabar = CreateFrame('StatusBar', nil, BC[partypet])
	BC[partypet].manabar:SetSize(35, 4)
	BC[partypet].manabar:SetPoint('TOPLEFT', 23, -10)
	BC[partypet].manabar.unit = partypet

	BC[partypet].manabar.MiddleText = parent:CreateFontString()
	BC[partypet].manabar.MiddleText:SetPoint('CENTER', BC[partypet].manabar, 0, -1)
	BC[partypet].manabar.SideText = parent:CreateFontString()
	BC[partypet].manabar.SideText:SetPoint('LEFT', BC[partypet].manabar, 'RIGHT', 2, -1)

	-- 队友的目标
	local partytarget = party .. 'target'
	BC[partytarget] = CreateFrame('Button', 'Party'.. id ..'TargetFrame', BC[party], 'SecureUnitButtonTemplate')
	BC[partytarget]:SetSize(100, 45)
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
	BC[partytarget].portrait:SetSize(36, 36)
	BC[partytarget].portrait:SetPoint('RIGHT', 8, -.5)

	-- 体力
	BC[partytarget].healthbar = CreateFrame('StatusBar', nil, BC[partytarget])
	BC[partytarget].healthbar:SetSize(46, 7)
	BC[partytarget].healthbar:SetPoint('TOPLEFT', 24, -14)
	BC[partytarget].healthbar:SetFrameLevel(1)
	BC[partytarget].healthbar.unit = partytarget

	BC[partytarget].healthbar.MiddleText = BC[partytarget]:CreateFontString()
	BC[partytarget].healthbar.MiddleText:SetPoint('CENTER', BC[partytarget].healthbar, 0, -1)
	BC[partytarget].healthbar.SideText = BC[partytarget]:CreateFontString()
	BC[partytarget].healthbar.SideText:SetPoint('RIGHT', BC[partytarget].healthbar, 'LEFT', -3, -1)

	-- 法力
	BC[partytarget].manabar = CreateFrame('StatusBar', nil, BC[partytarget])
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
		BC:aura(party) -- Buff/Debuff

		if not BC:getDB('party', 'outRange') then
			BC[party]:SetAlpha(1)
			BC[partytarget]:SetAlpha(1)
			BC[partypet]:SetAlpha(1)
		end

		-- 显示施法条
		local showCastBar = BC:getDB('party', 'showCastBar')
		if BC[party].castBar then
			if showCastBar then
				BC[party].castBar:SetStatusBarTexture(BC:file(BC.barList[1]))
				BC[party].castBar.Border:SetTexture(BC:file(BC.barList[3]))
				BC[party].castBar.BorderShield:SetTexture(BC:file(BC.barList[4]))
				BC[party].castBar.Text:SetFont(BC[party].castBar.Text:GetFont(), 9)
				CastingBarFrame_SetUnit(BC[party].castBar, party, true, true)
			else
				CastingBarFrame_SetUnit(BC[party].castBar)
			end
		end

		-- 定位
		if id > 1 and not InCombatLockdown() then
			local offsetY = ceil((MAX_TARGET_BUFFS + MAX_TARGET_DEBUFFS) / BC:getDB('party', 'auraRows')) * (BC:getDB('party', 'auraSize') + 2)
			BC[party]:SetPoint('TOPLEFT', _G['PartyMemberFrame' .. (id - 1)], 0, -42 -offsetY - (showCastBar and 18 or 0))
		end
	end
end

-- 获取小队id
function frame:partyID(unit)
	if type(unit) == 'string' and UnitExists(unit) and UnitInParty(unit) and not UnitIsUnit('player', unit) then
		for id = 1, MAX_PARTY_MEMBERS do
			if UnitIsUnit(unit, 'party' .. id) then
				return id
			end
		end
	end
end

for _, event in pairs({
	'GROUP_ROSTER_UPDATE', -- 队伍变更
	'UNIT_LEVEL', -- 升级
	'UNIT_AURA', -- Buff/Debuff变化
	'PLAYER_REGEN_ENABLED', -- 结束战斗
}) do
	frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(self, event, unit)
	local pid = self:partyID(unit)
	if event == 'GROUP_ROSTER_UPDATE' then
		if GetNumSubgroupMembers() > 0 then
			for id = 1, MAX_PARTY_MEMBERS do
				local party = BC['party'.. id]
				local level = UnitLevel('party'.. id)
<<<<<<< HEAD
				if party and party.levelText and party.levelText:IsShown() and level > 0 then
					party.levelText:SetText(level)
=======
				if party and party.level and party.level:IsShown() and level > 0 then
					party.level:SetText(level)
>>>>>>> 8447105b03be850e32767cca2b240a2d100e5c38
				end
			end
		end
	elseif event == 'UNIT_LEVEL' then
		if pid then frame:level(BC['party' .. pid]) end
	elseif event == 'UNIT_AURA' then
		if pid then BC:aura('party' .. pid) end
	elseif event == 'PLAYER_REGEN_ENABLED' then
		if GetNumSubgroupMembers() > 0 then
			for id = 1, MAX_PARTY_MEMBERS do
<<<<<<< HEAD
				BC:update('party' .. id) -- 更新队友
				BC:init('party' .. id .. 'pet') -- 初始化队友宠物
				BC:update('party' .. id .. 'target')  -- 更新队友目标
=======
				BC:update('party' .. id) -- 更新队友状态
				BC:update('party' .. id .. 'pet')  -- 更新队友宠物状态
				BC:update('party' .. id .. 'target')  -- 更新队友目标状态
>>>>>>> 8447105b03be850e32767cca2b240a2d100e5c38
			end
		end
	end
end)

frame:SetScript('OnUpdate', function(self, rate)
	local now = GetTime()
	if self.rate and now < self.rate then return end
	self.rate = now + .02 -- 刷新率
	for id = 1, MAX_PARTY_MEMBERS do
		BC:bar(BC['party' .. id .. 'target'].manabar)
		BC:bar(BC['party' .. id.. 'target'].healthbar)
		BC:bar(BC['party' .. id .. 'pet'].manabar)
		BC:bar(BC['party' .. id.. 'pet'].healthbar)
	end
	if BC:getDB('party', 'outRange') then self:alpha() end
end)
