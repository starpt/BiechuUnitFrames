local addonName = ...
local BC = _G[addonName]
local L = _G[addonName .. 'Locale']
local dark = BC:getDB('global', 'dark')
local frame = CreateFrame('Frame')

BC.player = PlayerFrame
BC.player.name:SetPoint('TOP', 50, -26) -- 名字
BC.player.borderTexture = PlayerFrameTexture -- 边框
BC.player.flash = PlayerFrameFlash -- 战斗中边框发红光
BC.player.pvpIcon = PlayerPVPIcon -- PVP图标
PlayerLevelText:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE') -- 等级

-- 载具
hooksecurefunc('PlayerFrame_UpdateArt', function(...)
	BC:init('player')
	BC:init('pet')
end)

-- 小队编号
PlayerFrameGroupIndicatorText:SetFont(STANDARD_TEXT_FONT, 12)
PlayerFrameGroupIndicatorText:SetPoint('LEFT', 20, -3)
PlayerFrameGroupIndicator:SetPoint('TOPLEFT', 97, -4.5)
hooksecurefunc('PlayerFrame_UpdateGroupIndicator', function()
	if PlayerFrameGroupIndicator:IsShown() and BC:getDB('player', 'hidePartyNumber') then PlayerFrameGroupIndicator:Hide() end
end)

-- 状态栏
BC.player.statusBar = BC.player:CreateTexture(nil, 'BACKGROUND')
BC.player.statusBar:SetSize(119, 19)
BC.player.statusBar:SetPoint('TOPLEFT', BC.player, 105, -22)

-- 体力
BC.player.healthbar.MiddleText = PlayerFrameHealthBarText
local parent = BC.player.healthbar.MiddleText:GetParent()
BC.player.healthbar.LeftText = parent:CreateFontString()
BC.player.healthbar.LeftText:SetPoint('LEFT', BC.player.healthbar, 3, 0)
BC.player.healthbar.RightText = parent:CreateFontString()
BC.player.healthbar.RightText:SetPoint('RIGHT', BC.player.healthbar, -1, 0)
BC.player.healthbar.SideText = parent:CreateFontString()
BC.player.healthbar.SideText:SetPoint('LEFT', BC.player.healthbar, 'RIGHT', 3, 0)

-- 法力
BC.player.manabar.MiddleText = PlayerFrameManaBarText
parent = BC.player.manabar.MiddleText:GetParent()
BC.player.manabar.LeftText = parent:CreateFontString()
BC.player.manabar.LeftText:SetPoint('LEFT', BC.player.manabar, 3, 0)
BC.player.manabar.RightText = parent:CreateFontString()
BC.player.manabar.RightText:SetPoint('RIGHT', BC.player.manabar, -1, 0)
BC.player.manabar.SideText = parent:CreateFontString()
BC.player.manabar.SideText:SetPoint('LEFT', BC.player.manabar, 'RIGHT', 3, 0)

-- 获取装备小图标索引
function GetIconIDFromTexture(iconTexture)
	if not strfind(iconTexture, '\\') then iconTexture = 'Interface\\Icons\\' .. iconTexture end
	RefreshEquipmentSetIconInfo()
	local numIcons = GetNumMacroIcons()
	for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		if GetInventoryItemTexture('player', i) then numIcons = numIcons + 1 end
	end
	for i = 1, numIcons do
		local texture, id = GetEquipmentSetIconInfo(i)
		if texture == iconTexture then return id end
	end
	return 1
end

-- 装备小图标
function frame:equip()
	for i = 1, 6 do
		local equip = _G['EquipSetFrame' .. i]
		if not equip then
			equip = CreateFrame('Button', 'EquipSetFrame' .. i, BC.player)
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
			equip.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		end

		local name, icon = GetEquipmentSetInfo(i)
		if name and icon and BC:getDB('player', 'equipmentIcon') then
			equip.name = name
			if name == BC:getDB('cache', 'equip') then
				equip:SetAlpha(1)
			else
				equip:SetAlpha(0.4)
			end
			equip.icon:SetTexture(icon)
			equip:Show()
			equip:SetScript('OnEnter', function(self)
				self:SetAlpha(1)
				GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
				GameTooltip:AddDoubleLine(L.clickEquipment .. ':', self.name, 1, 1, 0, 0, 1, 0)
				GameTooltip:AddDoubleLine(L.shiftKeyDown .. ':', L.saveEquipment, 1, 1, 0, 0, 1, 0)
				GameTooltip:Show()
			end)
			equip:SetScript('OnLeave', function(self)
				if self.name == BC:getDB('cache', 'equip') then
					self:SetAlpha(1)
				else
					self:SetAlpha(0.4)
				end
				GameTooltip:Hide()
			end)
			equip:SetScript('OnMouseDown', function(self)
				if IsShiftKeyDown() then -- 保存装备
					local dialog = StaticPopup_Show('CONFIRM_OVERWRITE_EQUIPMENT_SET', name)
					if dialog then
						dialog.data = self.name
						dialog.selectedIcon = GetIconIDFromTexture(self.icon:GetTexture())
					else
						UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
					end
				else
					EquipmentManager_EquipSet(self.name)
				end
			end)
		else
			equip:Hide()
		end
	end
end

hooksecurefunc('EquipmentManager_EquipSet', function(name)
	BC:setDB('cache', 'equip', name)
	for i = 1, 6 do
		local equip = _G['EquipSetFrame' .. i]
		if equip then
			if name == equip.name then
				equip:SetAlpha(1)
			else
				equip:SetAlpha(0.4)
			end
		end
	end
end)

-- 5秒回蓝
function frame:spark(bar, powerType)
	if not bar or BC.class == 'WARRIOR' or BC.class == 'ROGUE' or BC.class == 'DEATHKNIGHT' then return end
	if not bar.spark then
		bar.spark = bar:CreateTexture(nil, 'OVERLAY')
		bar.spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark', true)
		bar.spark:SetBlendMode('ADD')
		bar.spark:SetSize(28, 28)
		bar.spark:SetAlpha(0.8)
		if powerType then bar.powerType = powerType end

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
	BC.player.druidBar:SetSize(windth, height - 3)
	BC.player.druidBar:SetPoint('LEFT', 3, 0)
	BC.player.druidBar:SetFrameLevel(3)

	BC.player.druidBar.MiddleText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.MiddleText:SetPoint('CENTER', -0.5, -1)
	BC.player.druidBar.LeftText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.LeftText:SetPoint('LEFT', 6, -1)
	BC.player.druidBar.RightText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.RightText:SetPoint('RIGHT', -4.5, -1)
	BC.player.druidBar.SideText = BC.player.druidBar:CreateFontString(nil, 'OVERLAY')
	BC.player.druidBar.SideText:SetPoint('LEFT', BC.player.druidBar, 'RIGHT', 2.5, -1)
end
function frame:druid()
	if not BC.player.druid then return end
	if UnitPowerType('player') ~= 0 and BC:getDB('player', 'druidBar') then
		BC.player.druid:Show()
	else
		BC.player.druid:Hide()
	end
end

hooksecurefunc(PlayerFrameAlternateManaBar, 'Show', function(self)
	if BC:getDB('player', 'druidBar') or BC.class ~= 'DRUID' or UnitPowerType('player') == 0 then self:Hide() end
end)

-- 图腾
hooksecurefunc(TotemFrame, 'Show', function(self)
	TotemFrame:SetScale(0.8)
	TotemFrame:SetPoint('TOPLEFT', PlayerFrame, 'BOTTOMLEFT', 142, 46)
	for i = 1, 4 do
		local totem = _G['TotemFrameTotem' .. i]
		if totem then
			if not totem.borderTexture then
				totem.border = CreateFrame('Frame', nil, totem)
				totem.border:SetSize(57, 57)
				totem.border:SetPoint('CENTER', 11, -12)
				totem.border:SetFrameLevel(6)
				totem.borderTexture = totem.border:CreateTexture()
				totem.borderTexture:SetAllPoints(totem.border)
			end
			totem.borderTexture:SetTexture(BC:file('Minimap\\MiniMap-TrackingBorder'))
			if OmniCC and OmniCC.Timer then totem:SetScript('OnUpdate', nil) end
		end
	end
end)

BC.player.init = function()
	PlayerFrame_UpdateGroupIndicator() -- 小队编号
	TotemFrame:Show() -- 图腾
	BC:miniIcon('player') -- 小图标
	frame:equip() -- 装备小图标

	-- 载具
	if UnitInVehicle('player') then
		if UnitVehicleSkinType('player') == 'Natural' then
			PlayerFrameVehicleTexture:SetTexture(BC:file('Vehicles\\UI-Vehicle-Frame-Organic'))
		else
			PlayerFrameVehicleTexture:SetTexture(BC:file('Vehicles\\UI-Vehicle-Frame'))
		end
	end

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
PetFrameFlash:SetAlpha(0)

-- 快乐值图标
local point, relativeTo, relativePoint, offsetX, offsetY = PetFrameHappiness:GetPoint()
PetFrameHappiness:SetPoint(point, relativeTo, relativePoint, offsetX - 4, offsetY + 10)
PetFrameHappiness:SetSize(20, 20)

BC.pet.borderTexture = PetFrameTexture -- 边框
BC.pet.name:SetPoint('BOTTOMLEFT', 50, 41) -- 名字

-- 体力
BC.pet.healthbar:SetPoint('TOPLEFT', 47, -13)
BC.pet.healthbar.MiddleText = PetFrameHealthBarText
parent = BC.pet.healthbar.MiddleText:GetParent()
BC.pet.healthbar.MiddleText:SetPoint('TOP', 18, -11.2)
BC.pet.healthbar.LeftText = parent:CreateFontString()
BC.pet.healthbar.LeftText:SetPoint('LEFT', BC.pet.healthbar, 1, 1)
BC.pet.healthbar.RightText = parent:CreateFontString()
BC.pet.healthbar.RightText:SetPoint('RIGHT', BC.pet.healthbar, -1.5, 1)

-- 法力
BC.pet.manabar:SetPoint('TOPLEFT', 47, -21)
BC.pet.manabar.MiddleText = PetFrameManaBarText
parent = BC.pet.manabar.MiddleText:GetParent()
BC.pet.manabar.MiddleText:SetPoint('TOP', 18, -19.2)
BC.pet.manabar.LeftText = parent:CreateFontString()
BC.pet.manabar.LeftText:SetPoint('LEFT', BC.pet.manabar, 1, 0.7)
BC.pet.manabar.RightText = parent:CreateFontString()
BC.pet.manabar.RightText:SetPoint('RIGHT', BC.pet.manabar, -1.5, 0.7)

hooksecurefunc('PetFrame_Update', function()
	BC:update('pet')
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
	'ACTIVE_TALENT_GROUP_CHANGED', -- 天赋切换
	'PLAYER_TALENT_UPDATE', -- 天赋点更新
	'ZONE_CHANGED_NEW_AREA', -- 区域切换
	'EQUIPMENT_SETS_CHANGED', -- 套装变更
	'UPDATE_SHAPESHIFT_FORM', -- 形状变化
	'UNIT_MANA', -- 法力值变化
}) do
	frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(self, event, unit)
	if event == 'ACTIVE_TALENT_GROUP_CHANGED' or event == 'PLAYER_TALENT_UPDATE' or event == 'ZONE_CHANGED_NEW_AREA' then
		BC:miniIcon('player')
	elseif event == 'EQUIPMENT_SETS_CHANGED' then
		self:equip()
	elseif event == 'UPDATE_SHAPESHIFT_FORM' then
		self:druid()
	elseif event == 'UNIT_MANA' then
		if unit == 'player' and (UnitPowerType('player') == 0 or BC.class == 'DRUID') then
			local mana = UnitPower('player', 0)
			if type(self.lastMana) == 'number' and mana < self.lastMana and mana < UnitPowerMax('player', 0) then self.waitTime = GetTime() + 5 end
			self.lastMana = mana
		end
	end
end)

frame:SetScript('OnUpdate', function(self)
	local now = GetTime()
	if self.rate and now < self.rate then return end
	self.rate = now + 0.02 -- 刷新率

	if BC.player.druidBar and BC.player.druidBar:IsShown() then BC:bar(BC.player.druidBar) end
	if BC.pettarget:IsShown() then
		BC:bar(BC.pettarget.healthbar)
		BC:bar(BC.pettarget.manabar)
	end
end)
