local addonName = ...
local BC = _G[addonName]
local L = _G[addonName .. 'Locale']
local dark = BC:getDB('global', 'dark')
local frame = CreateFrame('Frame')

BC.player = PlayerFrame
BC.player.name:SetPoint('TOP', 50, -26)      -- 名字
BC.player.borderTexture = PlayerFrameTexture -- 边框
BC.player.flash = PlayerFrameFlash           -- 战斗中边框发红光
BC.player.pvpIcon = PlayerPVPIcon            -- PVP图标

-- 等级
PlayerLevelText:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE')
hooksecurefunc('PlayerFrame_UpdateLevelTextAnchor', function()
	PlayerLevelText:SetPoint('CENTER', BC.player, -62, -16)
end)
-- 小队编号
PlayerFrameGroupIndicatorText:SetFont(STANDARD_TEXT_FONT, 12)
PlayerFrameGroupIndicatorText:SetPoint('LEFT', 20, -3)
PlayerFrameGroupIndicator:SetPoint('TOPLEFT', 97, -4.5)
hooksecurefunc('PlayerFrame_UpdateGroupIndicator', function()
	if PlayerFrameGroupIndicator:IsShown() and BC:getDB('player', 'hidePartyNumber') then
		PlayerFrameGroupIndicator:Hide()
	end
end)

-- 状态栏
BC.player.statusBar = BC.player:CreateTexture(nil, 'BACKGROUND')
BC.player.statusBar:SetSize(119, 19)
BC.player.statusBar:SetPoint('TOPLEFT', BC.player, 105, -22)

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

	for i = 1, 6 do
		local equip = _G['EquipSetFrame' .. i]
		if not equip then
			equip = CreateFrame('Button', 'EquipSetFrame' .. i, BC.player)
			equip:SetFrameLevel(4)
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
	BC.player.druidBar:SetSize(windth, height - 4)
	BC.player.druidBar:SetPoint('LEFT', 2, 0)
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
function frame:druid()
	if not BC.player.druid then return end
	if UnitPowerType('player') ~= 0 and BC:getDB('player', 'druidBar') then
		BC.player.druid:Show()
	else
		BC.player.druid:Hide()
	end
end

BC.player.init = function()
	PlayerFrame_UpdateGroupIndicator() -- 小队编号
	BC:miniIcon('player')             -- 小图标

	-- 装备小图标
	frame:equip()
	if type(ItemRack) == 'table' then
		hooksecurefunc(ItemRack, 'FireItemRackEvent', frame.equip)
		hooksecurefunc(ItemRack, 'AddHidden', frame.equip)
		hooksecurefunc(ItemRack, 'RemoveHidden', frame.equip)
	end

	-- 德鲁伊法力/能量条
	frame:druid()
	if BC.player.druid then
		BC.player.druidBar:SetStatusBarTexture(BC:file(BC.barList[1]))
		BC.player.druid.border:SetTexture(BC:file(BC.barList[2]))
	end
end

-- 宠物
BC.pet = PetFrame

-- 快乐值图标
local point, relativeTo, relativePoint, offsetX, offsetY = PetFrameHappiness:GetPoint()
PetFrameHappiness:SetPoint(point, relativeTo, relativePoint, offsetX - 4, offsetY + 10)
PetFrameHappiness:SetSize(20, 20)

BC.pet.borderTexture = PetFrameTexture     -- 边框
BC.pet.name:SetPoint('BOTTOMLEFT', 50, 41) -- 名字

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

for _, event in pairs {
	'ACTIVE_TALENT_GROUP_CHANGED', -- 天赋切换
	'PLAYER_TALENT_UPDATE',       -- 天赋点更新
	'UPDATE_SHAPESHIFT_FORM'      -- 形状变化
} do
	frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(self, event)
	if event == 'ACTIVE_TALENT_GROUP_CHANGED' or event == 'PLAYER_TALENT_UPDATE' then
		BC:miniIcon('player')
	elseif event == 'UPDATE_SHAPESHIFT_FORM' then
		self:druid()
	end
end)

frame:SetScript('OnUpdate', function(self)
	local now = GetTime()
	if self.rate and now < self.rate then return end
	self.rate = now + .02 -- 刷新率

	if BC.player.druidBar and BC.player.druidBar:IsShown() then BC:bar(BC.player.druidBar) end
	if BC.pettarget:IsShown() and BC.pettarget:GetAlpha() > 0 then
		BC:bar(BC.pettarget.healthbar)
		BC:bar(BC.pettarget.manabar)
	end
end)
