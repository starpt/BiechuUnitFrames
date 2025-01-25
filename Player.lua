local addonName = ...
local BC = _G[addonName]
local L = _G[addonName .. 'Locale']
local dark = BC:getDB('global', 'dark')
local frame = CreateFrame('Frame')

BC.player = PlayerFrame
BC.player.name:SetPoint('TOP', 50, -26) -- 名字
BC.player.borderTexture = PlayerFrameTexture -- 边框
BC.player.pvpIcon = PlayerPVPIcon -- PVP图标

-- 战斗中边框发红光
BC.player.flash = PlayerFrameFlash
hooksecurefunc(BC.player.flash, 'Hide', function(self)
	if BC:getDB('player', 'combatFlash') and UnitAffectingCombat('player') then
		self:SetVertexColor(1, 0, 0)
		self:SetAlpha(.7)
		if not self:IsVisible() then self:Show() end
	else
		self:SetAlpha(0)
	end
end)

-- 小队编号
PlayerFrameGroupIndicatorText:SetFont(STANDARD_TEXT_FONT, 12)
PlayerFrameGroupIndicatorText:SetPoint('LEFT', 20, -3)
PlayerFrameGroupIndicator:SetPoint('TOPLEFT', 97, -4.5)
hooksecurefunc('PlayerFrame_UpdateGroupIndicator', function()
	if PlayerFrameGroupIndicator:IsVisible() and BC:getDB('player', 'hidePartyNumber') then
		PlayerFrameGroupIndicator:Hide()
	end
end)

-- 状态栏
BC.player.statusBar = BC.player:CreateTexture(nil, 'BACKGROUND')
BC.player.statusBar:SetSize(119, 19)
BC.player.statusBar:SetPoint('TOPLEFT', BC.player, 105, -22)

-- 等级
PlayerLevelText:SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')
hooksecurefunc('PlayerFrame_UpdateLevelTextAnchor', function()
	PlayerLevelText:SetPoint('CENTER', -62.5, -16.5)
end)

-- 体力
BC.player.healthbar.MiddleText = PlayerFrameHealthBarText
BC.player.healthbar.LeftText:SetPoint('LEFT', BC.player.healthbar, 4, -.5)
BC.player.healthbar.RightText:SetPoint('RIGHT', BC.player.healthbar, -.5, -.5)
BC.player.healthbar.SideText = BC.player.healthbar:CreateFontString()
BC.player.healthbar.SideText:SetPoint('LEFT', BC.player.healthbar, 'RIGHT', 3, -.5)

-- 法力
BC.player.manabar.MiddleText = PlayerFrameManaBarText
BC.player.manabar.MiddleText:SetPoint('CENTER', BC.player.manabar, 0, -.5)
BC.player.manabar.LeftText:SetPoint('LEFT', BC.player.manabar, 4, -.5)
BC.player.manabar.RightText:SetPoint('RIGHT', BC.player.manabar, -.5, -.5)
BC.player.manabar.SideText = BC.player.manabar:CreateFontString()
BC.player.manabar.SideText:SetPoint('LEFT', BC.player.manabar, 'RIGHT', 3, -.5)

-- 法力/能量恢复
if not BC.player.manabar.spark and BC.class ~= 'WARRIOR' then
	BC.player.manabar.spark = CreateFrame('StatusBar', nil, BC.player.manabar)
	-- BC.player.manabar.spark:SetAllPoints(BC.player.manabar)
	BC.player.manabar.spark:SetSize(BC.player.manabar:GetSize())
	BC.player.manabar.spark:SetPoint('CENTER')
	BC.player.manabar.spark.point = BC.player.manabar.spark:CreateTexture()
	BC.player.manabar.spark.point:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
	BC.player.manabar.spark.point:SetBlendMode('ADD')
	BC.player.manabar.spark.point:SetSize(28, 28)
end

-- 装备小图标
function frame:equip()
	if type(ItemRack) ~= 'table' or type(ItemRackUser) ~= 'table' or type(ItemRackUser.Sets) ~= 'table' then return end

	local sets = {}
	for i in pairs(ItemRackUser.Sets) do
		if not i:match('^~') then
			local show = true
			for _, k in pairs(ItemRackUser.Hidden) do
				if i == k then
					show = nil
					break
				end
			end
			if show then table.insert(sets, i) end
		end
	end
	table.sort(sets)

	for i = 1, 6 do -- 最多6个装备小图标
		local equip = _G['EquipSetFrame' .. i]
		if not equip then
			equip = CreateFrame('Button', 'EquipSetFrame' .. i, BC.player)
			equip:SetFrameLevel(3)
			equip:SetSize(18, 18)
			equip:SetPoint('TOPLEFT', 96 + 18 * i, -3.5)
			equip:SetHighlightTexture('Interface\\Buttons\\OldButtonHilight-Square')
			equip.border = equip:CreateTexture(nil, 'BORDER')
			equip.border:SetSize(24, 24)
			equip.border:SetPoint('CENTER')
			equip.border:SetTexture(BC.texture .. 'UI-SquareButton-Disabled')
			equip.icon = equip:CreateTexture()
			equip.icon:SetSize(14, 14)
			equip.icon:SetPoint('CENTER')
			equip.icon:SetTexCoord(.05, .95, .05, .95)
		end
		equip:Hide()
	end

	for i, k in pairs(sets) do
		local equip = _G['EquipSetFrame' .. i]
		if equip and BC:getDB('player', 'equipmentIcon') then
			if ItemRackUser.CurrentSet == k then
				equip:SetAlpha(1)
			else
				equip:SetAlpha(.4)
			end
			if dark then
				equip.border:SetVertexColor(0, 0, 0)
			else
				equip.border:SetVertexColor(1, 1, 1)
			end
			equip.id = i
			equip.name = k
			equip.icon:SetTexture(ItemRackUser.Sets[k].icon)
			equip:Show()

			-- 鼠标悬停
			equip:SetScript('OnEnter', function(self)
				if InCombatLockdown() then return end -- 战斗中
				self:SetAlpha(1)
				GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
				GameTooltip:AddDoubleLine(L.clickEquipment .. ':', self.name, 1, 1, 0, 0, 1, 0)
				GameTooltip:AddDoubleLine(L.shiftKeyDown .. ':', L.saveEquipment, 1, 1, 0, 0, 1, 0)
				GameTooltip:Show()
			end)

			-- 鼠标离开
			equip:SetScript('OnLeave', function(self)
				if self.name == ItemRackUser.CurrentSet then
					self:SetAlpha(1)
				else
					self:SetAlpha(.4)
				end
				GameTooltip:Hide()
			end)

			-- 鼠标点击
			equip:SetScript('OnMouseDown', function(self)
				if IsShiftKeyDown() then -- 保存方案
					BC:comfing(L.confirmEquipmentSet:format(self.name), function()
						for i = 0, 19 do
							ItemRackUser.Sets[self.name].equip[i] = ItemRack.GetID(i)
						end
						ItemRack.UpdateCurrentSet()
					end)
				else
					for i = 1, 6 do -- 最多6个装备小图标
						_G['EquipSetFrame' .. i]:SetAlpha(.4)
					end
					ItemRack.EquipSet(self.name)
				end
			end)
		end
	end
end

-- 天赋小图标(点击切换天赋)
function frame:talent()
	if not BC.player.miniIcon or not BC.player.miniIcon:IsShown() then return end

	BC.player.miniIcon:SetPoint('TOPLEFT', 88, 1)
	BC.player.miniIcon:SetFrameLevel(4)
	if dark then BC.player.miniIcon.border:SetAlpha(.9) end

	local active = GetActiveTalentGroup('player', false) -- 当前天赋
	local passive = 3 - active -- 将切换天赋
	local talent = {}
	local text
	for i = 1, MAX_TALENT_TABS do
		local _, name, _, icon, point = GetTalentTabInfo(i, 'player', false, active)
		text = (text and text .. '/' or '') .. point
		if point > 0 and (type(talent[active]) ~= 'table' or talent[active].point < point) then
			talent[active] = {
				name = name,
				icon = icon,
				point = point,
			}
		end
		_, name, _, _, point = GetTalentTabInfo(i, 'player', false, passive)
		if point > 0 and (type(talent[passive]) ~= 'table' or talent[passive].point < point) then
			talent[passive] = {
				name = name,
				point = point,
			}
		end
	end

	if type(talent[active]) == 'table' and type(talent[active].name) == 'string' then
		BC.player.miniIcon.tip = {[1] = {(active == 1 and L.primary or L.secondary) .. '(' .. talent[active].name ..'):', text, 1, 1, 0, 0, 1, 0}}
		BC.player.miniIcon.icon:SetTexture(talent[active].icon)
	else
		BC.player.miniIcon.tip = {[1] = {(active == 1 and L.primary or L.secondary)  .. ':', text, 1, 1, 0, 1, 0, 0}}
		BC.player.miniIcon.icon:SetTexture('Interface\\Icons\\INV_Misc_QuestionMark')
	end

	BC.player.miniIcon.tip[2] = {L.shiftKeyDown .. ':', L.nude, 1, 1, 0, 0, 1, 0} -- Shift 一键脱装

	if GetNumTalentGroups('player', false) > 1 then -- 可以切换天赋(开启双天赋)
		BC.player.miniIcon.tip[3] = {L.click .. ':', L.switch .. (active == 1 and L.secondary or L.primary), 1, 1, 0, 0, 1, 0}
		if BC:getDB('player', 'autoTalentEquip') and type(talent[passive]) == 'table' and type(talent[passive].name) == 'string' then
			BC.player.miniIcon.tip[4] = {L.switchAfter .. ':', talent[passive].name, 1, 1, 0, 0, 1, 0} -- 切换天赋后
		end
	end
	if type(BC.player.talentCallBack) == 'function' then BC.player:talentCallBack() end -- 切换天赋后回调

	-- 小图标点击
	BC.player.miniIcon.click = function()
		if IsShiftKeyDown() then -- 按住Shift 一键脱光
			EQUIPMENTMANAGER_BAGSLOTS = {} -- 背包空间缓存
			for _, i in pairs({16, 17, 5, 7, 1, 3, 9, 10, 6, 8}) do
				local durability = GetInventoryItemDurability(i)
				if durability and durability > 0 then -- 有耐久度
					for	bag = BACKPACK_CONTAINER, NUM_BAG_FRAMES do
						local free, family = C_Container.GetContainerNumFreeSlots(bag)
						if free > 0 and family == 0 then -- 有空位 且是背包
							EQUIPMENTMANAGER_BAGSLOTS[bag] = EQUIPMENTMANAGER_BAGSLOTS[bag] or {}
							for slot = 1, C_Container.GetContainerNumSlots(bag) do
								if not C_Container.GetContainerItemID(bag, slot) and not EQUIPMENTMANAGER_BAGSLOTS[bag][slot] then -- 有空位
									PickupInventoryItem(i)
									if bag == 0 then
										PutItemInBackpack()
									else
										PutItemInBag(C_Container.ContainerIDToInventoryID(bag))
									end
									EQUIPMENTMANAGER_BAGSLOTS[bag][slot] = true
									break
								end
							end
						end
					end
				end
			end
			for i = 1, 6 do -- 最多6个装备小图标
				_G['EquipSetFrame' .. i]:SetAlpha(.4)
			end
			ItemRackUser.CurrentSet = nil
		else
			SetActiveTalentGroup(passive) -- 切换天赋
			BC.player.talentCallBack = function() -- 切换天赋回调
				BC.player.miniIcon:Hide()
				BC.player.miniIcon:Show()
				if BC:getDB('player', 'autoTalentEquip') and talent[passive] == 'table' and type(talent[passive].name) == 'string' then
					ItemRack.EquipSet(talent[passive].name)
				end
				BC.player.talentCallBack = nil
			end
		end
	end
end

-- 德鲁伊法力条
if BC.class == 'DRUID' and not BC.player.druid then
	local windth, height = BC.player.manabar:GetSize()
	BC.player.druid = CreateFrame('Frame', 'PlayerFrameDruid', BC.player)
	BC.player.druid:SetSize(windth + 6, height + 4)
	BC.player.druid:SetPoint('TOPRIGHT', -3, -62)
	BC.player.druid:SetFrameLevel(3)

	BC.player.druid.border = BC.player.druid:CreateTexture(nil, 'OVERLAY')
	BC.player.druid.border:SetAllPoints(BC.player.druid)

	BC.player.druidBar = CreateFrame('StatusBar', 'PlayerFrameDruidBar', BC.player.druid)
	BC.player.druidBar.unit = 'player'
	BC.player.druidBar.powerType = 0
	BC.player.druidBar:SetSize(windth - 1, height - 4)
	BC.player.druidBar:SetPoint('LEFT', 3.5 , 0)
	BC.player.druidBar:SetFrameLevel(3)

	BC.player.druidBar.MiddleText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.MiddleText:SetPoint('CENTER', -.5, -1)
	BC.player.druidBar.LeftText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.LeftText:SetPoint('LEFT', 6, -1)
	BC.player.druidBar.RightText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.RightText:SetPoint('RIGHT', -4.5, -1)
	BC.player.druidBar.SideText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.SideText:SetPoint('LEFT', BC.player.druidBar, 'RIGHT', 2.5, -1)

	BC.player.druidBar.spark = CreateFrame('StatusBar', nil, BC.player.druidBar)
	BC.player.druidBar.spark:SetAllPoints(BC.player.druidBar)
	BC.player.druidBar.spark:SetFrameLevel(5)
	BC.player.druidBar.spark.point = BC.player.druidBar.spark:CreateTexture()
	BC.player.druidBar.spark.point:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
	BC.player.druidBar.spark.point:SetBlendMode('ADD')
	BC.player.druidBar.spark.point:SetSize(28, 28)
end

-- 显示法力/能量恢复提示
function frame:spark(bar, now)
	if not bar.spark then return end
	local powerMax = UnitPower('player', bar.powerType) >= UnitPowerMax('player', bar.powerType)
	if not BC:getDB('player', 'powerSpark')
		or UnitIsDeadOrGhost('player') -- 死亡
		or bar.powerType ~= 0 and bar.powerType ~= 3 -- 非法力和能量
		or bar.powerType == 0 and powerMax -- 满法力
		or powerMax and not IsStealthed() and not UnitCanAttack('player', 'target') -- 满能量只在潜行或者有可攻击目标才显示
	then
		bar.spark:Hide()
		return
	end
	bar.spark:Show()
	local interval = self.interval or 2 -- 恢复间隔
	if bar.powerType == 0 then
		local manaTime = BC:getDB('cache', 'manaTime')
		if type(self.waitTime) == 'number' and self.waitTime > now then
			bar.spark.point:SetPoint('CENTER', bar.spark, 'LEFT', bar.spark:GetWidth() * (self.waitTime - now) / 5, 0)
		elseif type(manaTime) == 'number' and now > manaTime then
			bar.spark.point:SetPoint('CENTER', bar.spark, 'LEFT', bar.spark:GetWidth() * (mod(now - manaTime, interval) / interval), 0)
		else
			bar.spark:Hide()
		end
	else
		local energyTime = BC:getDB('cache', 'energyTime')
		if type(energyTime) == 'number' and now > energyTime then
			bar.spark.point:SetPoint('CENTER', bar.spark, 'LEFT', bar.spark:GetWidth() * (mod(now - energyTime, interval) / interval), 0)
		end
	end
end

BC.player.init = function()
	PlayerFrame_UpdateGroupIndicator() -- 小队编号
	frame:talent()
	frame:equip()
	if type(ItemRack) == 'table' then
		hooksecurefunc(ItemRack, 'FireItemRackEvent', frame.equip)
		hooksecurefunc(ItemRack, 'AddHidden', frame.equip)
		hooksecurefunc(ItemRack, 'RemoveHidden', frame.equip)
	end

	-- 德鲁伊法力/能量条
	if BC.player.druid then
		BC.player.druidBar:SetStatusBarTexture(BC:file(BC.barList[1]))
		BC.player.druid.border:SetTexture(BC:file(BC.barList[2]))
	end
end

-- 宠物
BC.pet = PetFrame
PetFrameFlash:SetAlpha(0)

-- 快乐值图标
local point, relativeTo, relativePoint, offsetX, offsetY = PetFrameHappiness:GetPoint()
PetFrameHappiness:SetPoint(point, relativeTo, relativePoint, offsetX - 4, offsetY + 10)
PetFrameHappiness:SetSize(20, 20)

BC.pet.borderTexture = PetFrameTexture -- 边框
BC.pet.name:SetPoint('BOTTOMLEFT', 46, 40) -- 名字

-- 体力
BC.pet.healthbar:SetPoint('TOPLEFT', 47, -13)
BC.pet.healthbar.MiddleText = PetFrameHealthBarText
BC.pet.healthbar.MiddleText:SetPoint('TOP', BC.pet.healthbar, 0, 1.5)
BC.pet.healthbar.LeftText:SetPoint('TOPLEFT', BC.pet.healthbar, 1, 1.5)
BC.pet.healthbar.RightText:SetPoint('TOPRIGHT', BC.pet.healthbar, -1, 1.5)

-- 法力
BC.pet.manabar:SetPoint('TOPLEFT', 47, -21)
BC.pet.manabar.MiddleText = PetFrameManaBarText
BC.pet.manabar.MiddleText:SetPoint('TOP', BC.pet.manabar, 0, 1.5)
BC.pet.manabar.LeftText:SetPoint('TOPLEFT', BC.pet.manabar, 1, 1.5)
BC.pet.manabar.RightText:SetPoint('TOPRIGHT', BC.pet.manabar, -1, 1.5)

hooksecurefunc('PetFrame_Update', function()
	BC:dark('pet')
end)

-- 宠物的目标
BC.pettarget = CreateFrame('Button', 'PetFrameToT', PetFrame, 'SecureUnitButtonTemplate')
BC.pettarget:SetSize(128, 64)
BC.pettarget:SetFrameLevel(5)
BC.pettarget.unit = 'pettarget'

-- 背景边框
BC.pettarget.borderTexture = BC.pettarget:CreateTexture(nil, 'ARTWORK')
BC.pettarget.borderTexture:SetTexCoord(1, 0, 1, 1, 0, 0, 0, 1) -- 水平反转
BC.pettarget.borderTexture:SetPoint('TOP')

-- 名字
BC.pettarget.name = BC.pettarget:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
BC.pettarget.name:SetPoint('TOPRIGHT', -34, -39)

-- 头像
BC.pettarget.portrait = BC.pettarget:CreateTexture(nil, 'BORDER')
BC.pettarget.portrait:SetSize(32, 32)
BC.pettarget.portrait:SetPoint('TOPRIGHT', -8, -8)

	-- 鼠标提示
BC.pettarget:SetScript('OnEnter', function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetUnit(self.unit)
	GameTooltip:Show()
end)
BC.pettarget:SetScript('OnLeave', function(self)
	GameTooltip:Hide()
end)

SecureUnitButton_OnLoad(BC.pettarget, 'pettarget') -- 点击选择

-- 体力
BC.pettarget.healthbar = CreateFrame('StatusBar', nil, BC.pettarget)
BC.pettarget.healthbar:SetSize(70, 7)
BC.pettarget.healthbar:SetPoint('TOPLEFT', 12, -21)
BC.pettarget.healthbar:SetFrameLevel(1)
BC.pettarget.healthbar.MiddleText = BC.pettarget:CreateFontString()
BC.pettarget.healthbar.MiddleText:SetPoint('CENTER', BC.pettarget.healthbar, 0, 1)
BC.pettarget.healthbar.SideText = BC.pettarget:CreateFontString()
BC.pettarget.healthbar.SideText:SetPoint('RIGHT', BC.pettarget.healthbar, 'LEFT', 0, 1)
BC.pettarget.healthbar.unit = 'pettarget'

-- 法力
BC.pettarget.manabar = CreateFrame('StatusBar', nil, BC.pettarget)
BC.pettarget.manabar:SetSize(70, 7)
BC.pettarget.manabar:SetPoint('TOPLEFT', 12, -29)
BC.pettarget.manabar:SetFrameLevel(1)
BC.pettarget.manabar.MiddleText = BC.pettarget:CreateFontString()
BC.pettarget.manabar.MiddleText:SetPoint('CENTER', BC.pettarget.manabar, 0, -1)
BC.pettarget.manabar.SideText = BC.pettarget:CreateFontString()
BC.pettarget.manabar.SideText:SetPoint('RIGHT', BC.pettarget.manabar, 'LEFT', 0, -1)
BC.pettarget.manabar.unit = 'pettarget'

for _, event in pairs({
	'PLAYER_ENTERING_WORLD', -- 进入世界
	'PLAYER_REGEN_DISABLED', -- 开始战斗
	'PLAYER_REGEN_ENABLED', -- 结束战斗
	'ACTIVE_TALENT_GROUP_CHANGED', -- 天赋切换
	'PLAYER_TALENT_UPDATE', -- 天赋点更新
	'UNIT_PET', -- 宠物变化
	'COMBAT_LOG_EVENT_UNFILTERED', -- 战斗记录
	'UNIT_POWER_UPDATE', -- 法力/怒气/能量等 更新
}) do
	frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(self, event, unit)
	local now = GetTime()
	if event == 'PLAYER_ENTERING_WORLD' then
		if UnitPowerType('player') == 0 or BC.class == 'DRUID' then -- 法力
			self.lastMana = UnitPower('player', 0)
			local manaTime = BC:getDB('cache', 'manaTime')
			if type(manaTime) ~= 'number' or manaTime > now then BC:setDB('cache', 'manaTime', now) end
		end
		if UnitPowerType('player') == 3 or BC.class == 'DRUID' then -- 能量
			self.lastEnergy = UnitPower('player', 3)
			local energyTime = BC:getDB('cache', 'energyTime')
			if type(energyTime) ~= 'number' or energyTime > now then BC:setDB('cache', 'energyTime', now) end
		end
	elseif event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_REGEN_ENABLED' then
		BC.player.flash:Hide()
		BC:setDB('cache', 'threat', nil) -- 清空仇恨列表
	elseif event == 'ACTIVE_TALENT_GROUP_CHANGED' or event == 'PLAYER_TALENT_UPDATE' then
		self:talent()
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local guid = UnitGUID('player')
		local _, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo()
		if destGUID == guid then -- 施法目标自己
			if spellId == 13750 then -- 冲动, 加速能量恢复速度
				if subevent == 'SPELL_AURA_APPLIED' then -- 冲动 开始
					self.interval = 1
				elseif subevent == 'SPELL_AURA_REMOVED' then -- 冲动 结束
					self.interval = nil
				end
			elseif spellId == 29166 then -- 忽视 激活期间 5秒回蓝等待
				if subevent == 'SPELL_AURA_APPLIED' then -- 激活 开始
					self.ignore = true
				elseif subevent == 'SPELL_AURA_REMOVED' then -- 激活 结束
					self.ignore = nil
				end
			elseif subevent == 'SPELL_ENERGIZE' then -- 法力药水恢复 生命分流 跳过
				self.skip = true
			end
		end
	elseif event == 'UNIT_POWER_UPDATE' then
		if unit == 'player' then
			if UnitPowerType('player') == 0 or BC.class == 'DRUID' then -- 法力
				local mana = UnitPower('player', 0)
				if not self.ignore and type(self.lastMana) == 'number' and mana < self.lastMana then
					self.waitTime = now + 5
				elseif type(self.lastMana) == 'number' and mana > self.lastMana then -- 法力增加
					if self.skip then -- 跳过非2秒回蓝, 比如 生命分流
						self.skip = nil
					else
						self.waitTime = nil
						BC:setDB('cache', 'manaTime', now)
					end
				end
				self.lastMana = mana
			end

			if UnitPowerType('player') == 3 or BC.class == 'DRUID' then -- 能量
				local energy = UnitPower('player', 3)
				if type(self.lastEnergy) ~= 'number' or energy > self.lastEnergy then
					BC:setDB('cache', 'energyTime', now)
				end
				self.lastEnergy = UnitPower('player', 3)
			end
		end
	elseif event == 'UNIT_PET' then
		if unit == 'player' then BC:update('pet') end
	end
end)

frame:SetScript('OnUpdate', function(self)
	local now = GetTime()
	if self.rate and now < self.rate then return end
	self.rate = now + .02 -- 刷新率

	local powerType = UnitPowerType('player')
	if BC.player.druid then
		if powerType ~= 0 and BC:getDB('player', 'druidBar') then
			BC.player.druid:Show()
			BC:bar(BC.player.druidBar)
			self:spark(BC.player.druidBar, now)
		else
			BC.player.druid:Hide()
		end
	end

	self:spark(BC.player.manabar, now)

	if UnitExists('pettarget') then
		BC:bar(BC.pettarget.healthbar)
		BC:bar(BC.pettarget.manabar)
	elseif BC.pettarget:GetAlpha() > 0 then
		BC.pettarget:SetAlpha(0)
	end
end)