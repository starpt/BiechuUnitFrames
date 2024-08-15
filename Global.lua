local addonName = ...
_G[addonName] = _G[addonName] or CreateFrame('Frame')
local BC = _G[addonName]
local L = _G[addonName .. 'Locale']
BC.charKey = UnitName('player') .. ' - ' .. GetRealmName()
BC.class = select(2, UnitClass('player'))
BC.texture = 'Interface\\AddOns\\' .. addonName .. '\\Textures\\'

-- 默认设置
BC.default = {
	global = {
		dark = true,
		healthBarColor = true,
		nameTextClassColor = true,
		nameTextOutline = true,
		carry = 1,
		nameFont = L.fontList[1].value,
		valueFont = L.fontList[1].value,
		fontFlags = L.fontFlagsList[2].value,
		dragSystemFarmes = true,
		incomingHeals = true,
		autoTab = true,
		autoNameplate = true,
	},
	player = {
		relative = 'CENTER',
		offsetX = -223,
		offsetY = -98,
		drag = true,
		combatFlash = true,
		miniIcon = true,
		autoTalentEquip = true,
		equipmentIcon = true,
		hidePartyNumber = true,
		fiveSecondRule = true,
		druidBar = true,
		border = 1,
		portrait = 0,
		scale = 1,
		nameFontSize = 14,
		valueFontSize = 12,
		valueStyle = 2,
	},
	pet = {
		anchor = 'PlayerFrame',
		relative = 'TOPLEFT',
		offsetX = 84,
		offsetY = not UnitInVehicle('player') and (BC.class == 'DEATHKNIGHT' or BC.class == 'SHAMAN') and -80 or -61,
		hideName = true,
		nameFontSize = 10,
		valueFontSize = 10,
		valueStyle = 2,
	},
	pettarget = {
		anchor = 'PetFrame',
		relative = 'BOTTOMRIGHT',
		offsetX = 58,
		offsetY = -8,
		hideName = true,
		portrait = 1,
		scale = .6,
		nameFontSize = 12,
		valueFontSize = 12,
		valueStyle = 7,
	},
	target = {
		anchor = 'PlayerFrame',
		relative = 'TOPLEFT',
		offsetX = 445,
		offsetY = 0,
		drag = true,
		combatFlash = true,
		miniIcon = true,
		threatLeft = true,
		selfCooldown = true,
		dispelCooldown = true,
		dispelStealable = true,
		scale = 1,
		statusBarAlpha = 1,
		nameFontSize = 14,
		valueFontSize = 12,
		valueStyle = 5,

		auraRows = 5, -- 一行最多Buff/Debuff
		auraSize = 20, -- 图标大小
		auraX = -17, -- 起始X轴位置
		auraY = -46 , -- 起始Y轴位置
	},
	targettarget = {
		anchor = 'TargetFrame',
		relative = 'BOTTOMRIGHT',
		offsetX = -35,
		offsetY = -10,
		portrait = 1,
		nameFontSize = 10,
		valueFontSize = 10,
		valueStyle = 2,
	},
	focus = {
		anchor = 'PlayerFrame',
		relative = 'TOPLEFT',
		offsetX = -180,
		offsetY = 0,
		drag = true,
		combatFlash = true,
		miniIcon = true,
		threatLeft = true,
		selfCooldown = true,
		dispelCooldown = true,
		dispelStealable = true,
		scale = 1,
		statusBarAlpha = 1,
		nameFontSize = 14,
		valueFontSize = 12,
		valueStyle = 5,
		auraRows = 5, -- 一行最多Buff/Debuff
		auraSize = 20, -- 图标大小
		auraX = -17, -- 起始X轴位置
		auraY = -46 , -- 起始Y轴位置
	},
	focustarget = {
		anchor = 'FocusFrame',
		relative = 'BOTTOMRIGHT',
		offsetX = -35,
		offsetY = -10,
		portrait = 1,
		nameFontSize = 10,
		valueFontSize = 10,
		valueStyle = 2,
	},
	party = {
		relative = 'LEFT',
		offsetX = 190,
		offsetY = 325,
		drag = true,
		portraitCombat = true,
		combatFlash = true,
		showLevel = true,
		raidShowParty = true,
		showCastBar = true,
		outRange = true,
		selfCooldown = true,
		dispelCooldown = true,
		dispelStealable = true,
		scale = 1,
		nameFontSize = 10,
		valueFontSize = 10,
		valueStyle = 7,
		auraRows = 16, -- 一行最多Buff/Debuff
		auraSize = 16, -- 图标大小
		auraX = -15, -- 起始X轴位置
		auraY = -36, -- 起始Y轴位置
	},
	partypet = {
		relative = 'BOTTOMRIGHT',
		offsetX = -22,
		offsetY = -1,
		hideName = true,
		nameFontSize = 7,
		valueFontSize = 7,
		valueStyle = 7,
	},
	partytarget = {
		relative = 'TOPRIGHT',
		offsetX = 150,
		offsetY = 2,
		portrait = 1,
		hideName = true,
		scale = 1,
		nameFontSize = 10,
		valueFontSize = 10,
		valueStyle = 7,
	},
}

-- 单元框架
BC.unitList = {
	'player',
	'pet',
	'pettarget',
	'target',
	'targettarget',
	'focus',
	'focustarget',
	'party1',
	'party2',
	'party3',
	'party4',
	'party1pet',
	'party2pet',
	'party3pet',
	'party4pet',
	'party1target',
	'party2target',
	'party3target',
	'party4target',
}

-- 边框材质
BC.borderList = {
	'TargetingFrame\\UI-TargetingFrame',
	'TargetingFrame\\UI-TargetingFrame-Rare',
	'TargetingFrame\\UI-TargetingFrame-Rare-Elite',
	'TargetingFrame\\UI-TargetingFrame-Elite',
	'TargetingFrame\\UI-SmallTargetingFrame',
	'TargetingFrame\\UI-TargetofTargetFrame',
	'TargetingFrame\\UI-PartyFrame',
}

-- 条材质
BC.barList = {
	-- 条背景
	'TargetingFrame\\UI-StatusBar',

	-- 边框
	'Tooltips\\UI-StatusBar-Border',

	-- 队友施法条边框
	'CastingBar\\UI-CastingBar-Border-Small',
	'CastingBar\\UI-CastingBar-Small-Shield',
}

-- 头像材质
BC.portraitList = {
	[1] = 'TargetingFrame\\UI-Classes-Circles',
	[2] = 'Cat',
	[3] = 'Dog',
	[4] = 'Panda',
	[5] = 'CoolFace',
}

-- 种类图标
BC.creatureList = {
	[1] = 'Interface\\Icons\\Ability_Racial_BearForm', -- 野兽
	[2] = 'Interface\\Icons\\Spell_Holy_PrayerOfHealing', -- 人型生物
	[3] = 'Interface\\Icons\\INV_Misc_Head_Dragon_01', -- 龙类
	[4] = 'Interface\\Icons\\INV_Gizmo_02', -- 机械
	[5] = 'Interface\\Icons\\Spell_Shadow_Metamorphosis', -- 恶魔
	[6] = 'Interface\\Icons\\Spell_Frost_SummonWaterElemental', -- 元素生物
	[7] = 'Interface\\Icons\\Ability_Racial_Avatar', -- 巨人
	[8] = 'Interface\\Icons\\Spell_Shadow_RaiseDead', -- 亡灵
	[9] = 'Interface\\Icons\\Spell_Nature_NatureResistanceTotem', -- 图腾
	[10] = 'Interface\\Icons\\spell_shadow_antishadow', -- 畸变怪
	[11] = 'Interface\\Icons\\ABILITY_SEAL', -- 小动物
	[12] = 'Interface\\Icons\\INV_Elemental_Mote_Air01', -- 气体云雾
	[13] = 'Interface\\Icons\\Spell_Nature_Polymorph', -- 非战斗宠物
	[14] = 'Interface\\Icons\\INV_Misc_QuestionMark', -- 未指定
}

-- 读取变量
function BC:getDB(key, name)
	if type(key) ~= 'string' then return end
	local db = _G[addonName .. 'DB'] or {}
	local default = 'Public'
	if key == 'config' then
		return db.config or default
	elseif key == 'cache' then
		db[key] = db[key] or {}
		return db[key][name]
	end
	db = db[db.config or default] or {}
	if type(db) == 'table' and type(db[key]) == 'table' and db[key][name] ~= nil then
		return db[key][name]
	elseif type(self.default[key]) == 'table' and self.default[key][name] ~= nil then
		return self.default[key][name]
	end
end

-- 保存变量
function BC:setDB(key, name, value)
	if type(key) ~= 'string' then return end
	local db = _G[addonName .. 'DB'] or {}
	if key == 'config' then
		db[key] = name
	elseif key == 'cache' then
		db[key] = db[key] or {}
		db[key][name] = value
	else
		local charKey = db.config or 'Public'
		db[charKey] = db[charKey] or {}
		db[charKey][key] = db[charKey][key] or {}
		db[charKey][key][name] = value
	end
	_G[addonName .. 'DB'] = db

	if self[key] then
		self:init(key)
	elseif key == 'party' then
		for i = 1, MAX_PARTY_MEMBERS do
			self:init('party' .. i)
		end
	elseif key == 'partypet' then
		for i = 1, MAX_PARTY_MEMBERS do
			self:init('party' .. i .. 'pet')
		end
	elseif key == 'partytarget' then
		for i = 1, MAX_PARTY_MEMBERS do
			self:init('party' .. i .. 'target')
		end
	else
		self:init()
	end
end

-- 非战斗中按住Shift拖动
function BC:drag(frame, parent, drag, combat, shift, callBack)
	local mover = parent or frame
	if not frame or not mover then return end

	frame:SetScript('OnMouseDown', function(self, button)
		if drag == nil and combat == nil then drag = BC:getDB('global', 'dragSystemFarmes') end
		if drag and (not combat or not InCombatLockdown()) and (not shift or IsShiftKeyDown()) and button == 'LeftButton' then
			self.moving = true
			mover:SetMovable(true) -- 允许移动
			mover:SetClampedToScreen(true) -- 屏幕内移动
			mover:StartMoving()
		end
	end)
	frame:SetScript('OnMouseUp', function(self)
		if self.moving then
			mover:StopMovingOrSizing()
			mover:SetUserPlaced(false) -- 不保存在 layout-local.txt
			if type(callBack) == 'function' then callBack(mover) end
		end
		self.moving = nil
	end)
end
-- 自由拖动系统框架
BC:drag(PaperDollFrame, CharacterFrame) -- 角色信息
BC:drag(ReputationFrame, CharacterFrame) -- 声望
BC:drag(SkillFrame, CharacterFrame) -- 技能
BC:drag(TokenFrame, CharacterFrame) -- 货币
BC:drag(SpellBookFrame) -- 法术书和技能
BC:drag(QuestLogFrame) -- 任务日志
BC:drag(FriendsFrame) -- 社交
BC:drag(CommunitiesFrame) -- 群组
BC:drag(PVPFrame, PVPParentFrame) -- PVP
BC:drag(BattlefieldFrame, PVPParentFrame) -- 战场
BC:drag(PVEFrame) -- 地下城与副本查找器
BC:drag(GameMenuFrame) -- 游戏菜单
BC:drag(HelpFrame) -- 客服支持
BC:drag(SettingsPanel) -- 设置选项
BC:drag(AddonList) -- 插件列表
BC:drag(GossipFrame) -- 对话框
BC:drag(MerchantFrame) -- 购物框
hooksecurefunc('TalentFrame_LoadUI', function() -- 天赋
	BC:drag(PlayerTalentFrame)
end)
hooksecurefunc('GlyphFrame_LoadUI', function() -- 雕文
	BC:drag(GlyphFrame, PlayerTalentFrame)
end)
hooksecurefunc('AchievementFrame_LoadUI', function()
	BC:drag(AchievementFrameHeader, AchievementFrame) -- 成就
	BC:drag(AchievementFrameCategoriesContainer, AchievementFrame) -- 统计
end)
hooksecurefunc('CollectionsJournal_LoadUI', function() -- 藏品
	BC:drag(CollectionsJournal)
end)
hooksecurefunc('MacroFrame_LoadUI', function() -- 宏命令设置
	BC:drag(MacroFrame)
end)

-- 保护性驱散Debuff
local	DISPEL_DEBUFF = {
	['Curse'] = {
		[2782] = true,  -- 德鲁伊 解除诅咒
		[475] = true,   -- 法师 解除诅咒
		[51886] = true, -- 萨满 净化灵魂
	},
	['Disease'] = {
		[4987] = true,  -- 圣骑士 清洁术
		[528] = true,   -- 牧师 祛病术
		[552] = true,   -- 牧师 驱除疾病
		[526] = (BC.class == 'SHAMAN'),  -- 萨满 驱毒术
		[8170] = true,  -- 萨满 净化图腾
		[51886] = true, -- 萨满 净化灵魂
	},
	['Magic'] = {
		[4987] = true,  -- 圣骑士 清洁术
		[527] = true,   -- 牧师 驱散魔法
		[32375] = true, -- 牧师 群体驱散
		[19505] = true, -- 术士 吞噬魔法
	},
	['Poison'] = {
		[2893] = true,  -- 德鲁伊 驱毒术
		[8946] = true,  -- 德鲁伊 消毒术
		[4987] = true,  -- 圣骑士 清洁术
		[526] = true,   -- 萨满 驱毒术
		[8170] = true,  -- 萨满 净化图腾
		[51886] = true, -- 萨满 净化灵魂
	},
}
-- 进攻性驱散Buff
local	DISPEL_BUFF = {
	['Magic'] = {
		[527] = true,   -- 牧师 驱散魔法
		[32375] = true, -- 牧师 群体驱散
		[19505] = true, -- 术士 吞噬魔法
		[30449] = true, -- 法师 法术吸取
		[19801] = true, -- 猎人 宁神射击
		[47488] = true, -- 战士 盾牌猛击
		[370] = true,   -- 萨满 净化术
	},
	[''] = { -- 激怒
		[19801] = true, -- 猎人 宁神射击
	}
}
function BC:dispel(unit, dispelType)
	local spell
	if UnitCanAttack('player', unit) then
		spell = DISPEL_BUFF[dispelType]
	elseif UnitIsFriend('player', unit) then
		spell = DISPEL_DEBUFF[dispelType]
	end
	if not spell then return end
	for id, can in pairs(spell) do
		if can then
			local name = GetSpellInfo(id)
			if name and GetSpellInfo(name) then
				return name
			end
		end
	end
end
-- 宠物/队友buff/debuff直接显示时隐藏buff鼠标提示
hooksecurefunc('PartyMemberBuffTooltip_Update', function()
	PartyMemberBuffTooltip:Hide()
end)
-- OmniCC 冷却倒计时立即更新
hooksecurefunc('CooldownFrame_Set', function(self)
	if self:IsShown() and self._occ_show ~= nil then
		self:Hide()
		self:Show()
	end
end)
-- Buff/Debuff
function BC:aura(unit)
	local frame = BC[unit]
	if not frame then return end
	local key = unit:gsub('[%d-]', '')
	local maxBuffs = MAX_TARGET_BUFFS -- 最多Buff
	local maxDebuffs = MAX_TARGET_DEBUFFS -- 最多Debuff
	local rows = self:getDB(key, 'auraRows') or maxDebuffs -- 一行最多数量
	local spac = 2 -- 间隔
	local size = self:getDB(key, 'auraSize') or 21
	local offsetX = self:getDB(key, 'auraX') -- 起始坐标X
	local offsetY = self:getDB(key, 'auraY') -- 起始坐标Y
	local dark = BC:getDB('global', 'dark')
	local valueFont = self:getDB('global', 'valueFont')
	local fontFlags = self:getDB('global', 'fontFlags')
	local selfCooldown = BC:getDB(key, 'selfCooldown')
	local dispelCooldown = BC:getDB(key, 'dispelCooldown')
	local dispelStealable = BC:getDB(key, 'dispelStealable')
	local total = 0
	for i = 1, maxBuffs do
		local name = frame:GetName() .. 'Buff' .. i
		local buff = _G[name] or CreateFrame('Button', name, frame)
		buff:SetFrameLevel(5)

		buff.icon = _G[name .. 'Icon']
		if not buff.icon then
			buff.icon = buff:CreateTexture(name .. 'Icon', 'BACKGROUND')
			buff.icon:SetPoint('CENTER')
		end
		buff.icon:SetTexCoord(.06, .94, .06, .94)

		buff.cooldown = _G[name .. 'Cooldown']
		if not buff.cooldown then
			buff.cooldown = CreateFrame('Cooldown', name .. 'Cooldown', buff, 'CooldownFrameTemplate')
			buff.cooldown:SetReverse(true)
		end

		buff.count = _G[name .. 'Count'] or buff:CreateFontString(name .. 'Count', 'OVERLAY')
		buff.count:SetPoint('BOTTOMRIGHT', 2, -2)
		buff.count:SetFont(valueFont, (size or 21) * .6, fontFlags)

		buff.stealable = _G[name .. 'Stealable']
		if not buff.stealable then
			buff.stealable = buff:CreateTexture(name .. 'Stealable', 'ARTWORK')
			buff.stealable:SetPoint('CENTER')
			buff.stealable:SetBlendMode('ADD')
			buff.stealable:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-Stealable')
		end
		buff.stealable:Hide()

		buff.border = _G[name .. 'Border']
		if not buff.border then
			buff.border = buff:CreateTexture(name .. 'Border', 'BORDER')
			buff.border:SetAllPoints(buff)
			buff.border:SetTexture(BC.texture .. 'Border')
		end
		if dark then
			buff.border:SetVertexColor(.1, .1, .1)
		else
			buff.border:SetVertexColor(.4, .4, .4)
		end

		buff:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:SetUnitBuff(unit, i)
		end)
		buff:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)

		local _, icon, count, dispelType, duration, expirationTime, source = UnitBuff(unit, i)
		if icon then
			CooldownFrame_Set(buff.cooldown, expirationTime - duration, duration, true)
			local selfCast = source == 'player' or source == 'pet'
			if UnitCanAttack('player', unit) then -- 进攻驱散
				local canDispel = self:dispel(unit, dispelType) -- 可以驱散
				buff.cooldown._occ_show = not dispelCooldown or canDispel -- 倒计时
				if dispelStealable and canDispel then buff.stealable:Show() end -- 高亮
			elseif UnitIsFriend('player', unit) then -- 施放Buff
				buff.cooldown._occ_show = not selfCooldown or selfCast
			end

			local iconSize = selfCast and size or size - 2
			buff:SetSize(iconSize, iconSize)

			if offsetX and offsetY then
				local x = math.fmod(i, rows) -- 横排数
				if x == 0 then x = rows end
				local y = ceil(i / rows) -- 列数
				buff:ClearAllPoints()
				buff:SetPoint('TOPLEFT', offsetX + x * (size + spac), offsetY - (size + spac) * y)
			end

			buff.icon:SetSize(iconSize - 2, iconSize - 2)
			buff.icon:SetTexture(icon)

			buff.stealable:SetSize(iconSize + 4, iconSize + 4)

			if type(count) == 'number' and count > 1 then
				buff.count:SetText(count)
			else
				buff.count:SetText(nil)
			end

			buff:Show()
			total = total + 1
		else
			buff:Hide()
		end
	end

	-- Debuff
	local row = ceil(total / rows) -- 行数
	total = 0
	for i = 1, maxDebuffs do
		local name = frame:GetName() .. 'Debuff' .. i
		local debuff = _G[name] or CreateFrame('Button', name, frame)
		debuff:SetFrameLevel(5)

		debuff.icon = _G[name .. 'Icon']
		if not debuff.icon then
			debuff.icon = debuff:CreateTexture(name .. 'Icon', 'BACKGROUND')
			debuff.icon:SetPoint('CENTER')
		end
		debuff.icon:SetTexCoord(.06, .94, .06, .94)

		debuff.cooldown = _G[name .. 'Cooldown']
		if not debuff.cooldown then
			debuff.cooldown = CreateFrame('Cooldown', name .. 'Cooldown', debuff, 'CooldownFrameTemplate')
			debuff.cooldown:SetReverse(true)
		end

		debuff.count = _G[name .. 'Count'] or debuff:CreateFontString(name .. 'Count', 'OVERLAY')
		debuff.count:SetPoint('BOTTOMRIGHT', 2, -2)
		debuff.count:SetFont(valueFont, (size or 21) * .6, fontFlags)

		debuff.stealable = _G[name .. 'Stealable']
		if not debuff.stealable then
			debuff.stealable = debuff:CreateTexture(name .. 'Stealable', 'ARTWORK')
			debuff.stealable:SetPoint('CENTER')
			debuff.stealable:SetBlendMode('ADD')
			debuff.stealable:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-Stealable')
		end
		debuff.stealable:Hide()

		debuff.border = _G[name .. 'Border']
		if not debuff.border then
			debuff.border = debuff:CreateTexture(name .. 'Border', 'BORDER')
			debuff.border:SetAllPoints(debuff)
			debuff.border:SetTexture(BC.texture .. 'Border')
		end
		if dark then
			debuff.border:SetVertexColor(.1, .1, .1)
		else
			debuff.border:SetVertexColor(.4, .4, .4)
		end

		debuff:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:SetUnitDebuff(unit, i)
		end)
		debuff:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)

		local _, icon, count, dispelType, duration, expirationTime, source = UnitDebuff(unit, i)
		if icon then
			CooldownFrame_Set(debuff.cooldown, expirationTime - duration, duration, true)
			local selfCast = source == 'player' or source == 'pet'
			if UnitCanAttack('player', unit) then -- Dot
				debuff.cooldown._occ_show = not selfCooldown or selfCast
			elseif UnitIsFriend('player', unit) then -- 防御驱散
				local canDispel = self:dispel(unit, dispelType)
				if dispelStealable and canDispel then debuff.stealable:Show() end -- 高亮
				debuff.cooldown._occ_show = not dispelCooldown or canDispel
			end

			local iconSize = selfCast and size or size - 2
			debuff:SetSize(iconSize, iconSize)

			if offsetX and offsetY then
				local x = math.fmod(i, rows) -- 横排数
				if x == 0 then x = rows end
				local y = ceil(i / rows) + row -- 列数
				debuff:ClearAllPoints()
				debuff:SetPoint('TOPLEFT', offsetX + x * (size + spac), offsetY - (size + spac) * y)
			end

			debuff.icon:SetSize(iconSize - 2, iconSize - 2)
			debuff.icon:SetTexture(icon)

			debuff.stealable:SetSize(iconSize + 4, iconSize + 4)

			if type(count) == 'number' and count > 1 then
				debuff.count:SetText(count)
			else
				debuff.count:SetText(nil)
			end

			-- 边框
			if dispelType then
				local color = DebuffTypeColor[dispelType]
				if type(color) == 'table' then
					debuff.border:SetVertexColor(color.r, color.g, color.b)
					debuff.border:Show()
				end
			end

			debuff:Show()
			total = total + 1
		else
			debuff:Hide()
		end
	end

	-- 施法条定位
	if frame.castBar then
		local _, _, relative, offsetX, offsetY = frame.castBar:GetPoint()
		frame.castBar.relative = frame.castBar.relative or relative
		frame.castBar.offsetX = frame.castBar.offsetX or offsetX
		frame.castBar.offsetY = frame.castBar.offsetY or offsetY
		frame.castBar:SetPoint(frame.castBar.relative, frame.castBar.offsetX, frame.castBar.offsetY - ((size or 21) + spac) * (ceil(total / rows) + row))
	end
end

-- 材质切换
function BC:file(file, dark)
	return 'Interface\\'.. ((dark or BC:getDB('global', 'dark')) and 'AddOns\\' .. addonName .. '\\Textures\\' .. file:gsub('.-([^\\/]-%.?[^%.\\/]*)$', '%1') or file)
end

-- 头像
function BC:portrait(unit)
	local frame = self[unit]
	if not frame or not frame.portrait then return end

	-- 修正默认头像没有对齐问题
	if unit:match('^party%d$') then
		if BC:getDB('global', 'dark') then
			frame.portrait:SetPoint('TOPLEFT', 6, -8)
		else
			frame.portrait:SetPoint('TOPLEFT', 7, -6)
		end
	elseif unit == 'focustarget' or unit == 'targettarget' then
		if BC:getDB('global', 'dark') then
			frame.portrait:SetSize(39, 39)
			frame.portrait:SetPoint('TOPLEFT', 2, -3.5)
		else
			frame.portrait:SetSize(38, 38)
			frame.portrait:SetPoint('TOPLEFT', 4, -4)
		end
	end

	local key = unit:gsub('%d', '')
	local index = self:getDB(key, 'portrait')
	if index == 1 and UnitIsPlayer(unit) then
		local coord = CLASS_ICON_TCOORDS[select(2, UnitClass(unit))]
		if type(coord) == 'table' then
			frame.portrait:SetTexCoord(unpack(coord))
			frame.portrait:SetTexture(self:file(self.portraitList[1]))
		end
	else
		frame.portrait:SetTexCoord(0, 1, 0, 1)
		if type(index) == 'number' and index > 1 and UnitIsPlayer(unit) then
			frame.portrait:SetTexture(self:file(self.portraitList[index], 1))
		else
			if UnitInVehicle('player') then
				if unit == 'pet' then
					SetPortraitTexture(frame.portrait, 'player')
				end
			else
				SetPortraitTexture(frame.portrait, unit)
			end
		end
	end
end
hooksecurefunc('UnitFramePortrait_Update', function(self)
	BC:portrait(self.unit)
end)

-- 设置暗黑模式
function BC:dark(unit)
	local frame = self[unit]
	if not frame then return end
	local dark = self:getDB('global', 'dark')
	local key = unit:gsub('%d', '')

	-- 边框材质
	local index
	if frame.borderTexture then
		if key == 'player' then
			index = self:getDB(key, 'border')

			-- 小队编号边框
			local indicator = self:file('CharacterFrame\\UI-CharacterFrame-GroupIndicator')
			PlayerFrameGroupIndicatorLeft:SetTexture(indicator)
			PlayerFrameGroupIndicatorRight:SetTexture(indicator)
			PlayerFrameGroupIndicatorMiddle:SetTexture(indicator)

		elseif key == 'target' or key == 'focus' then
			local classification = UnitClassification(key)
			if classification == 'elite' or classification == 'worldboss' then
				index = 4
			elseif classification == 'rareelite' then
				index = 3
			elseif classification == 'rare' then
				index = 2
			else
				index = 1
			end
		elseif key == 'pettarget' then
			index = 5
		elseif key == 'targettarget' or key == 'focustarget' or key == 'partytarget' then
			index = 6
		elseif key == 'pet' or key == 'party' or key == 'partypet'then
			index = 7
		end
		if index then frame.borderTexture:SetTexture(self:file(self.borderList[index])) end
	end

	-- 状态栏
	if frame.statusBar then
		if UnitIsPlayer(unit) and BC:getDB(key, 'statusBarClass') then
			local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
			frame.statusBar:SetVertexColor(color.r, color.g, color.b)
			BC.player.statusBar:Show()
		elseif unit == 'player' then
			BC.player.statusBar:Hide()
		else
			if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
				frame.statusBar:SetVertexColor(.5, .5, .5)
			else
				frame.statusBar:SetVertexColor(UnitSelectionColor(unit))
			end
		end
		frame.statusBar:SetTexture(self:file(self.barList[1]))

		-- 状态栏透明度
		if self:getDB(key, 'statusBarAlpha') then frame.statusBar:SetAlpha(self:getDB(key, 'statusBarAlpha')) end
	end

	if frame.healthbar then frame.healthbar:SetStatusBarTexture(self:file(self.barList[1])) end -- 生命条
	if frame.manabar then frame.manabar:SetStatusBarTexture(self:file(self.barList[1])) end -- 法力条

	-- PVP图标
	if frame.pvpIcon then
		local factionGroup = UnitFactionGroup(unit)
		if UnitIsPVPFreeForAll(unit) then
			frame.pvpIcon:SetTexture(self:file('TargetingFrame\\UI-PVP-FFA'))
		elseif factionGroup and factionGroup ~= 'Neutral' and UnitIsPVP(unit) then
			frame.pvpIcon:SetTexture(self:file('TargetingFrame\\UI-PVP-' .. factionGroup))
		end
	end

	-- 显示小图标(职业/种类)
	if frame.miniIcon and frame.miniIcon:IsShown() then
		frame.miniIcon:SetScript('OnMouseDown', function(self, button)
			if unit == 'player' then
				if type(self.click) == 'function' then self.click() end
			else
				local name, server = UnitName(unit)
				if server and server ~= '' then name = name .. '-' .. server end
				if IsShiftKeyDown() then
					local editbox = ChatEdit_ChooseBoxForSend()
					if not editbox:IsShown() then ChatEdit_ActivateChat(editbox) end
					editbox:SetFocus()
					editbox:SetText(name)
					editbox:HighlightText()
				elseif UnitIsPlayer(unit) then
					if IsAltKeyDown() then
						InviteUnit(name) -- 邀请
					elseif IsControlKeyDown() then
						if UnitFactionGroup('player') == UnitFactionGroup(unit) and not UnitIsUnit('player', unit) and CheckInteractDistance(unit, 2) then
							InitiateTrade(unit) -- 交易
						end
					elseif button == 'LeftButton' then
						if CheckInteractDistance(unit, 1) then
							InspectUnit(unit) -- 观察
						end
					elseif button == 'MiddleButton' then
						if UnitIsFriend('player', unit) and not UnitIsUnit('player', unit) then
							ChatFrame_SendTell(name) -- 密语
						end
					elseif button == 'RightButton' and UnitIsFriend('player', unit) then
						if CheckInteractDistance(unit, 4) and UnitIsFriend('player', unit) and not UnitIsUnit('player', unit) then
							FollowUnit(unit) -- 跟随
						end
					end
				end
			end
		end)
		frame.miniIcon.border:SetTexture(self:file('Minimap\\MiniMap-TrackingBorder'))

		if unit == 'player' then
			if type(frame.miniIcon.update) == 'function' then frame.miniIcon.update() end
		elseif UnitIsPlayer(unit) then
			local class, base = UnitClass(unit)
			local color = RAID_CLASS_COLORS[base]
			if color then
				frame.miniIcon.tip = {[1] = {L.playerClass .. ':', class, 1, 1, 0, color.r, color.g, color.b}}
				if UnitFactionGroup('player') == UnitFactionGroup(unit) and not UnitIsUnit('player', unit) then -- 同阵营
					frame.miniIcon.tip[2] = {L.altKeyDown .. ':', L.invite, 1, 1, 0, 0, 1, 0}
				end
				frame.miniIcon.tip[4] = {L.shiftKeyDown .. ':', L.copyName, 1, 1, 0, 0, 1, 0}
				frame.miniIcon.tip[5] = {L.leftButton .. ':', L.inspect, 1, 1, 0, 0, 1, 0}
				if UnitIsFriend('player', unit) and not UnitIsUnit('player', unit) then
					frame.miniIcon.tip[3] = {L.ctrlKeyDown .. ':', L.trade, 1, 1, 0, 0, 1, 0}
					frame.miniIcon.tip[6] = {L.middleButton .. ':', L.sendTell, 1, 1, 0, 0, 1, 0}
					frame.miniIcon.tip[7] = {L.rightButton .. ':', L.followUnit, 1, 1, 0, 0, 1, 0}
				end
			end
			local coord = CLASS_ICON_TCOORDS[base]
			if coord then
				frame.miniIcon.icon:SetTexture(self:file('TargetingFrame\\UI-Classes-Circles'))
				frame.miniIcon.icon:SetTexCoord(unpack(coord))
			end
		else
			local creature = UnitCreatureType(unit)
			if creature and L.creatureList[creature] then
				frame.miniIcon.tip = {[1] = {L.creatureType .. ':', creature, 1, 1, 0, 0, 1, 0}}
				frame.miniIcon.tip[2] = {L.shiftKeyDown .. ':', L.copyName, 1, 1, 0, 0, 1, 0}
				frame.miniIcon.icon:SetTexture(self.creatureList[L.creatureList[creature]])
				frame.miniIcon.icon:SetTexCoord(.05, .95, .05, .95)
			end
		end
	end
end
-- 法力条暗黑模式
hooksecurefunc('UnitFrameManaBar_UpdateType', function(self)
	BC:dark(self.unit)
end)

-- 数字单位
function BC:carry(value)
	if type(value) ~= 'number' then return 0 end
	local carry = self:getDB('global', 'carry')
	if carry == 1 then
		if value >= 1e6 then
			return ('%.1f'):format(value/1e6):gsub('%.?0+$', '') .. 'M'
		elseif value >= 1e4 then
			return ('%.1f'):format(value/1e3):gsub('%.?0+$', '') .. 'K'
		end
	elseif carry == 2 then
		if value >= 1e8 then
			return ('%.2f'):format(value / 1e8):gsub('%.?0+$', '') .. L.yi
		elseif value >= 1e4 then
			return ('%.2f'):format(value / 1e4):gsub('%.?0+$', '') .. L.wan
		end
	end
	return value
end

-- 预治疗
function BC:incomingHeals(unit)
	local heals = UnitGetIncomingHeals(unit)
	for _, v in pairs(self.unitList) do
		if UnitIsUnit(unit, v) and self[v]:IsShown() and self[v].incomingHealsBar then
			self[v].incomingHealsBar:SetValue(heals == 0 and 0 or (UnitHealth(unit) + heals) / UnitHealthMax(unit))
		end
	end
end

-- 数值
function BC:bar(bar)
	local unit = bar and bar.unit and bar.unit:gsub('-', '')
	if not unit or not UnitExists(unit) then return end
	local key = unit == 'vehicle' and 'player' or (UnitInVehicle('player') and unit == 'player' and 'pet' or unit:gsub('%d', ''))
	local font = self:getDB('global', 'valueFont')
	local size = self:getDB(key, 'valueFontSize')
	local flag = self:getDB('global', 'fontFlags')
	if not (key and font and size and flag) then return end

	local value = bar:GetValue()
	local _, valueMax = bar:GetMinMaxValues()

	local color
	if UnitInVehicle('player') and key == 'pet' or key == 'pettarget' or key == 'partytarget' or key == 'partypet' or bar:GetName() == 'PlayerFrameDruidBar' then
		bar.unit = key == 'pet' and 'player' or bar.unit
		if bar.powerType then
			bar.powerType = key == 'pet' and UnitPowerType('player') or bar.powerType
			value = UnitPower(bar.unit, bar.powerType)
			valueMax = UnitPowerMax(bar.unit, bar.powerType)
			color = PowerBarColor[bar.powerType]
		else
			value = UnitHealth(bar.unit)
			valueMax = UnitHealthMax(bar.unit)
		end
		bar:SetMinMaxValues(0, valueMax)
		bar:SetValue(value)
	end

	-- 条颜色
	local percent = valueMax == 0 and 0 or value / valueMax
	if not bar.powerType then
		if self:getDB(key, 'healthBarClass') and UnitIsPlayer(bar.unit) then -- 职业色
			color = RAID_CLASS_COLORS[select(2, UnitClass(bar.unit))]
		elseif self:getDB('global', 'healthBarColor') then -- 生命值百分比变化
			color = {r = 0, g = 1, b = 0}
			if percent > .5 then
				color.r = (1 - percent) * 2
			else
				color.r = 1
				color.g = percent * 2
			end
		end
	end
	if type(color) == 'table' then bar:SetStatusBarColor(color.r, color.g, color.b) end

	-- 数值文字
	if bar.MiddleText then
		bar.MiddleText:Hide()
		bar.MiddleText:SetFont(font, size, flag)
	end
	if bar.LeftText then
		bar.LeftText:Hide()
		bar.LeftText:SetFont(font, size, flag)
	end
	if bar.RightText then
		bar.RightText:Hide()
		bar.RightText:SetFont(font, size, flag)
	end
	if bar.SideText then
		bar.SideText:Hide()
		bar.SideText:SetFont(font, size, flag)
	end

	if UnitIsDeadOrGhost(unit) then return end

	local valueStyle = self:getDB(key, 'valueStyle')
	percent = floor(percent * 100 + .5) .. '%'

	bar:SetScript('OnEnter', function(self)
		if valueStyle > 6 and self.MiddleText then
			if valueStyle == 8 or valueStyle == 9 then
				bar.MiddleText:SetText(percent)
			else
				self.MiddleText:SetText(BC:carry(value) .. '/' .. BC:carry(valueMax))
			end
			self.MiddleText:Show()
		end
	end)

	bar:SetScript('OnLeave', function(self)
		if valueStyle > 6 and self.MiddleText then
			self.MiddleText:Hide()
		end
	end)

	if valueStyle == 1 then
		if bar.LeftText then
			bar.LeftText:SetText(value > 0 and (not bar.powerType or bar.powerType == 0) and percent or '')
			bar.LeftText:Show()
		end
		if bar.RightText then
			bar.RightText:SetText(self:carry(value))
			bar.RightText:Show()
		end
	elseif valueStyle == 2 then
		if bar.MiddleText then
			bar.MiddleText:SetText(percent)
			bar.MiddleText:Show()
		end
	elseif valueStyle == 3 then
		if bar.MiddleText then
			bar.MiddleText:SetText(self:carry(value))
			bar.MiddleText:Show()
		end
	elseif valueStyle == 4 then
		if bar.MiddleText then
			bar.MiddleText:SetText(self:carry(value) .. '/' .. self:carry(valueMax))
			bar.MiddleText:Show()
		end
	elseif valueStyle == 5 then
		if bar.MiddleText then
			bar.MiddleText:SetText(self:carry(value))
			bar.MiddleText:Show()
		end
		if bar.SideText then
			bar.SideText:SetText(percent)
			bar.SideText:Show()
		end
	elseif valueStyle == 6 then
		if bar.MiddleText then
			bar.MiddleText:SetText(self:carry(value) .. '/' .. self:carry(valueMax))
			bar.MiddleText:Show()
		end
		if bar.SideText then
			bar.SideText:SetText(percent)
			bar.SideText:Show()
		end
	elseif valueStyle == 7 then
		if bar.SideText then
			bar.SideText:SetText(percent)
			bar.SideText:Show()
		end
	elseif valueStyle == 8 then
		if bar.SideText then
			bar.SideText:SetText(self:carry(value))
			bar.SideText:Show()
		end
	elseif valueStyle == 9 then
		if bar.SideText then
			bar.SideText:SetText(self:carry(value) .. '/' .. self:carry(valueMax))
			bar.SideText:Show()
		end
	end
end
-- 条更新
hooksecurefunc('TextStatusBar_UpdateTextString', function(self)
	BC:bar(self)
end)

-- 更新
function BC:update(unit)
	local frame = unit == 'vehicle' and self.player or self[unit]
	if not frame then return end
	local key = unit:gsub('%d', '')

	-- 隐藏框架
	if self:getDB(key, 'hideFrame') or UnitInVehicle('player') and unit == 'pettarget' then
		frame:Hide()
		return
	end
	if key == 'pettarget' or key == 'partypet' or key == 'partytarget' or key == 'party' and (BC:getDB('party', 'raidShowParty') or not UnitInRaid('player')) then
		if UnitExists(unit) then
			frame:Show()
		else
			frame:Hide()
		end
	end
	if not UnitExists(unit) then return end

	-- 名字
	if frame.name then
		if self:getDB(key, 'hideName') then
			frame.name:Hide()
		else
			if key == 'pettarget' or key == 'partypet' or key == 'partytarget' then frame.name:SetText(UnitName(unit)) end
			local color
			if self:getDB('global', 'nameTextClassColor') and UnitIsPlayer(unit) then
				color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
			else
				color = { r = 1, g = .82, b = 0}
			end
			if type(color) == 'table' then frame.name:SetTextColor(color.r, color.g, color.b) end
			frame.name:SetFont(self:getDB('global', 'nameFont'), self:getDB(key, 'nameFontSize'), self:getDB('global', 'fontFlags'))
			frame.name:Show()
		end
	end

	self:dark(unit)
	self:portrait(unit)
	frame.manabar.powerType = frame.manabar.powerType or UnitPowerType(unit)
	self:bar(frame.manabar)
	self:bar(frame.healthbar)
end

-- 始初化
function BC:init(unit)
	if not unit then
		for _, unit in pairs(self.unitList) do
			self:init(unit)
		end
		return
	end

	local frame = self[unit]
	if not frame then return end
	local key = unit:gsub('%d', '')

	-- 初始定位
	local anchor = _G[self:getDB(key, 'anchor')]
	local relative = self:getDB(key, 'relative')
	local offsetX = self:getDB(key, 'offsetX')
	local offsetY = self:getDB(key, 'offsetY')
	if key ~= 'party' or unit == 'party1' then
		frame:ClearAllPoints()
		if anchor and type(relative) == 'string' then
			frame:SetPoint(relative, anchor, relative, offsetX, offsetY)
		else
			frame:SetPoint(relative, offsetX, offsetY)
		end
	end
	-- 拖动
	self:drag(frame, key == 'party' and unit ~= 'party1' and PartyMemberFrame1, self:getDB(key, 'drag'), true, true, function(self)
		local _, _, relative, offsetX, offsetY = self:GetPoint()
		-- 有父对像
		if anchor then
			offsetX = self:GetLeft() - anchor:GetLeft()
			offsetY = self:GetTop() - anchor:GetTop()
			relative = 'TOPLEFT'
		end
		if relative then BC:setDB(key, 'relative', relative) end
		if offsetX then BC:setDB(key, 'offsetX', floor(offsetX)) end
		if offsetY then BC:setDB(key, 'offsetY', floor(offsetY)) end
	end)

	-- 头像上显示战斗信息
	local registered = frame:IsEventRegistered('UNIT_COMBAT')
	if self:getDB(key, 'portraitCombat') then
		if unit == 'player' or unit == 'pet' then
			if not registered then frame:RegisterEvent('UNIT_COMBAT') end
		else
			if not frame.portraitCombat then
				frame.portraitCombat = CreateFrame('Frame', nil, frame)
				frame.portraitCombat:SetFrameLevel(frame:GetFrameLevel() + 2)
			end
			if not frame.portraitCombatText then
				frame.portraitCombatText = frame.portraitCombat:CreateFontString(nil, 'OVERLAY', 'NumberFontNormalHuge')
				frame.portraitCombatText:SetPoint('CENTER', frame.portrait, 'CENTER')
			end
			CombatFeedback_Initialize(frame.portraitCombat, frame.portraitCombatText, frame.portrait:GetWidth() / 2)

			frame.portraitCombat:RegisterEvent('UNIT_COMBAT')
			frame.portraitCombat:SetScript('OnEvent', function(self, event, ...)
				if event == 'UNIT_COMBAT' then
					local arg1, arg2, arg3, arg4, arg5 = ...
					if unit == arg1 then
						CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5)
					end
				end
			end)
			frame.portraitCombat:SetScript('OnUpdate', function(self, elapsed)
				if self and self.feedbackStartTime then CombatFeedback_OnUpdate(self, elapsed) end
			end)
		end
	else
		if unit == 'player' or unit == 'pet' then
			if registered then frame:UnregisterEvent('UNIT_COMBAT') end
		else
			if frame.portraitCombat then
				if frame.portraitCombat:IsEventRegistered('UNIT_COMBAT') then
					frame.portraitCombat:UnregisterAllEvents()
				end
				frame.portraitCombat:SetScript('OnEvent', nil)
				frame.portraitCombat:SetScript('OnUpdate', nil)
			end
			if frame.portraitCombatText and frame.portraitCombatText:IsShown() then
				frame.portraitCombatText:Hide()
			end
		end
	end

	-- 显示小图标(职业/种类)
	if self:getDB(key, 'miniIcon') then
		if not frame.miniIcon then
			frame.miniIcon = CreateFrame('Button', nil, frame)
			frame.miniIcon:SetPoint('TOPLEFT', 114, 0)
			frame.miniIcon:SetSize(28, 28)
			frame.miniIcon:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')

			frame.miniIcon.border = frame.miniIcon:CreateTexture(nil, 'OVERLAY')
			frame.miniIcon.border:SetPoint('CENTER', 9, -9)
			frame.miniIcon.border:SetSize(40, 40)
			frame.miniIcon.border:SetAlpha(.8)

			frame.miniIcon.icon = frame.miniIcon:CreateTexture(nil, 'ARTWORK')
			frame.miniIcon.icon:SetPoint('CENTER', .5, 0)
			frame.miniIcon.icon:SetTexCoord(.06, .94, .06, .94)
			frame.miniIcon.icon:SetSize(14, 14)
			frame.miniIcon.icon:SetAlpha(.7)

			frame.miniIcon:SetScript('OnEnter', function(self)
				if InCombatLockdown() then return end -- 战斗中
				GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
				if type(self.tip) == 'table' then
					for _, val in pairs(self.tip) do
						GameTooltip:AddDoubleLine(unpack(val))
					end
					GameTooltip:Show()
				end
			end)

			frame.miniIcon:SetScript('OnLeave', function()
				GameTooltip:Hide()
			end)
		end

		frame.miniIcon:Show()
	elseif frame.miniIcon then
		frame.miniIcon:Hide()
	end

	-- 缩放
	local scale = self:getDB(key, 'scale')
	if type(scale) == 'number' then frame:SetScale(scale) end

	-- 预治疗
	if frame.healthbar then
		if not frame.incomingHealsBar then
			frame.incomingHealsBar = CreateFrame('StatusBar', nil, frame.healthbar)
			frame.incomingHealsBar:SetSize(frame.healthbar:GetWidth(), frame.healthbar:GetHeight())
			frame.incomingHealsBar:SetPoint('LEFT')
			frame.incomingHealsBar:SetFrameLevel(0)
			frame.incomingHealsBar:SetMinMaxValues(0, 1)
			frame.incomingHealsBar:SetValue(0)
			frame.incomingHealsBar:SetStatusBarTexture(self.texture .. 'UI-IncomingHealsBar')
		end
		if self:getDB('global', 'incomingHeals') then
			frame.incomingHealsBar:Show()
			self:RegisterEvent('UNIT_HEAL_PREDICTION')
		else
			frame.incomingHealsBar:Hide()
			self:UnregisterEvent('UNIT_HEAL_PREDICTION')
		end
	end

	-- 战斗状态边框红光
	if frame.flash then
		hooksecurefunc(frame.flash, 'Hide', function(self)
			if BC:getDB(key, 'combatFlash') and UnitAffectingCombat(unit) then
				self:SetVertexColor(1, 0, 0)
				self:SetAlpha(.7)
				self:Show()
			else
				self:SetAlpha(0)
			end
		end)
	end

	-- PVP图标
	if frame.pvpIcon then
		hooksecurefunc(frame.pvpIcon, 'Show', function()
			BC:dark(unit)
		end)
	end

	if type(frame.init) == 'function' then frame.init() end
	self:update(unit)
end

for _, event in pairs({
	'PLAYER_ENTERING_WORLD', -- 进入世界
	'ZONE_CHANGED', -- 区域更改
	'ZONE_CHANGED_NEW_AREA', -- 传送
	'UNIT_TARGET', -- 目标切换
	-- 'UNIT_FLAGS', -- 战斗状态
}) do
	BC:RegisterEvent(event)
end
BC:SetScript('OnEvent', function(self, event, unit, ...)
	if type(unit) == 'string' then unit = unit:gsub('-', '') end
	if event == 'PLAYER_ENTERING_WORLD' then
		self:init()
	elseif event == 'ZONE_CHANGED' or event == 'ZONE_CHANGED_NEW_AREA' then
		-- PVP环境自动设置TAB选择敌对玩家
		if self:getDB('global', 'autoTab') then
			local _, instance = IsInInstance()
			if instance == 'arena' or instance == 'pvp' then
				SetBinding('TAB', 'TARGETNEARESTENEMYPLAYER', 1)
			else
				SetBinding('TAB', 'TARGETNEARESTENEMY', 1)
			end
		end

		-- 进入达拉然自动关闭姓名板
		if self:getDB('global', 'autoNameplate') then
			local cache = self:getDB('cache') or {}
			if GetZoneText() == L.dalaran then
				if self:getDB('cache', 'nameplateShowFriends') == nil then
					self:setDB('cache', 'nameplateShowFriends', GetCVar('nameplateShowFriends'))
				end
				if self:getDB('cache', 'nameplateShowEnemies') == nil then
					self:setDB('cache', 'nameplateShowEnemies', GetCVar('nameplateShowEnemies'))
				end
				SetCVar('nameplateShowFriends', '0')
				SetCVar('nameplateShowEnemies', '0')
			else
				if self:getDB('cache', 'nameplateShowFriends') then
					SetCVar('nameplateShowFriends', self:getDB('cache', 'nameplateShowFriends'))
					self:setDB('cache', 'nameplateShowFriends', nil)
				end
				if self:getDB('cache', 'nameplateShowEnemies') then
					SetCVar('nameplateShowEnemies', self:getDB('cache', 'nameplateShowEnemies'))
					self:setDB('cache', 'nameplateShowEnemies', nil)
				end
			end
		end
	elseif event == 'UNIT_TARGET' then
		self:update((unit == 'player' and 'target' or unit) .. 'target')
	elseif event == 'UNIT_HEAL_PREDICTION' then -- 治疗预测
		self:incomingHeals(unit)
	end
end)
