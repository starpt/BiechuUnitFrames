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
	BC.player.manabar.spark = CreateFrame('Statusbar', nil, BC.player.manabar)
	BC.player.manabar.spark:SetAllPoints(BC.player.manabar)
	BC.player.manabar.spark.point = BC.player.manabar.spark:CreateTexture()
	BC.player.manabar.spark.point:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
	BC.player.manabar.spark.point:SetBlendMode('ADD')
	BC.player.manabar.spark.point:SetSize(28, 28)
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

	BC.player.druidBar.spark = CreateFrame('Statusbar', nil, BC.player.druidBar)
	BC.player.druidBar.spark:SetAllPoints(BC.player.druidBar)
	BC.player.druidBar.spark:SetFrameLevel(5)
	BC.player.druidBar.spark.point = BC.player.druidBar.spark:CreateTexture()
	BC.player.druidBar.spark.point:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
	BC.player.druidBar.spark.point:SetBlendMode('ADD')
	BC.player.druidBar.spark.point:SetSize(28, 28)
end

-- 显示法力/能量恢复提示
function frame:spark(bar)
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

	local now = GetTime()
	local interval = self.interval or 2 -- 恢复间隔

	if bar.powerType == 0 then
		local manaTime = BC:getDB('cache', 'manaTime')
		if type(self.waitTime) == 'number' and self.waitTime > now then
			bar.spark.point:SetPoint('CENTER', bar.spark, 'LEFT', bar.spark:GetWidth() * (self.waitTime - now) / 5, 0)
		elseif type(manaTime) == 'number' then
			bar.spark.point:SetPoint('CENTER', bar.spark, 'LEFT', bar.spark:GetWidth() * (mod(now - manaTime, interval) / interval), 0)
		else
			bar.spark:Hide()
		end
	else
		local energyTime = BC:getDB('cache', 'energyTime')
		if type(energyTime) == 'number' then
			bar.spark.point:SetPoint('CENTER', bar.spark, 'LEFT', bar.spark:GetWidth() * (mod(now - energyTime, interval) / interval), 0)
		end
	end
end

BC.player.init = function()
	PlayerFrame_UpdateGroupIndicator() -- 小队编号

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
	'UNIT_PET', -- 宠物变化
	'COMBAT_LOG_EVENT_UNFILTERED', -- 战斗记录
	'UNIT_POWER_UPDATE', -- 法力/怒气/能量等 更新
}) do
	frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(self, event, unit, ...)
	if event == 'PLAYER_ENTERING_WORLD' then
		local power = UnitPower('player')
		if UnitPowerType('player') == 0 then -- 法力
			self.lastMana = power
		elseif UnitPowerType('player') == 3 then -- 能量
			self.lastEnergy = power
		end
	elseif event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_REGEN_ENABLED' then
		BC.player.flash:Hide()
		BC:setDB('cache', 'threat', nil) -- 清空仇恨列表
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
			elseif spellId and GetSpellInfo(spellId) == GetSpellInfo(1454)  then -- 跳过 生命分流
				self.skip = true
			end
		end
	elseif event == 'UNIT_POWER_UPDATE' then
		local powerType = UnitPowerType('player')
		if unit == 'player' then
			local now = GetTime()
			if powerType == 0 then -- 法力
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
			elseif powerType == 3 then -- 能量
				local energy = UnitPower('player', 3)
				if type(self.lastEnergy) ~= 'number' or energy > self.lastEnergy then
					BC:setDB('cache', 'energyTime', now)
				end
				self.lastEnergy = energy
			end
		end
	elseif event == 'UNIT_PET' then
		if unit == 'player' then
			BC:update('pet')
		end
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
			BC.player.druidBar.powerType = powerType == 1 and BC:getDB('player', 'druidBarEnergy') and 3 or 0
			BC:bar(BC.player.druidBar)
			self:spark(BC.player.druidBar)
		else
			BC.player.druid:Hide()
		end
	end

	self:spark(BC.player.manabar)

	if UnitExists('pettarget') then
		BC:bar(BC.pettarget.healthbar)
		BC:bar(BC.pettarget.manabar)
	elseif BC.pettarget:GetAlpha() > 0 then
		BC.pettarget:SetAlpha(0)
	end
end)