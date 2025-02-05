local addonName = ...
local BC = _G[addonName]
local L = _G[addonName .. 'Locale']
local isZh = GetLocale() == 'zhCN' or GetLocale() == 'zhTW'
local vertical = -31
local horizontal = 322
local option = CreateFrame('Frame', addonName .. 'Option')
local category = Settings.RegisterCanvasLayoutCategory(option, addonName)
Settings.RegisterAddOnCategory(category)

-- 命令行
SlashCmdList[addonName] = function()
	Settings.OpenToCategory(category.ID)
end
_G['SLASH_' .. addonName .. '1'] = '/bc'

-- 标题
function option:title(parent, text)
	parent.title = parent:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	parent.title:SetPoint('TOPLEFT', 16, -16)
	parent.title:SetText(text)
end

-- 数值样式
function option:valueStyleList(...)
	local list = {}
	for _, i in pairs({...}) do
		list[i] = L.valueStyleList[i]
	end
	list[10] = L.valueStyleList[10] -- 都不显示
	return list
end

-- 勾选
function option:check(key, name, relative, offsetX, offsetY, text, click)
	local parent = key == 'global' and self or self[key]
	parent[name] = CreateFrame('CheckButton', parent:GetName() .. name:gsub('^%l', string.upper), parent, 'ChatConfigCheckButtonTemplate')
	parent[name]:SetPoint('TOPLEFT', relative and parent[relative] or parent, offsetX or 0, offsetY or vertical)
	_G[parent[name]:GetName() .. 'Text']:SetText(L[text or name])

	parent[name].Click = type(click) == 'function' and click or function(self)
		BC:setDB(key, name, self:GetChecked())
	end
	parent[name]:SetScript('OnClick', parent[name].Click)

	hooksecurefunc(parent[name], 'SetEnabled', function(self, value)
		if value then
			_G[self:GetName() .. 'Text']:SetTextColor(1, 1, 1)
		else
			_G[self:GetName() .. 'Text']:SetTextColor(.5, .5, .5)
		end
	end)
end

-- 拖动
function option:slider(key, name, relative, offsetX, offsetY, widht, height, lowText, highText, valueMin, valueMax, valueStep, change)
	local parent = key == 'global' and self or self[key]
	parent[name] = CreateFrame('Slider',  parent:GetName() .. name:gsub('^%l', string.upper), parent, 'CompactUnitFrameProfilesSliderTemplate')
	parent[name]:SetPoint('TOPLEFT', relative and parent[relative] or parent, offsetX or 0, offsetY or vertical)
	parent[name]:SetSize(widht or 180, height or 16)
	_G[parent[name]:GetName() .. 'Low']:SetText(lowText)
	_G[parent[name]:GetName() .. 'High']:SetText(highText)
	parent[name]:SetMinMaxValues(valueMin, valueMax)
	parent[name]:SetValueStep(valueStep)
	parent[name .. 'Text'] = parent:CreateFontString(parent:GetName() .. name:gsub('^%l', string.upper) .. 'Text', 'ARTWORK', 'GameFontNormalSmall')
	parent[name .. 'Text']:SetPoint('CENTER', parent[name], 0, 16)
	if type(change) == 'function' then parent[name]:SetScript('OnValueChanged', change) end

	hooksecurefunc(parent[name], 'SetEnabled', function(self, value)
		if value then
			_G[self:GetName() .. 'Text']:SetTextColor(1, .82, 0)
			_G[self:GetName() .. 'Low']:SetTextColor(1, 1, 1)
			_G[self:GetName() .. 'High']:SetTextColor(1, 1, 1)
		else
			_G[self:GetName() .. 'Text']:SetTextColor(.5, .5, .5)
			_G[self:GetName() .. 'Low']:SetTextColor(.5, .5, .5)
			_G[self:GetName() .. 'High']:SetTextColor(.5, .5, .5)
		end
	end)
end

-- 下拉菜单选项初始化
function option:downMenuInit(down, key, name, menus, width)
	local text = _G[down:GetName() .. 'Text']
	local function setFont(value)
		if text and type(value) == 'string' and value:lower():match('%.ttf$') then
			text:SetFont(value, select(2, text:GetFont()))
		end
	end

	UIDropDownMenu_Initialize(down, function()
		local sorted = {}
		for i in pairs(menus) do
			table.insert(sorted, i)
		end
		table.sort(sorted, function(a, b)
			return a < b
		end)
		for _, i in ipairs(sorted) do
			local info = UIDropDownMenu_CreateInfo()
			local menu = menus[i]
			if type(menu) == 'table' then
				info.text = menu.text
				info.value = menu.value
			else
				info.text = menu
				info.value = i
			end
			info.func = function(self)
				BC:setDB(key, name, self.value)
				UIDropDownMenu_SetSelectedID(down, self:GetID())
				setFont(self.value)
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetSelectedValue(down, BC:getDB(key, name))
	setFont(BC:getDB(key, name))
	UIDropDownMenu_SetWidth(down, width and width or (isZh and 120 or 200))
end

-- 下拉菜单
function option:downMenu(key, name, menus, relative, offsetX, offsetY, width, show)
	local parent = key == 'global' and self or self[key]
	parent[name] = parent:CreateFontString(parent:GetName() .. name:gsub('^%l', string.upper), 'ARTWORK', 'GameFontNormalSmall')
	parent[name]:SetPoint('TOPLEFT', relative and parent[relative] or parent, 'TOPLEFT', offsetX or 0, offsetY or vertical - 24)
	parent[name]:SetText(L[name])
	-- 下拉选择
	parent[name .. 'Down'] = CreateFrame('Frame', parent[name]:GetName() .. 'Down', parent, 'UIDropDownMenuTemplate')
	parent[name .. 'Down']:SetPoint('TOPLEFT', parent[name], -18, -16)

	parent[name].OnShow = function(self)
		local down = _G[self:GetName() .. 'Down']
		if type(show) == 'function' then
			show(down, key, name, menus)
		else
			option:downMenuInit(down, key, name, menus)
		end
		UIDropDownMenu_SetWidth(down, width and width or (isZh and 120 or 200))
	end

	parent[name].SetEnabled = function(self, enabled)
		UIDropDownMenu_SetDropDownEnabled(_G[self:GetName() .. 'Down'], enabled)
		if enabled then
			self:SetTextColor(1, .82, 0)
		else
			self:SetTextColor(.5, .5, .5)
		end
	end
end

-- 按钮
function option:button(key, name, relative, offsetX, offsetY, width, click)
	local parent = key == 'global' and self or self[key]
	parent[name] = CreateFrame('Button', parent:GetName() .. name:gsub('^%l', string.upper), parent, 'UIPanelButtonTemplate')
	parent[name]:SetPoint('TOPLEFT', relative and parent[relative] or parent, offsetX or 0, offsetY or 0)
	parent[name]:SetSize(width or 150, 25)
	_G[parent[name]:GetName() .. 'Text']:SetText(L[name])
	if type(click) == 'function' then parent[name]:SetScript('OnClick', click) end
end

-- 选项卡
option.list = {
	'player',
	'pet',
	'pettarget',
	'target',
	'targettarget',
	'party',
	'partypet',
	'partytarget',
}
for _, name in pairs(option.list) do
	option[name] = CreateFrame('Frame', option:GetName() .. name:gsub('^%l', string.upper))
	Settings.RegisterCanvasLayoutSubcategory(category, option[name], L[name])
	option:title(option[name], L[name]:gsub('[├├─└─]', ''))
end

-- 初始设置
function option:init()
	self.dark:SetChecked(BC:getDB('global', 'dark')) -- 暗黑风格
	self.newClassIcon:SetChecked(BC:getDB('global', 'newClassIcon')) -- 新风格职业图标
	self.healthBarColor:SetChecked(BC:getDB('global', 'healthBarColor')) -- 体力条颜色按生命值变化
	self.nameTextClassColor:SetChecked(BC:getDB('global', 'nameTextClassColor')) -- 名字颜色职业色(玩家)

	-- 数值单位
	local carry = BC:getDB('global', 'carry')
	local carryCheck = carry == 1 or carry == 2
	self.carry:SetChecked(carryCheck)
	if isZh then
		self.carrySlider:SetEnabled(carryCheck)
		self.carrySlider:SetValue(carryCheck and carry or carry - 2)
	else
		self.carrySlider:Hide()
	end

	self.nameFont:OnShow() -- 名字字体
	self.valueFont:OnShow() -- 数值字体
	self.fontFlags:OnShow() -- 字体轮廓
	self.config:OnShow() -- 选择配置

	self.dragSystemFarmes:SetChecked(BC:getDB('global', 'dragSystemFarmes')) -- 自由拖动系统框体
	self.incomingHeals:SetChecked(BC:getDB('global', 'incomingHeals')) -- 显示预配治疗
	self.autoTab:SetChecked(BC:getDB('global', 'autoTab')) -- PVP自动TAB选择玩家
	self.alwaysCompareItems:SetChecked(GetCVar('alwaysCompareItems') == '1') -- 启用装备对比

	-- 切换天赋后装备套装(ItemRack)
	local hasItemRack = type(ItemRack) == 'table'
	self.player.autoTalentEquip:SetChecked(hasItemRack and BC:getDB('player', 'autoTalentEquip'))
	self.player.autoTalentEquip:SetEnabled(hasItemRack and BC:getDB('player', 'miniIcon'))

	-- 显示装备小图标(ItemRack)
	self.player.equipmentIcon:SetChecked(hasItemRack and BC:getDB('player', 'equipmentIcon'))
	self.player.equipmentIcon:SetEnabled(hasItemRack)

	self.player.hidePartyNumber:SetChecked(BC:getDB('player', 'hidePartyNumber')) -- 在团队中隐藏小队编号

	-- 显示法力/能量恢复闪动
	if BC.class == 'WARRIOR' then
		self.player.powerSpark:SetChecked(false)
		self.player.powerSpark:SetEnabled(false)
	else
		self.player.powerSpark:SetChecked(BC:getDB('player', 'powerSpark'))
		self.player.powerSpark:SetEnabled(type(PowerSparkDB) ~= 'table' or not PowerSparkDB.enabled)
	end

	-- 显示自定义德鲁伊法力条
	if BC.class == 'DRUID' then
		self.player.druidBar:SetChecked(BC:getDB('player', 'druidBar'))
	else
		self.player.druidBar:SetChecked(false)
		self.player.druidBar:SetEnabled(false)
	end

	self.player.border:OnShow() -- 边框
	self.player.portrait:OnShow() -- 头像

	self.party.outRange:SetChecked(BC:getDB('party', 'outRange')) -- 超出范围半透明
	self.party.raidShowParty:SetChecked(BC:getDB('party', 'raidShowParty')) -- 团队显示小队框体
	self.party.showLevel:SetChecked(BC:getDB('party', 'showLevel')) -- 显示等级
	self.party.showCastBar:SetChecked(BC:getDB('party', 'showCastBar')) -- 显示施法条

	for _, key in pairs(option.list) do

		-- 隐藏框体
		local hideFrame = self[key].hideFrame
		if hideFrame then
			if key == 'targettarget' then
				hideFrame:SetChecked(GetCVar('showTargetOfTarget') ~= '1')
			else
				hideFrame:SetChecked(BC:getDB(key, 'hideFrame'))
			end
			hideFrame:Click()
		end

		if self[key].portraitCombat then self[key].portraitCombat:SetChecked(BC:getDB(key, 'portraitCombat')) end -- 头像上显示战斗信息
		if self[key].combatFlash then self[key].combatFlash:SetChecked(BC:getDB(key, 'combatFlash')) end -- 战斗状态边框红光
		if self[key].showThreat then self[key].showThreat:SetChecked(GetCVar('threatShowNumeric') == '1') end -- 显示威胁百分比
		if self[key].portraitClass then self[key].portraitClass:SetChecked(BC:getDB(key, 'portrait') == 1) end -- 头像显示职业图标(玩家)
		if self[key].miniIcon then self[key].miniIcon:SetChecked(BC:getDB(key, 'miniIcon')) end -- 显示小图标(职业/种类)
		if self[key].healthBarClass then self[key].healthBarClass:SetChecked(BC:getDB(key, 'healthBarClass')) end -- 体力条职业色(玩家)
		if self[key].statusBarClass then self[key].statusBarClass:SetChecked(BC:getDB(key, 'statusBarClass')) end -- 状态栏背景职业色(玩家)
		if self[key].statusBarAlpha then self[key].statusBarAlpha:SetValue(BC:getDB(key, 'statusBarAlpha')) end -- 状态栏透明度
		if self[key].nameFontSize then self[key].nameFontSize:SetValue(BC:getDB(key, 'nameFontSize')) end -- 名字字体大小
		if self[key].valueFontSize then self[key].valueFontSize:SetValue(BC:getDB(key, 'valueFontSize')) end -- 数值字体大小
		if self[key].valueStyleDown then self[key].valueStyle:OnShow() end -- 数值样式

		-- 隐藏名字
		local hideName = self[key].hideName
		if hideName then
			hideName:SetChecked(BC:getDB(key, 'hideName'))
			hideName:Click()
		end

		if self[key].drag then self[key].drag:SetChecked(BC:getDB(key, 'drag')) end -- 排战斗中按住Shift拖动

		-- 锚定玩家框体
		local anchor = self[key].anchor
		local scale = self[key].scale -- 框体缩放
		if anchor then
			anchor:SetChecked(BC:getDB(key, 'anchor') == 'PlayerFrame')
			if scale then scale:SetEnabled(BC:getDB(key, 'anchor') ~= 'PlayerFrame') end -- 框体缩放
		end

		if scale then scale:SetValue(BC:getDB(key, 'scale')) end -- 框体缩放
		if self[key].showEnemyBuff then self[key].showEnemyBuff:SetChecked(BC:getDB(key, 'showEnemyBuff')) end -- 显示敌对目标模拟Buff

		-- 只显示我施放的Buff/Debuff倒计时(OmniCC)
		local hasOmniCC = type(OmniCC) == 'table'
		if self[key].selfCooldown then
			self[key].selfCooldown:SetChecked(hasOmniCC and BC:getDB(key, 'selfCooldown'))
			self[key].selfCooldown:SetEnabled(hasOmniCC)
		end

		-- 只显示可以驱散的Buff/Debuff倒计时(OmniCC)
		if self[key].dispelCooldown then
			self[key].dispelCooldown:SetChecked(hasOmniCC and BC:getDB(key, 'dispelCooldown'))
			self[key].dispelCooldown:SetEnabled(hasOmniCC)
		end

		if self[key].dispelStealable then self[key].dispelStealable:SetChecked(BC:getDB(key, 'dispelStealable')) end -- 高亮显示可以驱散的Buff/Debuff

		if self[key].auraSize and BC:getDB(key, 'auraSize') then self[key].auraSize:SetValue(BC:getDB(key, 'auraSize')) end -- Buff/Debuff图标大小
		if self[key].auraRows and BC:getDB(key, 'auraRows') then self[key].auraRows:SetValue(BC:getDB(key, 'auraRows')) end -- 一行Buff/Debuff数量
		if self[key].auraX and BC:getDB(key, 'auraX') then self[key].auraX:SetValue(BC:getDB(key, 'auraX')) end -- Buff/Debuf X轴位置
		if self[key].auraY and BC:getDB(key, 'auraY') then self[key].auraY:SetValue(BC:getDB(key, 'auraY')) end -- Buff/Debuff Y轴位置
	end
end
option:RegisterEvent('PLAYER_ENTERING_WORLD')
option:SetScript('OnEvent', function(self, event)
	if event == 'PLAYER_ENTERING_WORLD' then self:init() end
end)

--[[ 全局设置 开始 ]]
option:title(option, addonName .. ' v' .. GetAddOnMetadata(addonName, 'Version'))
option.info = option:CreateFontString(option:GetName() .. 'Info', 'ARTWORK', 'SystemFont_Small')
option.info:SetPoint('TOPLEFT', 17, vertical - 6)
option.info:SetTextColor(.7, .7, .7)
option.info:SetText(L.info)

option:check('global', 'dark', 'title', -1, vertical - 8) -- 使用暗黑材质
option:check('global', 'newClassIcon', 'dark') -- 使用新职业图标
option:check('global', 'healthBarColor', 'newClassIcon') -- 体力条颜色按生命值变化
option:check('global', 'nameTextClassColor', 'healthBarColor') -- 名字颜色职业色(玩家)

-- 数值单位
option:check('global', 'carry', 'nameTextClassColor', nil, nil, nil, function(self)
	local slider = option.carrySlider
	if slider:IsVisible() then
		BC:setDB('global', 'carry', (self:GetChecked() and 0 or 2) + slider:GetValue())
		option.carrySlider:SetEnabled(self:GetChecked())
	else
		BC:setDB('global', 'carry', self:GetChecked() and 2 or 0)
	end
end)
option:slider('global', 'carrySlider', 'carry', 180, -4, 72, nil, L.carryK, L.carryW, 1, 2, 1, function(self, value)
	value = (option.carry:GetChecked() and 0 or 2) + value
	if value ~= BC:getDB('global', 'carry') then BC:setDB('global', 'carry', value) end
	self:SetObeyStepOnDrag(true)
end)

option:downMenu('global', 'nameFont', L.fontList, 'carry', 3, vertical - 4) -- 名字字体
option:downMenu('global', 'valueFont',  L.fontList, 'nameFont') -- 数值字体
option:downMenu('global', 'fontFlags', L.fontFlagsList, 'valueFont') -- 字体轮廓

-- 选择配置
option:downMenu('global', 'config', {
	[1] = {
		text = L.public,
		value = 'Public',
	},
	[2] = {
		text = UnitClass('player'),
		value = BC.class,
	},
	[3] = {
		text = BC.charKey,
		value = BC.charKey,
	},
}, nil, horizontal + 2, -18, 180, function(down, key, name, menus, width)
	UIDropDownMenu_Initialize(down, function()
		for i in pairs(menus) do
			local info = UIDropDownMenu_CreateInfo()
				info.text = menus[i].text
				info.value = menus[i].value
				info.func = function(self)
					BC:setDB('config', self.value)
					UIDropDownMenu_SetSelectedID(down, self:GetID())
					option:init()
				end
				UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetSelectedValue(down, BC:getDB('config'))
end)

-- 重置
option:button('global', 'reset', 'configDown', 218, -.5, 60, function()
	if InCombatLockdown() then
		print('|cffff0000'.. L['cantSaveInCombat'] .. '|r')
		return
	end

	BC:comfing(L.confirmResetDefault, function()
		if type(_G[addonName .. 'DB']) == 'table' then _G[addonName .. 'DB'][BC:getDB('config')] = nil end
		BC:init()
		SetCVar('alwaysCompareItems', '1')
		SetCVar('threatShowNumeric', '1')
		SetCVar('showTargetOfTarget', '1')
		option:init()
	end)
end)

hooksecurefunc('SetCVar', function(name, value)
	if name == 'alwaysCompareItems' then -- 启用装备对比
		option.alwaysCompareItems:SetChecked(value == '1')
	elseif name == 'threatShowNumeric' then
		option.target.showThreat:SetChecked(value == '1') -- 目标 显示威胁百分比
	elseif name == 'showTargetOfTarget' then -- 目标的目标 隐藏框体
		local hideFrame = option.targettarget.hideFrame
		hideFrame:SetChecked(value ~= '1')
		hideFrame:Click()
	end
end)

option:check('global', 'dragSystemFarmes', nil, horizontal, vertical - 39) -- 自由拖动系统框体
option:check('global', 'incomingHeals', 'dragSystemFarmes') -- 显示预治疗
option:check('global', 'autoTab', 'incomingHeals') -- PVP自动TAB选择玩家

-- 启用装备对比
option:check('global', 'alwaysCompareItems', 'autoTab', nil, nil, nil, function(self)
	SetCVar('alwaysCompareItems', self:GetChecked() and '1' or '0')
end)

-- 支持宝
option.alipay = option:CreateTexture()
option.alipay:SetTexture(BC.texture .. 'Alipay')
option.alipay:SetSize(128, 128)
option.alipay:SetPoint('BOTTOMRIGHT', option, -20, 20)
--[[ 全局设置 结束 ]]


--[[ 玩家设置 开始 ]]
option:check('player', 'portraitCombat', nil, 13, vertical - 8) -- 头像上显示战斗信息
option:check('player', 'combatFlash', 'portraitCombat') -- 战斗状态边框红光

-- 显示天赋小图标(点击切换天赋)
option:check('player', 'miniIcon', 'combatFlash', nil, nil, 'talentIcon', function(self)
	BC:setDB('player', 'miniIcon', self:GetChecked())
	option.player.autoTalentEquip:SetEnabled(self:GetChecked() and type(ItemRack) == 'table')
end)

option:check('player', 'autoTalentEquip', 'miniIcon', 15, vertical + 6) -- 切换天赋后装备套装(ItemRack)
option:check('player', 'equipmentIcon', 'autoTalentEquip', -15, vertical + 2) -- 显示装备小图标(ItemRack)
option:check('player', 'hidePartyNumber', 'equipmentIcon') -- 在团队中隐藏小队编号
option:check('player', 'powerSpark', 'hidePartyNumber') -- 显示法力/能量恢复闪动

-- 显示自定义德鲁伊法力条
option:check('player', 'druidBar', 'powerSpark')
option:check('player', 'healthBarClass', 'druidBar') -- 体力条职业色(玩家)
option:check('player', 'statusBarClass', 'healthBarClass') -- 状态栏背景职业色(玩家)

-- 名字字体大小
option:slider('player', 'nameFontSize', 'statusBarClass', 5, vertical - 16, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('player', 'nameFontSize') then BC:setDB('player', 'nameFontSize', value) end
	option.player.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
end)

-- 数值字体大小
option:slider('player', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('player', 'valueFontSize') then BC:setDB('player', 'valueFontSize', value) end
	option.player.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
end)

option:downMenu('player', 'valueStyle', L.valueStyleList, 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 恢复左上角位置
option:button('player', 'pointTargetLeftTop', nil, horizontal + 2, -20, nil, function()
	if InCombatLockdown() then
		print('|cffff0000'.. L['cantSaveInCombat'] .. '|r')
		return
	end

	BC:setDB('player', 'relative', 'TOPLEFT')
	BC:setDB('player', 'offsetX', -19)
	BC:setDB('player', 'offsetY', -4)
	BC:setDB('target', 'relative', 'TOPLEFT')
	if BC:getDB('target', 'anchor') then
		BC:setDB('target', 'offsetX', 299)
		BC:setDB('target', 'offsetY', 0)
	else
		BC:setDB('target', 'offsetX', 280)
		BC:setDB('target', 'offsetY', -4)
	end
	option.player.scale:SetValue(1)
	option.target.scale:SetValue(1)
end)

-- 恢复水平居中位置
option:button('player', 'pointTargetCenter', 'pointTargetLeftTop', 154, 0, nil, function()
	if InCombatLockdown() then
		print('|cffff0000'.. L['cantSaveInCombat'] .. '|r')
		return
	end

	BC:setDB('player', 'relative', 'CENTER')
	BC:setDB('player', 'offsetX', -223)
	BC:setDB('player', 'offsetY', -98)
	if BC:getDB('target', 'anchor') then
		BC:setDB('target', 'relative', 'TOPLEFT')
		BC:setDB('target', 'offsetX', 446)
		BC:setDB('target', 'offsetY', 0)
	else
		BC:setDB('target', 'relative', 'CENTER')
		BC:setDB('target', 'offsetX', 223)
		BC:setDB('target', 'offsetY', -98)
	end
	option.player.scale:SetValue(1)
	option.target.scale:SetValue(1)
end)

option:check('player', 'drag', 'pointTargetLeftTop', -2, vertical - 4) -- 非战斗中按住Shift左击拖动

-- 框体缩放
option:slider('player', 'scale', 'drag', 4, vertical - 16, nil, nil, '50%', '150%', .5, 1.5, .05, function(self, value)
	value = floor(value * 100 + .5)
	option.player.scaleText:SetText(L.scale .. ': ' .. value .. '%')
	value = value / 100
	if value ~= BC:getDB('player', 'scale') then BC:setDB('player', 'scale', value) end
end)

option:downMenu('player', 'border', L.borderList, 'scale', -1, vertical - 8) -- 边框
option:downMenu('player', 'portrait', L.portraitList, 'border') -- 头像
--[[ 玩家设置 结束 ]]


--[[ 宠物设置 开始 ]]
option:check('pet', 'portraitCombat', nil, 13, vertical - 8) -- 头像上显示战斗信息

-- 隐藏名字
option:check('pet', 'hideName', 'portraitCombat', nil, nil, nil, function(self)
	BC:setDB('pet', 'hideName', self:GetChecked())
	if option.pet.nameFontSize then option.pet.nameFontSize:SetEnabled(not self:GetChecked()) end
end)

-- 名字字体大小
option:slider('pet', 'nameFontSize', 'hideName', 5, vertical - 16, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('pet', 'nameFontSize') then BC:setDB('pet', 'nameFontSize', value) end
	option.pet.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
end)

-- 数值字体大小
option:slider('pet', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('pet', 'valueFontSize') then BC:setDB('pet', 'valueFontSize', value) end
	option.pet.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
end)

option:downMenu('pet', 'valueStyle', option:valueStyleList(1, 2, 3, 4), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 恢复默认位置
option:button('pet', 'pointDefault', nil, horizontal + 2, -20, nil, function()
	if InCombatLockdown() then
		print('|cffff0000'.. L['cantSaveInCombat'] .. '|r')
		return
	end

	BC:setDB('pet', 'point', nil)
	BC:setDB('pet', 'relative', nil)
	BC:setDB('pet', 'offsetX', nil)
	BC:setDB('pet', 'offsetY', nil)
end)

option:check('pet', 'drag', 'pointDefault', -2, vertical - 4) -- 非战斗中按住Shift左击拖动
--[[ 宠物设置 结束 ]]


--[[ 宠物的目标设置 开始 ]]

-- 隐藏框体
option:check('pettarget', 'hideFrame', nil, 13, vertical - 8, nil, function(self)
	local enabled = self:GetChecked()
	BC:setDB('pettarget', 'hideFrame', enabled)
	enabled = not enabled
	if option.pettarget.portraitClass then option.pettarget.portraitClass:SetEnabled(enabled) end
	if option.pettarget.healthBarClass then option.pettarget.healthBarClass:SetEnabled(enabled) end
	if option.pettarget.hideName then option.pettarget.hideName:SetEnabled(enabled) end
	if option.pettarget.nameFontSize then option.pettarget.nameFontSize:SetEnabled(enabled and not BC:getDB('pettarget', 'hideName')) end
	if option.pettarget.valueFontSize then option.pettarget.valueFontSize:SetEnabled(enabled) end
	if option.pettarget.valueStyle then option.pettarget.valueStyle:SetEnabled(enabled) end
end)

-- 头像显示职业图标(玩家)
option:check('pettarget', 'portraitClass', 'hideFrame', nil, nil, nil, function(self)
	BC:setDB('pettarget', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('pettarget', 'healthBarClass', 'portraitClass') -- 体力条职业色(玩家)

-- 隐藏名字
option:check('pettarget', 'hideName', 'healthBarClass', nil, nil, nil, function(self)
	BC:setDB('pettarget', 'hideName', self:GetChecked())
	if option.pettarget.nameFontSize then option.pettarget.nameFontSize:SetEnabled(not self:GetChecked()) end
end)

-- 名字字体大小
option:slider('pettarget', 'nameFontSize', 'hideName', 5, vertical - 16, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('pettarget', 'nameFontSize') then BC:setDB('pettarget', 'nameFontSize', value) end
	option.pettarget.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
end)

-- 数值字体大小
option:slider('pettarget', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('pettarget', 'valueFontSize') then BC:setDB('pettarget', 'valueFontSize', value) end
	option.pettarget.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
end)

option:downMenu('pettarget', 'valueStyle', option:valueStyleList(2, 3, 5, 7, 8), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式
--[[ 宠物的目标设置 结束 ]]


--[[ 目标设置 开始 ]]
option:check('target', 'portraitCombat', nil, 13, vertical - 8) -- 头像上显示战斗信息
option:check('target', 'combatFlash', 'portraitCombat') -- 战斗状态边框红光

-- 显示威胁百分比
option:check('target', 'showThreat', 'combatFlash', nil, nil, nil, function(self)
	SetCVar('threatShowNumeric', self:GetChecked() and '1' or '0')
end)

-- 头像显示职业图标(玩家)
option:check('target', 'portraitClass', 'showThreat', nil, nil, nil, function(self)
	BC:setDB('target', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('target', 'miniIcon', 'portraitClass') -- 显示职业小图标(玩家)/NPC种类小图标
option:check('target', 'healthBarClass', 'miniIcon') -- 体力条职业色(玩家)
option:check('target', 'statusBarClass', 'healthBarClass') -- 状态栏背景职业色(玩家)

-- 状态栏透明度
option:slider('target', 'statusBarAlpha', 'statusBarClass', 5, vertical - 16, nil, nil, '0', '1', 0, 1, .1, function(self, value)
	value = floor(value * 10 + 0.5)
	value = value / 10
	if value ~= BC:getDB('target', 'statusBarAlpha') then BC:setDB('target', 'statusBarAlpha', value) end
	option.target.statusBarAlphaText:SetText(L.statusBarAlpha .. ': ' .. value)
end)

-- 名字字体大小
option:slider('target', 'nameFontSize', 'statusBarAlpha', 0, vertical - 20, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('target', 'nameFontSize') then BC:setDB('target', 'nameFontSize', value) end
	option.target.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
end)

-- 数值字体大小
option:slider('target', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('target', 'valueFontSize') then BC:setDB('target', 'valueFontSize', value) end
	option.target.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
end)

option:downMenu('target', 'valueStyle', L.valueStyleList, 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 和玩家框体水平对齐
option:button('target', 'pointPlayerAlignment', nil, horizontal + 2, -20, 160, function()
	if InCombatLockdown() then
		print('|cffff0000'.. L['cantSaveInCombat'] .. '|r')
		return
	end

	option.player.scale:SetValue(1)
	option.target.scale:SetValue(1)
	if BC:getDB('target', 'anchor') then
		BC:setDB('target', 'offsetY', 0)
	else
		local relative = BC:getDB('player', 'relative')
		local offsetX
		if string.match(relative, 'LEFT') then
			offsetX = TargetFrame:GetLeft()
		elseif string.match(relative, 'RIGHT') then
			offsetX = TargetFrame:GetRight() - UIParent:GetWidth()
		else
			offsetX = TargetFrame:GetLeft() - (UIParent:GetWidth() - TargetFrame:GetWidth()) / 2
		end
		BC:setDB('target', 'relative', relative)
		BC:setDB('target', 'offsetX', floor(offsetX + .5))
		BC:setDB('target', 'offsetY', BC:getDB('player', 'offsetY'))
	end
end)

-- 和玩家框体水平居中
option:button('target', 'pointPlayerCenter', 'pointPlayerAlignment', 164, 0, 160, function()
	if InCombatLockdown() then
		print('|cffff0000'.. L['cantSaveInCombat'] .. '|r')
		return
	end

	option.player.scale:SetValue(1)
	option.target.scale:SetValue(1)
	local relative
	if BC:getDB('target', 'anchor') then
		relative = PlayerFrame:GetPoint()
		if string.match(relative, 'TOP') then
			relative = 'TOPLEFT'
		elseif string.match(relative, 'BOTTOM') then
			relative = 'BOTTOMLEFT'
		else
			relative = 'LEFT'
		end

		BC:setDB('player', 'relative', relative)
		BC:setDB('player', 'offsetX', floor(UIParent:GetWidth() - BC:getDB('target', 'offsetX') - TargetFrame:GetWidth() + 0.5)/2)
		BC:setDB('target', 'offsetY', 0)
	else
		relative = BC:getDB('player', 'relative')
		if string.match(relative, 'TOP') then
			relative = 'TOP'
		elseif string.match(relative, 'BOTTOM') then
			relative = 'BOTTOM'
		else
			relative = 'CENTER'
		end
		local offsetX = floor(PlayerFrame:GetLeft() / 2 - TargetFrame:GetLeft() / 2 + .5)
		BC:setDB('player', 'relative', relative)
		BC:setDB('player', 'offsetX', offsetX)
		BC:setDB('target', 'relative', relative)
		BC:setDB('target', 'offsetX', -offsetX)
		BC:setDB('target', 'offsetY', BC:getDB('player', 'offsetY'))
	end
end)

option:check('target', 'drag', 'pointPlayerAlignment', -2, vertical - 4) -- 非战斗中按住Shift左击拖动

-- 锚定玩家框体
option:check('target', 'anchor', 'drag', nil, nil, nil, function(self)
	local offsetX, offsetY
	if self:GetChecked() then
		offsetX = TargetFrame:GetLeft() - PlayerFrame:GetLeft()
		offsetY = TargetFrame:GetTop() - PlayerFrame:GetTop()
		option.target.scale:SetValue(1)
		option.target.scale:SetEnabled(false)
		BC:setDB('target', 'anchor', 'PlayerFrame')
	else
		offsetX = TargetFrame:GetLeft()
		offsetY = TargetFrame:GetTop() - UIParent:GetHeight()
		option.target.scale:SetEnabled(true)
		BC:setDB('target', 'anchor', nil)
	end
	BC:setDB('target', 'relative', 'TOPLEFT')
	BC:setDB('target', 'offsetX', floor(offsetX + .5))
	BC:setDB('target', 'offsetY', floor(offsetY + .5))
end)

-- 框体缩放
option:slider('target', 'scale', 'anchor', 5, vertical - 16, nil, nil, '50%', '150%', .5, 1.5, .05, function(self, value)
	value = floor(value * 100 + .5)
	option.target.scaleText:SetText(L.scale .. ': ' .. value .. '%')
	value = value / 100
	if value ~= BC:getDB('target', 'scale') then BC:setDB('target', 'scale', value) end
end)

option:check('target', 'showEnemyBuff', 'scale', -4, vertical - 8) -- 显示敌对目标模拟Buff
option:check('target', 'selfCooldown', 'showEnemyBuff') -- 只显示我施放的Buff/Debuff倒计时(OmniCC)
option:check('target', 'dispelCooldown', 'selfCooldown') -- 只显示可以驱散的Buff/Debuff倒计时(OmniCC)
option:check('target', 'dispelStealable', 'dispelCooldown') -- 高亮显示可以驱散的Buff/Debuff

-- Buff/Debuff图标大小
option:slider('target', 'auraSize', 'dispelStealable', 4, vertical - 20, nil, nil, 12, 64, 12, 64, 1, function(self, value)
	value = floor(value)
	option.target.auraSizeText:SetText(L.auraSize .. ': ' .. value)
	if value ~= BC:getDB('target', 'auraSize') then BC:setDB('target', 'auraSize', value) end
end)

-- 一行Buff/Debuff数量
option:slider('target', 'auraRows', 'auraSize', 0, vertical - 20, nil, nil, 1, 32, 1, 32, 1, function(self, value)
	value = floor(value)
	option.target.auraRowsText:SetText(L.auraRows .. ': ' .. value)
	if value ~= BC:getDB('target', 'auraRows') then BC:setDB('target', 'auraRows', value) end
end)

-- Buff/Debuf起始X轴位置
option:slider('target', 'auraX', 'auraRows', 0, vertical - 20, nil, nil, -256, 256, -256, 256, 1, function(self, value)
	value = floor(value)
	option.target.auraXText:SetText(L.auraX .. ': ' .. value)
	if value ~= BC:getDB('target', 'auraX') then BC:setDB('target', 'auraX', value) end
end)

-- Buff/Debuf起始Y轴位置
option:slider('target', 'auraY', 'auraX', 0, vertical - 20, nil, nil, -256, 256, -256, 256, 1, function(self, value)
	value = floor(value)
	option.target.auraYText:SetText(L.auraY .. ': ' .. value)
	if value ~= BC:getDB('target', 'auraY') then BC:setDB('target', 'auraY', value) end
end)
--[[ 目标设置 结束 ]]


--[[ 目标的目标设置 开始 ]]

-- 隐藏框体
option:check('targettarget', 'hideFrame', nil, 13, vertical - 8, nil, function(self)
	local enabled = not self:GetChecked()
	if (GetCVar('showTargetOfTarget') ~= '1') == enabled then
		SetCVar('showTargetOfTarget', enabled and '1' or '0')
	end
	option.targettarget.portraitClass:SetEnabled(enabled)
	option.targettarget.healthBarClass:SetEnabled(enabled)
	option.targettarget.hideName:SetEnabled(enabled)
	option.targettarget.nameFontSize:SetEnabled(enabled and not BC:getDB('targettarget', 'hideName'))
	option.targettarget.valueFontSize:SetEnabled(enabled)
	option.targettarget.valueStyle:SetEnabled(enabled)
	option.targettarget.pointDefault:SetEnabled(enabled)
	option.targettarget.drag:SetEnabled(enabled)
end)

-- 头像显示职业图标(玩家)
option:check('targettarget', 'portraitClass', 'hideFrame', nil, nil, nil, function(self)
	BC:setDB('targettarget', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('targettarget', 'healthBarClass', 'portraitClass') -- 体力条职业色(玩家)

-- 隐藏名字
option:check('targettarget', 'hideName', 'healthBarClass', nil, nil, nil, function(self)
	BC:setDB('targettarget', 'hideName', self:GetChecked())
	if option.targettarget.nameFontSize then option.targettarget.nameFontSize:SetEnabled(not self:GetChecked()) end
end)

-- 名字字体大小
option:slider('targettarget', 'nameFontSize', 'hideName', 5, vertical - 16, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.targettarget.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('targettarget', 'nameFontSize') then BC:setDB('targettarget', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('targettarget', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.targettarget.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('targettarget', 'valueFontSize') then BC:setDB('targettarget', 'valueFontSize', value) end
end)

option:downMenu('targettarget', 'valueStyle', option:valueStyleList(2, 3, 7, 8), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 恢复默认位置
option:button('targettarget', 'pointDefault', nil, horizontal + 2, -20, nil, function()
	if InCombatLockdown() then
		print('|cffff0000'.. L['cantSaveInCombat'] .. '|r')
		return
	end

	BC:setDB('targettarget', 'point', nil)
	BC:setDB('targettarget', 'relative', nil)
	BC:setDB('targettarget', 'offsetX', nil)
	BC:setDB('targettarget', 'offsetY', nil)
end)

option:check('targettarget', 'drag', 'pointDefault', -2, vertical - 4) -- 非战斗中按住Shift左击拖动
--[[ 目标的目标设置 结束 ]]


--[[ 队友设置 开始 ]]

 -- 隐藏框体
option:check('party', 'hideFrame', nil, 13, vertical - 8, nil, function(self)
	local enabled = self:GetChecked()
	BC:setDB('party', 'hideFrame', enabled)
	enabled = not enabled

	option.party.portraitCombat:SetEnabled(enabled)
	option.party.combatFlash:SetEnabled(enabled)
	option.party.healthBarClass:SetEnabled(enabled)
	option.party.portraitClass:SetEnabled(enabled)
	option.party.outRange:SetEnabled(enabled)
	option.party.raidShowParty:SetEnabled(enabled)
	option.party.showLevel:SetEnabled(enabled)
	option.party.showCastBar:SetEnabled(enabled)
	option.party.hideName:SetEnabled(enabled)
	option.party.nameFontSize:SetEnabled(enabled and not BC:getDB('party', 'hideName'))
	option.party.valueFontSize:SetEnabled(enabled)
	option.party.valueStyle:SetEnabled(enabled)

	option.party.pointDefault:SetEnabled(enabled)
	option.party.drag:SetEnabled(enabled)
	option.party.scale:SetEnabled(enabled)

	option.party.selfCooldown:SetEnabled(enabled)
	option.party.dispelCooldown:SetEnabled(enabled)
	option.party.dispelStealable:SetEnabled(enabled)
	option.party.auraSize:SetEnabled(enabled)
	option.party.auraRows:SetEnabled(enabled)
	option.party.auraX:SetEnabled(enabled)
	option.party.auraY:SetEnabled(enabled)
end)

option:check('party', 'portraitCombat', 'hideFrame') -- 头像上显示战斗信息
option:check('party', 'combatFlash', 'portraitCombat') -- 战斗状态边框红光
option:check('party', 'healthBarClass', 'combatFlash') -- 体力条职业色(玩家)

-- 头像显示职业图标(玩家)
option:check('party', 'portraitClass', 'healthBarClass', nil, nil, nil, function(self)
	BC:setDB('party', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('party', 'outRange', 'portraitClass') -- 超出范围半透明
option:check('party', 'raidShowParty', 'outRange') -- 团队显示小队框体
option:check('party', 'showLevel', 'raidShowParty') -- 显示等级
option:check('party', 'showCastBar', 'showLevel') -- 显示队友施法条

-- 隐藏名字
option:check('party', 'hideName', 'showCastBar', nil, nil, nil, function(self)
	BC:setDB('party', 'hideName', self:GetChecked())
	if option.party.nameFontSize then option.party.nameFontSize:SetEnabled(not self:GetChecked()) end
end)

-- 名字字体大小
option:slider('party', 'nameFontSize', 'hideName', 5, vertical - 16, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('party', 'nameFontSize') then BC:setDB('party', 'nameFontSize', value) end
	option.party.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
end)

-- 数值字体大小
option:slider('party', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('party', 'valueFontSize') then BC:setDB('party', 'valueFontSize', value) end
	option.party.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
end)

option:downMenu('party', 'valueStyle', L.valueStyleList, 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 恢复默认位置
option:button('party', 'pointDefault', nil, horizontal + 2, -20, nil, function()
	if InCombatLockdown() then
		print('|cffff0000'.. L['cantSaveInCombat'] .. '|r')
		return
	end

	BC:setDB('party', 'point', nil)
	BC:setDB('party', 'relative', nil)
	BC:setDB('party', 'offsetX', nil)
	BC:setDB('party', 'offsetY', nil)
end)

option:check('party', 'drag', 'pointDefault', -2, vertical - 4) -- 非战斗中按住Shift左击拖动

-- 框体缩放
option:slider('party', 'scale', 'drag', 5, vertical - 16, nil, nil, '50%', '150%', .5, 1.5, .05, function(self, value)
	value = floor(value * 100 + .5)
	option.party.scaleText:SetText(L.scale .. ': ' .. value .. '%')
	value = value / 100
	if value ~= BC:getDB('party', 'scale') then BC:setDB('party', 'scale', value) end
end)

option:check('party', 'selfCooldown', 'scale', -4, vertical - 8, 'buffCooldown') -- 只显示我施放的Buff倒计时(OmniCC)
option:check('party', 'dispelCooldown', 'selfCooldown', nil, nil, 'debuffCooldown') -- 只显示可以驱散的Debuff倒计时(OmniCC)
option:check('party', 'dispelStealable', 'dispelCooldown', nil, nil, 'debuffStealable') -- 高亮显示可以驱散的Debuff

-- Buff/Debuff图标大小
option:slider('party', 'auraSize', 'dispelStealable', 5, vertical - 16, nil, nil, 12, 64, 12, 64, 1, function(self, value)
	value = floor(value + .5)
	option.party.auraSizeText:SetText(L.auraSize .. ': ' .. value)
	if value ~= BC:getDB('party', 'auraSize') then BC:setDB('party', 'auraSize', value) end
end)

-- 一行Buff/Debuff数量
option:slider('party', 'auraRows', 'auraSize', 0, vertical - 20, nil, nil, 8, 32, 8, 32, 1, function(self, value)
	value = floor(value + .5)
	option.party.auraRowsText:SetText(L.auraRows .. ': ' .. value)
	if value ~= BC:getDB('party', 'auraRows') then BC:setDB('party', 'auraRows', value) end
end)

-- Buff/Debuf起始X轴位置
option:slider('party', 'auraX', 'auraRows', 0, vertical - 20, nil, nil, -256, 256, -256, 256, 1, function(self, value)
	value = floor(value + .5)
	if value ~= BC:getDB('party', 'auraX') then BC:setDB('party', 'auraX', value) end
	option.party.auraXText:SetText(L.auraX .. ': ' .. value)
end)

-- Buff/Debuf起始Y轴位置
option:slider('party', 'auraY', 'auraX', 0, vertical - 20, nil, nil, -256, 256, -256, 256, 1, function(self, value)
	value = floor(value + .5)
	if value ~= BC:getDB('party', 'auraY') then BC:setDB('party', 'auraY', value) end
	option.party.auraYText:SetText(L.auraY .. ': ' .. value)
end)
--[[ 队友设置 结束 ]]


--[[ 队友的宠物设置 开始 ]]

-- 隐藏框体
option:check('partypet', 'hideFrame', nil, 13, vertical - 8, nil, function(self)
	local enabled = not self:GetChecked()
	BC:setDB('partypet', 'hideFrame', not enabled)
	option.partypet.hideName:SetEnabled(enabled)
	option.partypet.nameFontSize:SetEnabled(enabled and not BC:getDB('partypet', 'hideName'))
	option.partypet.valueFontSize:SetEnabled(enabled)
	option.partypet.valueStyle:SetEnabled(enabled)
end)

-- 隐藏名字
option:check('partypet', 'hideName', 'hideFrame', nil, nil, nil, function(self)
	BC:setDB('partypet', 'hideName', self:GetChecked())
	if option.partypet.nameFontSize then option.partypet.nameFontSize:SetEnabled(not self:GetChecked()) end
end)

-- 名字字体大小
option:slider('partypet', 'nameFontSize', 'hideName', 5, vertical - 16, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('partypet', 'nameFontSize') then BC:setDB('partypet', 'nameFontSize', value) end
	option.partypet.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
end)

-- 数值字体大小
option:slider('partypet', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('partypet', 'valueFontSize') then BC:setDB('partypet', 'valueFontSize', value) end
	option.partypet.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
end)

option:downMenu('partypet', 'valueStyle', option:valueStyleList(2, 3, 5, 7, 8), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式
--[[ 队友的宠物设置 结束 ]]


--[[ 队友目标的设置 开始 ]]

-- 隐藏框体
option:check('partytarget', 'hideFrame', nil, 13, vertical - 8, nil, function(self)
	local enabled = not self:GetChecked()
	BC:setDB('partytarget', 'hideFrame', not enabled)
	option.partytarget.portraitClass:SetEnabled(enabled)
	option.partytarget.healthBarClass:SetEnabled(enabled)
	option.partytarget.hideName:SetEnabled(enabled)
	option.partytarget.nameFontSize:SetEnabled(enabled and not BC:getDB('partytarget', 'hideName'))
	option.partytarget.valueFontSize:SetEnabled(enabled)
	option.partytarget.valueStyle:SetEnabled(enabled)
end)

-- 头像显示职业图标(玩家)
option:check('partytarget', 'portraitClass', 'hideFrame', nil, nil, nil, function(self)
	BC:setDB('partytarget', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('partytarget', 'healthBarClass', 'portraitClass') -- 体力条职业色(玩家)

-- 隐藏名字
option:check('partytarget', 'hideName', 'healthBarClass', nil, nil, nil, function(self)
	BC:setDB('partytarget', 'hideName', self:GetChecked())
	if option.partytarget.nameFontSize then option.partytarget.nameFontSize:SetEnabled(not self:GetChecked()) end
end)

-- 名字字体大小
option:slider('partytarget', 'nameFontSize', 'hideName', 5, vertical - 16, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('partytarget', 'nameFontSize') then BC:setDB('partytarget', 'nameFontSize', value) end
	option.partytarget.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
end)

-- 数值字体大小
option:slider('partytarget', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	if value ~= BC:getDB('partytarget', 'valueFontSize') then BC:setDB('partytarget', 'valueFontSize', value) end
	option.partytarget.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
end)

option:downMenu('partytarget', 'valueStyle', option:valueStyleList(2, 3, 5, 7, 8), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式
--[[ 队友目标的设置 结束 ]]
