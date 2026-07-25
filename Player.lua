local addonName = ...
local BC = _G[addonName]
local L = _G[addonName .. 'Locale']
local dark = BC:getDB('global', 'dark')
local frame = CreateFrame('Frame')

BC.player = PlayerFrame

-- 边框
BC.player.borderTexture = PlayerFrameTexture
BC.player.borderTexture:SetTexCoord(1, 0.09375, 0, 0.78125)
BC.player.borderTexture:SetSize(232, 100)

-- 等级
PlayerLevelText:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE')
PlayerLevelText:SetPoint('CENTER', -63, -16)

-- PVP图标
BC.player.pvpIcon = PlayerPVPIcon
BC.player.pvpIcon:SetPoint('TOPLEFT', 18, -20)
PlayerPVPTimerText:SetDrawLayer('OVERLAY')
PlayerPVPTimerText:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE')
PlayerPVPTimerText:SetPoint('CENTER', BC.player.pvpIcon, 'TOPLEFT', 21, -19)

BC.player.portrait:SetPoint('TOPLEFT', 42, -12) -- 头像
BC.player.flash = PlayerFrameFlash -- 战斗中边框发红光
PlayerHitIndicator:SetPoint('CENTER', BC.player.portrait) -- 头像战斗信息
PlayerFrameBackground:SetPoint('TOPLEFT', 106, -22) -- 背景
PlayerStatusTexture:SetPoint('TOPLEFT', 35, -8) -- 状态栏背景 (休息的时候闪动)
PlayerRestIcon:SetPoint('TOPLEFT', 37, -49) -- 休息图标
PlayerLeaderIcon:SetPoint('TOPLEFT', 44, -10) -- 队长图标
PlayerMasterIcon:SetPoint('TOPLEFT', 80, -10) -- 分配图标
PlayerAttackBackground:SetPoint('TOPLEFT', 37, -50) -- 战斗状态背景

-- 状态栏
BC.player.statusBar = BC.player:CreateTexture(nil, 'BACKGROUND')
BC.player.statusBar:SetSize(119, 19)
BC.player.statusBar:SetPoint('TOPLEFT', 106, -22)

-- 载具
hooksecurefunc('PlayerFrame_UpdateArt', function(self)
	if self.state == 'vehicle' then
		if UnitVehicleSkinType('player') == 'Natural' then
			PlayerFrameVehicleTexture:SetTexture(BC:file('Vehicles\\UI-Vehicle-Frame-Organic'))
		else
			PlayerFrameVehicleTexture:SetTexture(BC:file('Vehicles\\UI-Vehicle-Frame'))
		end
		PlayerName:SetPoint('CENTER', 50, 12)
		PlayerFrameVehicleTexture:SetPoint('TOPLEFT', 20, 0)
		PlayerFrameFlash:SetTexCoord(0, 1, 0, 0.78)
		PlayerFrameFlash:SetPoint('TOPLEFT', 20, 0)
		self.healthbar:SetPoint('TOPLEFT', 120, -51.5) -- 体力条
		self.manabar:SetPoint('TOPLEFT', 120, -62) -- 法力条
	else
		PlayerName:SetPoint('CENTER', 50, 17.8)
		PlayerFrameFlash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
		PlayerFrameFlash:SetPoint('TOPLEFT', 15, 0)
		self.healthbar:SetPoint('TOPLEFT', 106, -41) -- 体力条
		self.manabar:SetPoint('TOPLEFT', 106, -52) -- 法力条
	end
end)
hooksecurefunc('PlayerFrame_ToPlayerArt', function()
	BC.player.healthbar:SetPoint('TOPLEFT', 106, -41)
	BC.player.manabar:SetPoint('TOPLEFT', 106, -52)
end)

-- 小队编号
PlayerFrameGroupIndicatorText:SetFont(STANDARD_TEXT_FONT, 12)
PlayerFrameGroupIndicatorText:SetPoint('LEFT', 20, -3)
PlayerFrameGroupIndicator:SetPoint('TOPLEFT', 97, -4.5)
hooksecurefunc('PlayerFrame_UpdateGroupIndicator', function()
	if BC:getDB('player', 'hidePartyNumber') then PlayerFrameGroupIndicator:Hide() end
end)

-- 体力
BC.player.healthbar.MiddleText = PlayerFrameHealthBarText
BC.player.healthbar.MiddleText:SetPoint('CENTER', BC.player.healthbar, 0, -0.5)
BC.player.healthbar.LeftText:SetPoint('LEFT', BC.player.healthbar, 4, -0.5)
BC.player.healthbar.RightText:SetPoint('RIGHT', BC.player.healthbar, -0.5, -0.5)
BC.player.healthbar.SideText = BC.player.healthbar:CreateFontString()
BC.player.healthbar.SideText:SetPoint('LEFT', BC.player.healthbar, 'RIGHT', 3, -0.5)

-- 法力
BC.player.manabar.MiddleText = PlayerFrameManaBarText
BC.player.manabar.MiddleText:SetPoint('CENTER', BC.player.manabar, 0, -0.5)
BC.player.manabar.LeftText:SetPoint('LEFT', BC.player.manabar, 4, -0.5)
BC.player.manabar.RightText:SetPoint('RIGHT', BC.player.manabar, -0.5, -0.5)
BC.player.manabar.SideText = BC.player.manabar:CreateFontString()
BC.player.manabar.SideText:SetPoint('LEFT', BC.player.manabar, 'RIGHT', 3, -0.5)

-- 装备小图标
function frame:equip()
	for i = 1, 6 do
		local equip = _G['EquipSetFrame' .. i]
		if not equip then
			equip = CreateFrame('Button', 'EquipSetFrame' .. i, BC.player)
			equip:SetFrameLevel(4)
			equip:SetSize(18, 18)
			equip:SetPoint('TOPLEFT', 96 + 18 * i, -4)
			equip:SetHighlightTexture('Interface\\Buttons\\OldButtonHilight-Square')
			equip.border = equip:CreateTexture()
			equip.border:SetSize(16, 16)
			equip.border:SetPoint('CENTER')
			equip.border:SetTexture(BC.texture .. 'Border')
			equip.icon = equip:CreateTexture(nil, 'BACKGROUND')
			equip.icon:SetAllPoints(equip.border)
			equip.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		end
		equip:Hide()
		if BC:getDB('global', 'dark') then
			equip.border:SetVertexColor(0.1, 0.1, 0.1)
		else
			equip.border:SetVertexColor(0.2, 0.2, 0.2)
		end
	end
	if not BC:getDB('player', 'equipmentIcon') then return end

	local index = 1
	for i = 0, 10 do
		local name, icon, setID, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(i)
		if name and icon and setID then
			local equip = _G['EquipSetFrame' .. index]
			if equip then
				equip.name = name
				equip.setID = setID
				equip.isEquipped = isEquipped
				equip.icon:SetTexture(icon)
				if isEquipped then
					equip:SetAlpha(1)
				else
					equip:SetAlpha(0.4)
				end
				equip:Show()

				equip:SetScript('OnEnter', function(self)
					self:SetAlpha(1)
					GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
					GameTooltip:AddDoubleLine(L.clickEquipment .. ':', self.name, 1, 1, 0, 0, 1, 0)
					GameTooltip:AddDoubleLine(L.shiftKeyDown .. ':', L.saveEquipment, 1, 1, 0, 0, 1, 0)
					GameTooltip:Show()
				end)
				equip:SetScript('OnLeave', function(self)
					if self.isEquipped then
						self:SetAlpha(1)
					else
						self:SetAlpha(0.4)
					end
					GameTooltip:Hide()
				end)
				equip:SetScript('OnMouseDown', function(self)
					if IsShiftKeyDown() then -- 保存装备
						BC:comfing(CONFIRM_OVERWRITE_EQUIPMENT_SET:format(self.name), function()
							C_EquipmentSet.SaveEquipmentSet(self.setID)
						end)
					else
						C_EquipmentSet.UseEquipmentSet(self.setID)
					end
				end)
			else
				break
			end
			index = index + 1
		end
	end
end

hooksecurefunc(C_EquipmentSet, 'UseEquipmentSet', function(setID)
	for i = 1, 6 do
		local equip = _G['EquipSetFrame' .. i]
		if equip then
			if setID == equip.setID then
				equip:SetAlpha(1)
				equip.isEquipped = true
			else
				equip:SetAlpha(0.4)
				equip.isEquipped = false
			end
		end
	end
end)

-- 5秒回蓝
function frame:spark(bar, powerType)
	if not bar or BC.class == 'WARRIOR' or BC.class == 'ROGUE' or BC.class == 'DEATHKNIGHT' then return end
	if not bar.spark then
		bar.spark = bar:CreateTexture()
		bar.spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
		bar.spark:SetBlendMode('ADD')
		bar.spark:SetSize(28, 28)
		bar.spark:SetAlpha(0.8)
		if powerType then bar.powerType = powerType end
	end
	bar:HookScript('OnUpdate', function(self)
		local now = GetTime()
		if self.rate and now < self.rate then return end
		self.rate = now + 0.02 --刷新率

		if
			BC:getDB('player', 'fiveSecondRule')
			and bar:IsShown()
			and not UnitIsDeadOrGhost('player')
			and (self.powerType or UnitPowerType('player')) == 0
			and UnitPower('player', 0) < UnitPowerMax('player', 0)
			and type(frame.waitTime) == 'number'
			and frame.waitTime > now
		then
			self.spark:Show()
			self.spark:SetPoint('CENTER', self, 'LEFT', self:GetWidth() * (frame.waitTime - now) / 5, 0)
		else
			self.spark:Hide()
		end
	end)
end

-- 德鲁伊法力条
if BC.class == 'DRUID' and not BC.player.druid then
	local windth, height = BC.player.manabar:GetSize()
	BC.player.druid = CreateFrame('Frame', 'PlayerFrameDruid', BC.player)
	BC.player.druid:SetSize(windth + 6, height + 4)
	BC.player.druid:SetPoint('TOPRIGHT', -2, -62)
	BC.player.druid:SetFrameLevel(3)

	BC.player.druid.border = BC.player.druid:CreateTexture(nil, 'OVERLAY')
	BC.player.druid.border:SetAllPoints(BC.player.druid)

	BC.player.druidBar = CreateFrame('StatusBar', 'PlayerFrameDruidBar', BC.player.druid, 'TextStatusBar')
	BC.player.druidBar.unit = 'player'
	BC.player.druidBar.powerType = 0
	BC.player.druidBar:SetSize(windth, height - 2)
	BC.player.druidBar:SetPoint('LEFT', 3, 0)
	BC.player.druidBar:SetFrameLevel(3)

	BC.player.druidBar.MiddleText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.MiddleText:SetPoint('CENTER', -2, -0.5)
	BC.player.druidBar.LeftText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.LeftText:SetPoint('LEFT', 2, -0.5)
	BC.player.druidBar.RightText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.RightText:SetPoint('RIGHT', -2.5, -0.5)
	BC.player.druidBar.SideText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.SideText:SetPoint('LEFT', BC.player.druidBar, 'RIGHT', 1, -0.5)
end
function frame:druid()
	if not BC.player.druid then return end
	if UnitPowerType('player') ~= 0 and BC:getDB('player', 'druidBar') then
		BC.player.druid:Show()
	else
		BC.player.druid:Hide()
	end
end

-- 德鲁伊变形原始法力条
hooksecurefunc(PlayerFrameAlternateManaBar, 'Show', function(self)
	if BC:getDB('player', 'druidBar') or BC.class ~= 'DRUID' or UnitPowerType('player') == 0 then self:Hide() end
end)

-- 符文
hooksecurefunc(RuneFrame, 'Show', function(self)
	self:SetPoint('TOP', 18, 3)
end)

-- 图腾
hooksecurefunc(TotemFrame, 'Update', function(self)
	self:SetScale(0.8)
	self:SetPoint('TOPLEFT', PlayerFrame, 'BOTTOMLEFT', 107, 44)
	local slot, totem
	for i = 1, MAX_TOTEMS do
		slot = SHAMAN_TOTEM_PRIORITIES[i]
		if GetTotemInfo(slot) then
			totem = self.totemPool:Acquire()
			if not totem.borderTexture then
				totem.border = CreateFrame('Frame', nil, totem)
				totem.border:SetSize(38, 38)
				totem.border:SetPoint('CENTER')
				totem.border:SetFrameLevel(7)
				totem.borderTexture = totem.border:CreateTexture()
				totem.borderTexture:SetAllPoints(totem.border)
			end
			totem.borderTexture:SetTexture(BC:file('CharacterFrame\\TotemBorder'))
		end
	end
end)

BC.player.init = function()
	PlayerFrame_UpdateGroupIndicator() -- 小队编号
	PlayerFrame_UpdateArt(BC.player) -- 载具
	BC:miniIcon('player') -- 小图标
	frame:equip() -- 装备小图标
	TotemFrame:Update() -- 图腾

	-- 5秒回蓝闪动
	if UnitPowerType('player') == 0 or BC.class == 'DRUID' then frame.lastMana = UnitPower('player', 0) end
	frame:spark(BC.player.manabar)
	if BC.class == 'DRUID' then
		frame:spark(PlayerFrameAlternateManaBar, 0)
		frame:spark(BC.player.druidBar, 0)
	end

	-- 德鲁伊法力/能量条
	frame:druid()
	PlayerFrameAlternateManaBar:Show()
	if BC.player.druid then
		BC.player.druidBar:SetStatusBarTexture(BC:file(BC.barList[1]))
		BC.player.druid.border:SetTexture(BC:file(BC.barList[2]))
	end
end

-- 宠物
BC.pet = PetFrame
PetPortrait:SetDrawLayer('ARTWORK') -- 头像层级

-- 快乐值图标
local point, relativeTo, relativePoint, offsetX, offsetY = PetFrameHappiness:GetPoint()
PetFrameHappiness:SetPoint(point, relativeTo, relativePoint, offsetX - 4, offsetY + 10)
PetFrameHappiness:SetSize(20, 20)

PetHitIndicator:SetPoint('CENTER', BC.pet.portrait, 0, -3) -- 头像战斗信息
BC.pet.borderTexture = PetFrameTexture -- 边框
BC.pet.name:SetPoint('BOTTOMLEFT', 49, 41) -- 名字

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

hooksecurefunc(PetFrame, 'Update', function()
	BC:init('pet')
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
BC.pettarget.healthbar = CreateFrame('StatusBar', nil, BC.pettarget, 'TextStatusBar')
BC.pettarget.healthbar:SetSize(70, 7)
BC.pettarget.healthbar:SetPoint('TOPLEFT', 12, -21)
BC.pettarget.healthbar:SetFrameLevel(1)
BC.pettarget.healthbar.MiddleText = BC.pettarget:CreateFontString()
BC.pettarget.healthbar.MiddleText:SetPoint('CENTER', BC.pettarget.healthbar, 0, 1)
BC.pettarget.healthbar.SideText = BC.pettarget:CreateFontString()
BC.pettarget.healthbar.SideText:SetPoint('RIGHT', BC.pettarget.healthbar, 'LEFT', 0, 1)
BC.pettarget.healthbar.unit = 'pettarget'

-- 法力
BC.pettarget.manabar = CreateFrame('StatusBar', nil, BC.pettarget, 'TextStatusBar')
BC.pettarget.manabar:SetSize(70, 7)
BC.pettarget.manabar:SetPoint('TOPLEFT', 12, -29)
BC.pettarget.manabar:SetFrameLevel(1)
BC.pettarget.manabar.MiddleText = BC.pettarget:CreateFontString()
BC.pettarget.manabar.MiddleText:SetPoint('CENTER', BC.pettarget.manabar, 0, -1)
BC.pettarget.manabar.SideText = BC.pettarget:CreateFontString()
BC.pettarget.manabar.SideText:SetPoint('RIGHT', BC.pettarget.manabar, 'LEFT', 0, -1)
BC.pettarget.manabar.unit = 'pettarget'

for _, event in pairs({
	'ACTIVE_TALENT_GROUP_CHANGED', -- 天赋切换
	'PLAYER_TALENT_UPDATE', -- 天赋点更新
	'EQUIPMENT_SETS_CHANGED', -- 套装变更
	'UPDATE_SHAPESHIFT_FORM', -- 形态变化
	'UNIT_POWER_UPDATE', -- 法力/能量值变化
}) do
	frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(self, event, unit)
	if event == 'ACTIVE_TALENT_GROUP_CHANGED' or event == 'PLAYER_TALENT_UPDATE' then
		BC:miniIcon('player')
	elseif event == 'EQUIPMENT_SETS_CHANGED' then
		self:equip()
	elseif event == 'UPDATE_SHAPESHIFT_FORM' then
		self:druid()
	elseif event == 'UNIT_POWER_UPDATE' then
		if unit == 'player' and (UnitPowerType('player') == 0 or BC.class == 'DRUID') then
			local mana = UnitPower('player', 0)
			if type(self.lastMana) == 'number' and mana < self.lastMana and mana < UnitPowerMax('player', 0) then
				self.waitTime = GetTime() + 5
			end
			self.lastMana = mana
		end
	end
end)

frame:SetScript('OnUpdate', function(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer < 0.1 then return end
	self.timer = 0

	if BC.player.druidBar and BC.player.druidBar:IsShown() then BC:bar(BC.player.druidBar) end
	if BC.pettarget:IsShown() and BC.pettarget:GetAlpha() > 0 then
		BC:bar(BC.pettarget.healthbar)
		BC:bar(BC.pettarget.manabar)
	end
end)
