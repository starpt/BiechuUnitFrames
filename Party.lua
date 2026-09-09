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

-- 禁止队友施法完成后动画
hooksecurefunc('CastingBarFrame_OnEvent', function(self, event, unit)
	if type(unit) == 'string' and unit:match('^party%d$') then self.flash = nil end
end)
hooksecurefunc('CastingBarFrame_FinishSpell', function(self)
	if type(self.unit) == 'string' and self.unit:match('^party%d$') then self.flash = nil end
end)

-- 队友的宠物变化
hooksecurefunc('PartyMemberFrame_UpdatePet', function(self)
	local party = type(self.unit) == 'string' and self.unit:match('^party%d$')
	if party then BC:init(party .. 'pet') end
end)

-- 关闭界面设界后更新队友宠物
hooksecurefunc(InterfaceOptionsFrame, 'Hide', function(self)
	for id = 1, GetNumPartyMembers() do
		BC:init('party' .. id .. 'pet')
	end
end)

for id = 1, MAX_PARTY_MEMBERS do
	-- 队友
	local party = 'party' .. id
	BC[party] = _G['PartyMemberFrame' .. id]
	BC[party].borderTexture = _G['PartyMemberFrame' .. id .. 'Texture'] -- 边框
	BC[party].pvpIcon = _G['PartyMemberFrame' .. id .. 'PVPIcon'] -- PVP状态图标

	-- 战斗中边框发红光
	BC[party].flash = _G['PartyMemberFrame' .. id .. 'Flash']
	if not BC[party].flash then
		BC[party].flash = BC[party]:CreateTexture()
		BC[party].flash.unit = party
		BC[party].flash:SetPoint('TOPLEFT', BC[party], -24, 0)
		BC[party].flash:SetSize(242, 93)
		BC[party].flash:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-Flash')
		BC[party].flash:SetTexCoord(0, 0.9453125, 0, 0.181640625)
	end

	-- 等级文字
	BC[party].levelText = BC[party]:CreateFontString(BC[party]:GetName() .. 'Level', 'OVERLAY', 'GameFontNormalSmall')
	BC[party].levelText:SetPoint('BOTTOM', BC[party], 'BOTTOMLEFT', 6, 3)
	BC[party].levelText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')

	-- 体力
	BC[party].healthbar.MiddleText = _G['PartyMemberFrame' .. id .. 'HealthBarText']
	local parent = BC[party].healthbar.MiddleText:GetParent()
	BC[party].healthbar.LeftText = parent:CreateFontString()
	BC[party].healthbar.LeftText:SetPoint('LEFT', BC[party].healthbar, 0, 0.5)
	BC[party].healthbar.RightText = parent:CreateFontString()
	BC[party].healthbar.RightText:SetPoint('RIGHT', BC[party].healthbar, -1, 0.5)
	BC[party].healthbar.SideText = parent:CreateFontString()
	BC[party].healthbar.SideText:SetPoint('LEFT', BC[party].healthbar, 'RIGHT', 2, 0.5)

	-- 法力
	BC[party].manabar.MiddleText = _G['PartyMemberFrame' .. id .. 'ManaBarText']
	parent = BC[party].manabar.MiddleText:GetParent()
	BC[party].manabar.LeftText = parent:CreateFontString()
	BC[party].manabar.LeftText:SetPoint('LEFT', BC[party].manabar, 0, 0.5)
	BC[party].manabar.RightText = parent:CreateFontString()
	BC[party].manabar.RightText:SetPoint('RIGHT', BC[party].manabar, -1, 0.5)
	BC[party].manabar.SideText = parent:CreateFontString()
	BC[party].manabar.SideText:SetPoint('LEFT', BC[party].manabar, 'RIGHT', 2, 0.5)

	-- 施法条
	BC[party].castBar = CreateFrame('StatusBar', BC[party]:GetName() .. 'CastBar', BC[party], 'CastingBarFrameTemplate')
	BC[party].castBar:SetSize(94, 6)
	BC[party].castBar:Hide()
	BC[party].castBar.Border = _G[BC[party].castBar:GetName() .. 'Border']
	BC[party].castBar.Border:SetSize(125, 31.25)
	BC[party].castBar.Border:ClearAllPoints()
	BC[party].castBar.Border:SetPoint('CENTER')
	BC[party].castBar.Text = _G[BC[party].castBar:GetName() .. 'Text']
	BC[party].castBar.Text:SetDrawLayer('OVERLAY')
	BC[party].castBar.Text:SetFont(STANDARD_TEXT_FONT, 8)
	BC[party].castBar.Text:ClearAllPoints()
	BC[party].castBar.Text:SetPoint('CENTER', 0, 0.5)
	BC[party].castBar.BorderShield = _G[BC[party].castBar:GetName() .. 'BorderShield']
	BC[party].castBar.BorderShield:SetSize(125, 31.25)
	BC[party].castBar.BorderShield:ClearAllPoints()
	BC[party].castBar.BorderShield:SetPoint('CENTER', -3, 0)
	BC[party].castBar.Icon = _G[BC[party].castBar:GetName() .. 'Icon']
	BC[party].castBar.Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	BC[party].castBar.Icon:ClearAllPoints()
	BC[party].castBar.Icon:SetPoint('LEFT', -13.5, 0)
	BC[party].castBar.Icon:SetSize(10, 10)
	BC[party].castBar.Icon:Show()

	-- 队友的宠物
	local partypet = party .. 'pet'
	BC[partypet] = _G['PartyMemberFrame' .. id .. 'PetFrame']
	BC[partypet].borderTexture = _G['PartyMemberFrame' .. id .. 'PetFrameTexture'] -- 边框

	-- 名字
	BC[partypet].name:ClearAllPoints()
	BC[partypet].name:SetPoint('TOPLEFT', 24, -15)

	parent = CreateFrame('Frame', nil, BC[partypet])
	parent:SetFrameLevel(12)

	-- 体力
	BC[partypet].healthbar.MiddleText = parent:CreateFontString()
	BC[partypet].healthbar.MiddleText:SetPoint('CENTER', BC[partypet].healthbar, 0, 0.5)
	BC[partypet].healthbar.SideText = parent:CreateFontString()
	BC[partypet].healthbar.SideText:SetPoint('LEFT', BC[partypet].healthbar, 'RIGHT', 2, 0.5)

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
	BC[partytarget].portrait:SetSize(36, 36)
	BC[partytarget].portrait:SetPoint('RIGHT', 8, -0.5)

	-- 体力
	BC[partytarget].healthbar = CreateFrame('StatusBar', nil, BC[partytarget])
	BC[partytarget].healthbar:SetSize(46, 7)
	BC[partytarget].healthbar:SetPoint('TOPLEFT', 24, -14)
	BC[partytarget].healthbar:SetFrameLevel(1)
	BC[partytarget].healthbar.unit = partytarget

	BC[partytarget].healthbar.MiddleText = BC[partytarget]:CreateFontString()
	BC[partytarget].healthbar.MiddleText:SetPoint('CENTER', BC[partytarget].healthbar)
	BC[partytarget].healthbar.SideText = BC[partytarget]:CreateFontString()
	BC[partytarget].healthbar.SideText:SetPoint('RIGHT', BC[partytarget].healthbar, 'LEFT', -3, 0)

	-- 法力
	BC[partytarget].manabar = CreateFrame('StatusBar', nil, BC[partytarget])
	BC[partytarget].manabar:SetSize(46, 7)
	BC[partytarget].manabar:SetPoint('TOPLEFT', 24, -23)
	BC[partytarget].manabar:SetFrameLevel(1)
	BC[partytarget].manabar.unit = partytarget

	BC[partytarget].manabar.MiddleText = BC[partytarget]:CreateFontString()
	BC[partytarget].manabar.MiddleText:SetPoint('CENTER', BC[partytarget].manabar)
	BC[partytarget].manabar.SideText = BC[partytarget]:CreateFontString()
	BC[partytarget].manabar.SideText:SetPoint('RIGHT', BC[partytarget].manabar, 'LEFT', -3, 0)

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

		-- 施法条
		BC[party].castBar:SetStatusBarTexture(BC:file(BC.barList[1]))
		BC[party].castBar.Border:SetTexture(BC:file(BC.barList[3]))
		BC[party].castBar.BorderShield:SetTexture(BC:file(BC.barList[4]))
		local showCastBar = BC:getDB('party', 'showCastBar')
		if showCastBar then
			BC[party].castBar.unit = party
		else
			BC[party].castBar:Hide()
			if BC[party].castBar.unit == party then BC[party].castBar.unit = nil end
		end

		-- 定位
		if id > 1 and not InCombatLockdown() then
			local offsetY = ceil((MAX_TARGET_BUFFS + MAX_TARGET_DEBUFFS) / BC:getDB('party', 'auraRows')) * (BC:getDB('party', 'auraSize') + 2)
			BC[party]:SetPoint('TOPLEFT', _G['PartyMemberFrame' .. (id - 1)], 0, -42 - offsetY - (showCastBar and 18 or 0))
		end
	end

	BC[partytarget].init = function()
		BC[partytarget]:SetPoint(BC:getDB('partytarget', 'relative'), BC[party], BC:getDB('partytarget', 'offsetX'), BC:getDB('partytarget', 'offsetY'))
	end
end

for _, event in pairs({
	'UNIT_AURA', -- Buff/Debuff变化
	'UNIT_LEVEL', -- 升级
	'PARTY_MEMBERS_CHANGED', -- 队伍变更
}) do
	frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(self, event, unit)
	local party = type(unit) == 'string' and unit:match('^party%d$')
	if event == 'UNIT_AURA' then
		if party then BC:aura(party) end
	elseif event == 'UNIT_LEVEL' then
		if party and BC[party] then self:level(BC[party]) end
	elseif event == 'PARTY_MEMBERS_CHANGED' then
		for id = 1, MAX_PARTY_MEMBERS do
			BC:update('party' .. id)
			BC:update('party' .. id .. 'target')
			self:level(BC['party' .. id])
		end
	end
end)

frame:SetScript('OnUpdate', function(self)
	if GetNumPartyMembers() == 0 then return end
	local now = GetTime()
	if self.rate and now < self.rate then return end
	self.rate = now + 0.02 -- 刷新率

	for id = 1, GetNumPartyMembers() do
		BC:bar(BC['party' .. id .. 'target'].healthbar)
		BC:bar(BC['party' .. id .. 'target'].manabar)
		BC:bar(BC['party' .. id .. 'pet'].healthbar)
		BC:bar(BC['party' .. id .. 'pet'].manabar)
	end
end)
