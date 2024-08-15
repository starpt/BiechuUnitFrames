local addonName = ...
local BC = _G[addonName]
local L = _G[addonName .. 'Locale']
local dark = BC:getDB('global', 'dark')
local frame = CreateFrame('Frame')

BC.player = PlayerFrame
BC.player.name:SetPoint('TOP', 50, -26.5) -- 名字
BC.player.borderTexture = PlayerFrameTexture -- 边框
BC.player.pvpIcon = PlayerPVPIcon -- PVP图标
BC.player.flash = PlayerFrameFlash -- 战斗中边框发红光

-- 小队编号
PlayerFrameGroupIndicatorText:SetFont(STANDARD_TEXT_FONT, 12)
PlayerFrameGroupIndicatorText:SetPoint('LEFT', 20, -3)
PlayerFrameGroupIndicator:SetPoint('TOPLEFT', 97, -4.5)
hooksecurefunc('PlayerFrame_UpdateGroupIndicator', function()
	if PlayerFrameGroupIndicator:IsShown() and BC:getDB('player', 'hidePartyNumber') then
		PlayerFrameGroupIndicator:Hide()
	end
end)

-- 等级
hooksecurefunc('PlayerFrame_UpdateLevelTextAnchor', function()
	PlayerLevelText:SetPoint('CENTER', BC.player, -62, -16)
end)

-- 定位
hooksecurefunc(BC.player, 'SetPoint', function(self, ...)
	if self.moving then -- 载具自动还原
		frame.lock = nil
	else
		frame.lock = GetTime() + .1 -- 定位刷新频率
	end
end)

-- 载具
hooksecurefunc('PlayerFrame_UpdateArt', function()
	BC:init('player')
	BC:init('pet')
end)

-- 状态栏
BC.player.statusBar = BC.player:CreateTexture(nil, 'BACKGROUND')
BC.player.statusBar:SetSize(119, 19)
BC.player.statusBar:SetPoint('TOPLEFT', BC.player, 'TOPLEFT', 106, -22)

-- 体力
BC.player.healthbar.MiddleText = PlayerFrameHealthBarText
BC.player.healthbar.LeftText:SetPoint('LEFT', BC.player.healthbar, 'LEFT', 4, -.5)
BC.player.healthbar.RightText:SetPoint('RIGHT', BC.player.healthbar, 'RIGHT', -.5, -.5)
BC.player.healthbar.SideText = BC.player.healthbar:CreateFontString()
BC.player.healthbar.SideText:SetPoint('LEFT', BC.player.healthbar, 'RIGHT', 3, -.5)

-- 法力
BC.player.manabar.MiddleText = PlayerFrameManaBarText
BC.player.manabar.MiddleText:SetPoint('CENTER', BC.player.manabar, 'CENTER', 0, -.5)
BC.player.manabar.LeftText:SetPoint('LEFT', BC.player.manabar, 'LEFT', 4, -.5)
BC.player.manabar.RightText:SetPoint('RIGHT', BC.player.manabar, 'RIGHT', -.5, -.5)
BC.player.manabar.SideText = BC.player.manabar:CreateFontString()
BC.player.manabar.SideText:SetPoint('LEFT', BC.player.manabar, 'RIGHT', 3, -.5)

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
end

-- 5秒回蓝
if not BC.player.fiveSecondRule and BC.class ~= 'WARRIOR' and BC.class ~= 'ROGUE' and BC.class ~= 'DEATHKNIGHT' then
	BC.player.fiveSecondRule = CreateFrame('Statusbar', nil, BC.player.manabar)
	BC.player.fiveSecondRule:SetSize(BC.player.manabar:GetSize())
	BC.player.fiveSecondRule:SetFrameLevel(4)
	BC.player.fiveSecondRule.point = BC.player.fiveSecondRule:CreateTexture()
	BC.player.fiveSecondRule.point:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
	BC.player.fiveSecondRule.point:SetBlendMode('ADD')
	BC.player.fiveSecondRule.point:SetSize(28, 28)
end

-- 天赋和装备小图标
function frame:talentEquip()
	-- 装备小图标 最多6个
	local equipID = BC:getDB('cache', 'equip')
	for i = 1, 6 do
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
			equip.icon:SetTexCoord(.06, .94, .06, .94)
		end
		equip:Hide()
	end
	if BC:getDB('player', 'equipmentIcon') then
		GearManagerDialog_Update()
		local dialog = GearManagerDialog;
		local buttons = dialog.buttons;
		local index = 0
		for i = 1, #buttons do
			if buttons[i].name then
				index = index + 1
				local equip = _G['EquipSetFrame' .. index]
				if equip then
					equip.id = buttons[i].id
					if equipID == equip.id then
						equip:SetAlpha(1)
					else
						equip:SetAlpha(.4)
					end
					if dark then
						equip.border:SetVertexColor(0, 0, 0)
					else
						equip.border:SetVertexColor(1, 1, 1)
					end
					equip.icon:SetTexture(buttons[i].icon:GetTexture())
					equip:Show()

					-- 鼠标悬停
					equip:SetScript('OnEnter', function(self)
						if InCombatLockdown() then return end -- 战斗中
							self:SetAlpha(1)
							GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
							GameTooltip:AddLine(L.clickEquipment:format(C_EquipmentSet.GetEquipmentSetInfo(self.id)))
							GameTooltip:AddLine(L.shiftKeyDownSave)
							GameTooltip:Show()
					end)

					-- 鼠标离开
					equip:SetScript('OnLeave', function(self)
						if self.id == equipID then
							self:SetAlpha(1)
						else
							self:SetAlpha(.4)
						end
						GameTooltip:Hide()
					end)

					-- 鼠标点击
					equip:SetScript('OnMouseDown', function(self)
						local name, icon = C_EquipmentSet.GetEquipmentSetInfo(self.id)
						if IsShiftKeyDown() then -- 保存方案
							if name then
								local dialog = StaticPopup_Show('CONFIRM_OVERWRITE_EQUIPMENT_SET', name)
								if dialog then
									dialog.data = self.id
									dialog.selectedIcon = icon
								else
									UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, .1, .1, 1.0)
								end
							end
						else
							PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
							EquipmentManager_EquipSet(self.id)
						end
					end)

				end
			end
		end
	end

	-- 天赋小图标(点击切换天赋)
	if BC.player.miniIcon and BC.player.miniIcon:IsShown() then
		-- 小图标点击
		BC.player.miniIcon.click = function()
			local active = GetActiveTalentGroup('player', false) -- 当前天赋
			if IsShiftKeyDown() then -- 按住Shift 一键脱光
				EQUIPMENTMANAGER_BAGSLOTS = {} -- 背包空间缓存
				for _, i in pairs({16, 17, 5, 7, 1, 3, 9, 10, 6, 8}) do
					local durability = GetInventoryItemDurability(i)
					if durability and durability > 0 then -- 有耐久度
						for bag = 0, NUM_BAG_SLOTS do
							EQUIPMENTMANAGER_BAGSLOTS[bag] = EQUIPMENTMANAGER_BAGSLOTS[bag] or {}
							for slot = 1, C_Container.GetContainerNumSlots(bag) do
								if not C_Container.GetContainerItemID(bag, slot) and not EQUIPMENTMANAGER_BAGSLOTS[bag][slot] then -- 背包有空位
									PickupInventoryItem(i)
									if bag == 0 then
										PutItemInBackpack()
									else
										PutItemInBag(bag + CONTAINER_BAG_OFFSET)
									end
									EQUIPMENTMANAGER_BAGSLOTS[bag][slot] = true
									break
								end
							end
						end
					end
				end
				C_EquipmentSet.UseEquipmentSet(-1)
			else
				SetActiveTalentGroup(3 - active) -- 切换天赋
				BC.player.miniIcon.update = function() -- 切换天赋回调
					BC.player.miniIcon.update = nil
					BC.player.miniIcon:Hide()
					BC.player.miniIcon:Show()

					-- 切换天赋后自动装备对应套装
					if BC:getDB('player', 'autoTalentEquip') then
						local equip = _G['EquipSetFrame' .. (active == 1 and 2 or 1)]
						if equip and equip.id then
							PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
							EquipmentManager_EquipSet(equip.id)
						end
					end
				end
			end
		end

		BC.player.miniIcon:SetPoint('TOPLEFT', 88, 1)
		BC.player.miniIcon:SetFrameLevel(4)
		BC.player.miniIcon.icon:SetPoint('CENTER', 1, 0)
		if dark then BC.player.miniIcon.border:SetAlpha(.9) end

		local active = GetActiveTalentGroup('player', false) -- 当前天赋
		local equip = _G['EquipSetFrame' .. (active == 1 and 2 or 1)]
		local name
		if equip and equip.id then name = C_EquipmentSet.GetEquipmentSetInfo(equip.id) end
		local green = {0, 1, 0}
		local grey = {.5, .5, .5}
		local color = name and green or grey
		local text
		local talent = {}
		for i = 1, MAX_TALENT_TABS do
			local _, icon, point = GetTalentTabInfo(i, 'player', false, active)
			text = (text and text .. '/' or '') .. point
			if not talent.point or talent.point < point then
				talent = {
					icon = icon,
					point = point,
				}
			end
		end
		if talent.icon and type(talent.point) == 'number' and talent.point > 0 then
			BC.player.miniIcon.tip = {[1] = {L.action .. (active == 1 and L.primary or L.secondary)  .. ':', text, 1, 1, 0, 0, 1, 0}}
			BC.player.miniIcon.icon:SetTexture(talent.icon)
		else
			BC.player.miniIcon.tip = {[1] = {L.action .. (active == 1 and L.primary or L.secondary)  .. ':', text, 1, 1, 0, 1, 0, 0}}
			BC.player.miniIcon.icon:SetTexture('Interface\\Icons\\INV_Misc_QuestionMark')
		end
		BC.player.miniIcon.tip[2] = {L.shiftKeyDown .. ':', L.nude, 1, 1, 0, green[1], green[2], green[3]} -- Shift 一键脱装
		BC.player.miniIcon.tip[3] = {L.click .. ':', L.switch .. (active == 1 and L.secondary or L.primary), 1, 1, 0, 0, 1, 0}

		if BC:getDB('player', 'autoTalentEquip') then
			BC.player.miniIcon.tip[4] = {L.switchAfter .. ':', name or L.noEquip, 1, 1, 0, color[1], color[2], color[3]} -- 切换天赋后
		end

		if type(BC.player.miniIcon.update) == 'function' then BC.player.miniIcon.update() end -- 切换天赋后回调
	end
end
hooksecurefunc('EquipmentManager_EquipSet', function(id) -- 装备方案
	BC:setDB('cache', 'equip', id)
	for i = 1, 6 do
		local equip = _G['EquipSetFrame' .. i]
		if equip.id ==  id then
			equip:SetAlpha(1)
		else
			equip:SetAlpha(.4)
		end
	end
end)
hooksecurefunc(C_EquipmentSet, 'DeleteEquipmentSet', function() -- 删除方案
	frame:talentEquip()
end)

BC.player.init = function()
	PlayerLevelText:SetFont(BC:getDB('global', 'valueFont'), BC:getDB('player', 'valueFontSize'), 'OUTLINE') -- 等级
	frame:talentEquip() -- 天赋装备小图标
	PlayerFrame_UpdateGroupIndicator() -- 小队编号

	-- 德鲁伊法力/能量条
	if BC.player.druid then
		if UnitInVehicle('player') and BC.player.druid:IsShown() then
			BC.player.druid:Hide()
		else
			BC.player.druidBar:SetStatusBarTexture(BC:file(BC.barList[1]))
			BC.player.druid.border:SetTexture(BC:file(BC.barList[2]))
		end
	end

	if UnitInVehicle('player') then
		if UnitVehicleSkinType('player') == 'Natural' then
			PlayerFrameVehicleTexture:SetTexture(BC:file('Vehicles\\UI-Vehicle-Frame-Organic'))
		else
			PlayerFrameVehicleTexture:SetTexture(BC:file('Vehicles\\UI-Vehicle-Frame'))
		end
	end
	BC.player.healthbar.MiddleText:SetPoint('CENTER', BC.player.healthbar, 'CENTER', 0, -.5)
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
BC.pet.healthbar.MiddleText:SetPoint('TOP', BC.pet.healthbar, 'TOP', 0, 1.5)
BC.pet.healthbar.LeftText:SetPoint('LEFT', BC.pet.healthbar, 'TOPLEFT', 1, -3.5)
BC.pet.healthbar.RightText:SetPoint('RIGHT', BC.pet.healthbar, 'TOPRIGHT', -1, -3.5)

-- 法力
BC.pet.manabar:SetPoint('TOPLEFT', 47, -21)
BC.pet.manabar.MiddleText = PetFrameManaBarText
BC.pet.manabar.MiddleText:SetPoint('TOP', BC.pet.manabar, 'TOP', 0, 1)
BC.pet.manabar.LeftText:SetPoint('LEFT', BC.pet.manabar, 'TOPLEFT', 1, -3.5)
BC.pet.manabar.RightText:SetPoint('RIGHT', BC.pet.manabar, 'TOPRIGHT', -1, -3.5)

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
BC.pettarget.healthbar.MiddleText:SetPoint('CENTER', BC.pettarget.healthbar, 'CENTER', 0, 1)
BC.pettarget.healthbar.SideText = BC.pettarget:CreateFontString()
BC.pettarget.healthbar.SideText:SetPoint('RIGHT', BC.pettarget.healthbar, 'LEFT', 0, 1)
BC.pettarget.healthbar.unit = 'pettarget'

-- 法力
BC.pettarget.manabar = CreateFrame('StatusBar', nil, BC.pettarget)
BC.pettarget.manabar:SetSize(70, 7)
BC.pettarget.manabar:SetPoint('TOPLEFT', 12, -29)
BC.pettarget.manabar:SetFrameLevel(1)
BC.pettarget.manabar.MiddleText = BC.pettarget:CreateFontString()
BC.pettarget.manabar.MiddleText:SetPoint('CENTER', BC.pettarget.manabar, 'CENTER', 0, -1)
BC.pettarget.manabar.SideText = BC.pettarget:CreateFontString()
BC.pettarget.manabar.SideText:SetPoint('RIGHT', BC.pettarget.manabar, 'LEFT', 0, -1)
BC.pettarget.manabar.unit = 'pettarget'

for _, event in pairs({
	'PLAYER_REGEN_DISABLED', -- 开始战斗
	'PLAYER_REGEN_ENABLED', -- 结束战斗
	'UNIT_SPELLCAST_SUCCEEDED', -- 施法成功
	'ACTIVE_TALENT_GROUP_CHANGED', -- 天赋切换
	'PLAYER_TALENT_UPDATE', -- 天赋点更新
	'EQUIPMENT_SETS_CHANGED', -- 装备更新
}) do
	frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(self, event, unit)
	if event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_REGEN_ENABLED' then
		BC.player.flash:Hide()
	elseif event == 'UNIT_SPELLCAST_SUCCEEDED' then
		if type(self.mana) == 'number' and self.mana > UnitPower('player', 0) then self.wait = GetTime() + 5 end
	elseif event == 'ACTIVE_TALENT_GROUP_CHANGED' or event == 'PLAYER_TALENT_UPDATE' or event == 'EQUIPMENT_SETS_CHANGED' then
		self:talentEquip()
	end
end)

frame:SetScript('OnUpdate', function(self)
	local now = GetTime()

	if type(self.lock) == 'number' and self.lock < now then
		BC:init('player')
		self.lock = nil
	end

	if UnitInVehicle('player') then return end

	if self.rate and now < self.rate then return end
	self.rate = now + .05 -- 刷新率

	local powerType = UnitPowerType('player')
	local sfrBar= powerType == 0 and BC.player.manabar
	if BC.player.druid then
		if BC:getDB('player', 'druidBar') then
			PlayerFrameAlternateManaBar:SetAlpha(0)
			if powerType == 0 then
				BC.player.druid:Hide()
			else
				BC.player.druid:Show()
				BC.player.druidBar.powerType = powerType == 1 and BC:getDB('player', 'druidBarEnergy') and 3 or 0
				BC:bar(BC.player.druidBar)
				if BC.player.druidBar.powerType == 0 then sfrBar = BC.player.druidBar end
			end
		else
			BC.player.druid:Hide()
			PlayerFrameAlternateManaBar:SetAlpha(1)
		end
	end

	-- 5秒回蓝
	if BC.player.fiveSecondRule and sfrBar then
		if BC:getDB('player', 'fiveSecondRule') and not UnitIsDeadOrGhost('player') then
			local wait = type(self.wait) == 'number' and self.wait - now
			if wait and wait > 0 then
				BC.player.fiveSecondRule:SetPoint('CENTER', sfrBar, 0, -.5)
				BC.player.fiveSecondRule.point:SetPoint('CENTER', BC.player.fiveSecondRule, 'LEFT', BC.player.fiveSecondRule:GetWidth() * wait / 5, 0)
				BC.player.fiveSecondRule:Show()
			else
				BC.player.fiveSecondRule:Hide()
			end
			self.mana = UnitPower('player', 0)
		elseif BC.player.fiveSecondRule:IsShown() then
			BC.player.fiveSecondRule:Hide()
		end
	end

	if UnitExists('pettarget') then
		BC:bar(BC.pettarget.healthbar)
		BC:bar(BC.pettarget.manabar)
	else
		BC.pettarget:Hide()
	end
end)