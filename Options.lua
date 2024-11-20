local addonName = ...
local BC = _G[addonName]
local L = _G[addonName .. 'Locale']
local isZh = GetLocale() == 'zhCN' or GetLocale() == 'zhTW'
local vertical = -31
local horizontal = 322
local option = CreateFrame('Frame', addonName .. 'Option')
option.name = addonName
InterfaceOptions_AddCategory(option)

-- 命令行
SlashCmdList[addonName] = function()
	InterfaceOptionsFrame:Show() -- 界面设置
	InterfaceOptionsFrame_OpenToCategory(option)
end
_G['SLASH_' .. addonName .. '1'] = '/bc'

option.list = {
	'player',
	'pet',
	'pettarget',
	'target',
	'targettarget',
	'focus',
	'focustarget',
	'party',
	'partypet',
	'partytarget',
}

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
	parent[name] = CreateFrame('CheckButton', parent:GetName() .. name:gsub('^%l', string.upper), parent, 'InterfaceOptionsCheckButtonTemplate')
	parent[name]:SetPoint('TOPLEFT', relative and parent[relative] or parent, 'TOPLEFT', offsetX or 0, offsetY or vertical)
	_G[parent[name]:GetName() .. 'Text']:SetText(L[text or name])
	parent[name]:SetScript('OnClick', type(click) == 'function' and click or function(self)
		BC:setDB(key, name, self:GetChecked())
	end)
end

-- 拖动
function option:slider(key, name, relative, offsetX, offsetY, widht, height, lowText, highText, valueMin, valueMax, valueStep, change)
	local parent = key == 'global' and self or self[key]
	parent[name] = CreateFrame('Slider',  parent:GetName() .. name:gsub('^%l', string.upper), parent, 'OptionsSliderTemplate')
	parent[name]:SetPoint('TOPLEFT', relative and parent[relative] or parent, 'TOPLEFT', offsetX or 0, offsetY or vertical)
	parent[name]:SetSize(widht or 180, height or 16)
	_G[parent[name]:GetName() .. 'Low']:SetText(lowText)
	_G[parent[name]:GetName() .. 'High']:SetText(highText)
	parent[name]:SetMinMaxValues(valueMin, valueMax)
	parent[name]:SetValueStep(valueStep)
	parent[name .. 'Text'] = parent:CreateFontString(parent:GetName() .. name:gsub('^%l', string.upper) .. 'Text', 'ARTWORK', 'GameFontNormalSmall')
	parent[name .. 'Text']:SetPoint('CENTER', parent[name], 'CENTER', 0, 16)
	if type(change) == 'function' then parent[name]:SetScript('OnValueChanged', change) end
end

-- 下拉菜单选项初始化
function option:downMenuInit(down, key, name, menus, width)
	local text = _G[down:GetName()..'Text']
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
				UIDropDownMenu_SetSelectedID(down, self:GetID())
				setFont(self.value)
				BC:setDB(key, name, self.value)
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
	parent[name .. 'Down']:SetPoint('TOPLEFT', parent[name], 'TOPLEFT', -18, -16)
	parent[name .. 'Down'].OnShow = function(self)
		if type(show) == 'function' then
			show(self, key, name, menus)
		else
			option:downMenuInit(self, key, name, menus)
		end
		UIDropDownMenu_SetWidth(self, width and width or (isZh and 120 or 200))
	end
end

-- 按钮
function option:button(key, name, relative, offsetX, offsetY, width, click)
	local parent = key == 'global' and self or self[key]
	parent[name] = CreateFrame('Button', parent:GetName() .. name:gsub('^%l', string.upper), parent, 'OptionsButtonTemplate')
	parent[name]:SetPoint('TOPLEFT', relative and parent[relative] or parent, 'TOPLEFT', offsetX or 0, offsetY or 0)
	parent[name]:SetSize(width or 150, 25)
	_G[parent[name]:GetName() .. 'Text']:SetText(L[name])
	if type(click) == 'function' then parent[name]:SetScript('OnClick', click) end
end

for _, name in pairs(option.list) do
	option[name] = CreateFrame('Frame', option:GetName() .. name:gsub('^%l', string.upper))
	option[name].name = L[name]
	option[name].parent = addonName
	InterfaceOptions_AddCategory(option[name])
	option:title(option[name], L[name]:gsub('[├├─└─]', ''))
end

-- 初始设置
function option:init()
	self.dark:SetChecked(BC:getDB('global', 'dark')) -- 使用暗黑材质
	self.newClassIcon:SetChecked(BC:getDB('global', 'newClassIcon')) -- 使用新职业图标
	self.healthBarColor:SetChecked(BC:getDB('global', 'healthBarColor')) -- 体力条颜色按生命值变化
	self.nameTextClassColor:SetChecked(BC:getDB('global', 'nameTextClassColor')) -- 名字颜色职业色(玩家)

	-- 数值单位
	local carry = BC:getDB('global', 'carry')
	local carryCheck = carry == 2 or carry == 1
	self.carry:SetChecked(carryCheck)
	if isZh then
		self.carrySlider:Show()
		self.carrySlider:SetValue(carryCheck and carry or carry - 2)
		if carry == 1 or carry == 2 then
			BlizzardOptionsPanel_Slider_Enable(self.carrySlider)
		else
			BlizzardOptionsPanel_Slider_Disable(self.carrySlider)
		end
	else
		self.carrySlider:Hide()
	end

	self.nameFontDown:OnShow() -- 名字字体
	self.valueFontDown:OnShow() -- 数值字体
	self.fontFlagsDown:OnShow() -- 字体轮廓
	self.configDown:OnShow() -- 选择配置

	self.dragSystemFarmes:SetChecked(BC:getDB('global', 'dragSystemFarmes')) -- 自由拖动系统框体
	self.incomingHeals:SetChecked(BC:getDB('global', 'incomingHeals')) -- 显示预配治疗
	self.autoTab:SetChecked(BC:getDB('global', 'autoTab')) -- PVP自动TAB选择玩家
	self.autoNameplate:SetChecked(BC:getDB('global', 'autoNameplate')) -- 进入达拉然自动关闭姓名板
	self.alwaysCompareItems:SetChecked(GetCVar('alwaysCompareItems') == '1') -- 启用装备对比

	-- 显示天赋小图标(点击切换天赋)
	if BC:getDB('player', 'miniIcon') then
		BlizzardOptionsPanel_CheckButton_Enable(option.player.autoTalentEquip)
		_G[option.player.autoTalentEquip:GetName() .. 'Text']:SetTextColor(1, 1, 1)
	else
		BlizzardOptionsPanel_CheckButton_Disable(option.player.autoTalentEquip)
	end

	self.player.autoTalentEquip:SetChecked(BC:getDB('player', 'autoTalentEquip')) -- 切换天赋后自动装备对应套装
	self.player.equipmentIcon:SetChecked(BC:getDB('player', 'equipmentIcon')) -- 显示装备小图标(最多6个)
	self.player.hidePartyNumber:SetChecked(BC:getDB('player', 'hidePartyNumber')) -- 在团队中隐藏小队编号

	-- 在法力条上显示5秒恢复提示
	if BC.class == 'WARRIOR' or BC.class == 'ROGUE' or BC.class == 'DEATHKNIGHT' then
		self.player.fiveSecondRule:SetChecked(false)
		BlizzardOptionsPanel_CheckButton_Disable(self.player.fiveSecondRule)
	else
		BlizzardOptionsPanel_CheckButton_Enable(self.player.fiveSecondRule)
		_G[self.player.fiveSecondRule:GetName() .. 'Text']:SetTextColor(1, 1, 1)
		self.player.fiveSecondRule:SetChecked(BC:getDB('player', 'fiveSecondRule'))
	end

	-- 显示自定义德鲁伊法力条
	if BC.class == 'DRUID' then
		self.player.druidBar:SetChecked(BC:getDB('player', 'druidBar'))
		self.player.druidBarEnergy:SetChecked(BC:getDB('player', 'druidBarEnergy'))
		if BC:getDB('player', 'druidBar') then
			BlizzardOptionsPanel_CheckButton_Enable(self.player.druidBarEnergy)
			_G[self.player.druidBarEnergy:GetName() .. 'Text']:SetTextColor(1, 1, 1)
		else
			BlizzardOptionsPanel_CheckButton_Disable(self.player.druidBarEnergy)
		end
	else
		self.player.druidBar:SetChecked(false)
		self.player.druidBarEnergy:SetChecked(false)
		BlizzardOptionsPanel_CheckButton_Disable(self.player.druidBar)
		BlizzardOptionsPanel_CheckButton_Disable(self.player.druidBarEnergy)
	end

	self.player.borderDown:OnShow() -- 边框
	self.player.portraitDown:OnShow() -- 头像

	self.party.outRange:SetChecked(BC:getDB('party', 'outRange')) -- 超出范围半透明
	self.party.raidShowParty:SetChecked(BC:getDB('party', 'raidShowParty')) -- 团队显示小队框体
	self.party.showLevel:SetChecked(BC:getDB('party', 'showLevel')) -- 显示等级
	self.party.showCastBar:SetChecked(BC:getDB('party', 'showCastBar')) -- 显示施法条

	for _, key in pairs(option.list) do
		if self[key].hideFrame then self[key].hideFrame:SetChecked(BC:getDB(key, 'hideFrame')) end -- 隐藏框体
		if self[key].portraitCombat then self[key].portraitCombat:SetChecked(BC:getDB(key, 'portraitCombat')) end -- 头像上显示战斗信息
		if self[key].combatFlash then self[key].combatFlash:SetChecked(BC:getDB(key, 'combatFlash')) end -- 战斗状态边框红光
		if self[key].portraitClass then self[key].portraitClass:SetChecked(BC:getDB(key, 'portrait') == 1) end -- 头像显示职业图标(玩家)
		if self[key].miniIcon then self[key].miniIcon:SetChecked(BC:getDB(key, 'miniIcon')) end -- 显示小图标(职业/种类)
		if self[key].threatLeft then self[key].threatLeft:SetChecked(BC:getDB(key, 'threatLeft')) end -- 居左显示威胁值
		if self[key].healthBarClass then self[key].healthBarClass:SetChecked(BC:getDB(key, 'healthBarClass')) end -- 体力条职业色(玩家)
		if self[key].statusBarClass then self[key].statusBarClass:SetChecked(BC:getDB(key, 'statusBarClass')) end -- 状态栏背景职业色(玩家)
		if self[key].statusBarAlpha then self[key].statusBarAlpha:SetValue(BC:getDB(key, 'statusBarAlpha')) end -- 状态栏透明度
		if self[key].nameFontSize then self[key].nameFontSize:SetValue(BC:getDB(key, 'nameFontSize')) end -- 名字字体大小
		if self[key].valueFontSize then self[key].valueFontSize:SetValue(BC:getDB(key, 'valueFontSize')) end -- 数值字体大小
		if self[key].valueStyleDown then self[key].valueStyleDown:OnShow() end -- 数值样式

		-- 隐藏名字
		if self[key].hideName then
			self[key].hideName:SetChecked(BC:getDB(key, 'hideName'))
			if BC:getDB(key, 'hideName') then
				self[key].nameFontSizeText:SetTextColor(.5, .5, .5)
				BlizzardOptionsPanel_Slider_Disable(self[key].nameFontSize)
			else
				self[key].nameFontSizeText:SetTextColor(1, .82, 0)
				BlizzardOptionsPanel_Slider_Enable(self[key].nameFontSize)
			end
		end

		if self[key].drag then self[key].drag:SetChecked(BC:getDB(key, 'drag')) end -- 排战斗中按住Shift拖动

		-- 锚定玩家框体
		if self[key].anchor then
			local anchor = BC:getDB(key, 'anchor') == 'PlayerFrame'
			self[key].anchor:SetChecked(anchor)
			local scale = self[key].scale
			if anchor then
				scale:SetValue(1)
				self[key].scaleText:SetTextColor(.5, .5, .5)
				BlizzardOptionsPanel_Slider_Disable(scale)
			else
				self[key].scaleText:SetTextColor(1, .82, 0)
				BlizzardOptionsPanel_Slider_Enable(scale)
			end
		end

		if self[key].scale then self[key].scale:SetValue(BC:getDB(key, 'scale')) end -- 框体缩放
		if self[key].selfCooldown then self[key].selfCooldown:SetChecked(BC:getDB(key, 'selfCooldown')) end -- 只显示我施放的Buff/Debuff倒计时(OmniCC)
		if self[key].dispelCooldown then self[key].dispelCooldown:SetChecked(BC:getDB(key, 'dispelCooldown')) end -- 只显示可以驱散的Buff/Debuff倒计时(OmniCC)
		if self[key].dispelStealable then self[key].dispelStealable:SetChecked(BC:getDB(key, 'dispelStealable')) end -- 高亮显示可以驱散的Buff/Debuff

		if self[key].auraSize and BC:getDB(key, 'auraSize') then self[key].auraSize:SetValue(BC:getDB(key, 'auraSize')) end -- Buff/Debuff图标大小
		if self[key].auraRows and BC:getDB(key, 'auraRows') then self[key].auraRows:SetValue(BC:getDB(key, 'auraRows')) end -- 一行Buff/Debuff数量
		if self[key].auraX and BC:getDB(key, 'auraX') then self[key].auraX:SetValue(BC:getDB(key, 'auraX')) end -- Buff/Debuf X轴位置
		if self[key].auraY and BC:getDB(key, 'auraY') then self[key].auraY:SetValue(BC:getDB(key, 'auraY')) end -- Buff/Debuff Y轴位置
	end
end
option:RegisterEvent('VARIABLES_LOADED')
option:SetScript('OnEvent', function(self, event)
	if event == 'VARIABLES_LOADED' then self:init() end
end)

--[[ 全局设置 开始 ]]
option:title(option, addonName .. '_' .. GetAddOnMetadata(addonName, 'Version'))
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
		if option.carry:GetChecked() then
			BlizzardOptionsPanel_Slider_Enable(slider)
		else
			BlizzardOptionsPanel_Slider_Disable(slider)
		end
		BC:setDB('global', 'carry', (self:GetChecked() and 0 or 2) + slider:GetValue())
	else
		BC:setDB('global', 'carry', self:GetChecked() and 2 or 0)
	end
end)
option:slider('global', 'carrySlider', 'carry', 120, -4, 72, nil, L.carryK, L.carryW, 1, 2, 1, function(self, value)
	self:SetObeyStepOnDrag(true)
	value = (option.carry:GetChecked() and 0 or 2) + value
	if value ~= BC:getDB('global', 'carry') then
		BC:setDB('global', 'carry', value)
	end
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
	if type(_G[addonName .. 'DB']) == 'table' then _G[addonName .. 'DB'][BC:getDB('config')] = nil end
	option:init()
	BC:init()
end)

option:check('global', 'dragSystemFarmes', nil, horizontal, vertical - 39) -- 自由拖动系统框体
option:check('global', 'incomingHeals', 'dragSystemFarmes') -- 显示预治疗
option:check('global', 'autoTab', 'incomingHeals') -- PVP自动TAB选择玩家
option:check('global', 'autoNameplate', 'autoTab') -- 进入达拉然自动关闭姓名板

-- 启用装备对比
option:check('global', 'alwaysCompareItems', 'autoNameplate', nil, nil, nil, function(self)
	SetCVar('alwaysCompareItems', self:GetChecked() and '1' or '0')
end)

-- 支持宝
option.alipay = option:CreateTexture()
option.alipay:SetTexture(BC.texture .. 'Alipay')
option.alipay:SetSize(128, 128)
option.alipay:SetPoint('BOTTOMRIGHT', option, 'BOTTOMRIGHT', -20, 20)

--[[ 全局设置 结束 ]]

--[[ 玩家设置 开始 ]]
option:check('player', 'portraitCombat', nil, 13, vertical - 8) -- 头像上显示战斗信息
option:check('player', 'combatFlash', 'portraitCombat') -- 战斗状态边框红光

-- 显示天赋小图标(点击切换天赋)
option:check('player', 'miniIcon', 'combatFlash', nil, nil, 'talentIcon', function(self)
	if self:GetChecked() then
		BlizzardOptionsPanel_CheckButton_Enable(option.player.autoTalentEquip)
		_G[option.player.autoTalentEquip:GetName() .. 'Text']:SetTextColor(1, 1, 1)
	else
		BlizzardOptionsPanel_CheckButton_Disable(option.player.autoTalentEquip)
	end
	BC:setDB('player', 'miniIcon', self:GetChecked())
end)

option:check('player', 'autoTalentEquip', 'miniIcon', 15, vertical + 6) -- 切换天赋后自动装备对应套装
option:check('player', 'equipmentIcon', 'autoTalentEquip', -15, vertical + 2) -- 显示装备小图标(最多6个)
option:check('player', 'hidePartyNumber', 'equipmentIcon') -- 在团队中隐藏小队编号
option:check('player', 'fiveSecondRule', 'hidePartyNumber') -- 在法力条上显示5秒回蓝

-- 显示自定义德鲁伊法力条
option:check('player', 'druidBar', 'fiveSecondRule', nil, nil, nil, function(self)
	if self:GetChecked() then
		BlizzardOptionsPanel_CheckButton_Enable(option.player.druidBarEnergy)
		_G[option.player.druidBarEnergy:GetName() .. 'Text']:SetTextColor(1, 1, 1)
	else
		BlizzardOptionsPanel_CheckButton_Disable(option.player.druidBarEnergy)
	end
	BC:setDB('player', 'druidBar', self:GetChecked())
end)

option:check('player', 'druidBarEnergy', 'druidBar', 15, vertical + 6) -- 熊形态下显示能量条
option:check('player', 'healthBarClass', 'druidBarEnergy', -15, vertical + 2) -- 体力条职业色(玩家)
option:check('player', 'statusBarClass', 'healthBarClass') -- 状态栏背景职业色(玩家)

-- 名字字体大小
option:slider('player', 'nameFontSize', 'statusBarClass', 5, vertical - 20, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	option.player.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('player', 'nameFontSize') then BC:setDB('player', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('player', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	option.player.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('player', 'valueFontSize') then BC:setDB('player', 'valueFontSize', value) end
end)

option:downMenu('player', 'valueStyle', L.valueStyleList, 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 恢复左上角位置
option:button('player', 'pointTargetLeftTop', nil, horizontal + 2, -20, nil, function()
	option.player.scale:SetValue(1)
	option.target.scale:SetValue(1)
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
end)

-- 恢复水平居中位置
option:button('player', 'pointTargetCenter', 'pointTargetLeftTop', 154, 0, nil, function()
	option.player.scale:SetValue(1)
	option.target.scale:SetValue(1)
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
end)

option:check('player', 'drag', 'pointTargetLeftTop', -2, vertical - 4) -- 非战斗中按住Shift左击拖动

-- 框体缩放
option:slider('player', 'scale', 'drag', 4, vertical - 20, nil, nil, '50%', '150%', .5, 1.5, .05, function(self, value)
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
	if self:GetChecked() then
		option.pet.nameFontSizeText:SetTextColor(.5, .5, .5)
		BlizzardOptionsPanel_Slider_Disable(option.pet.nameFontSize)
	else
		option.pet.nameFontSizeText:SetTextColor(1, .82, 0)
		BlizzardOptionsPanel_Slider_Enable(option.pet.nameFontSize)
	end
	BC:setDB('pet', 'hideName', self:GetChecked())
end)

-- 名字字体大小
option:slider('pet', 'nameFontSize', 'hideName', 5, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.pet.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('pet', 'nameFontSize') then BC:setDB('pet', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('pet', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.pet.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('pet', 'valueFontSize') then BC:setDB('pet', 'valueFontSize', value) end
end)

option:downMenu('pet', 'valueStyle', option:valueStyleList(1, 2, 3, 4), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 恢复默认位置
option:button('pet', 'pointDefault', nil, horizontal + 2, -20, nil, function()
	BC:setDB('pet', 'point', nil)
	BC:setDB('pet', 'relative', nil)
	BC:setDB('pet', 'offsetX', nil)
	BC:setDB('pet', 'offsetY', nil)
end)

option:check('pet', 'drag', 'pointDefault', -2, vertical - 4) -- 非战斗中按住Shift左击拖动
--[[ 宠物设置 结束 ]]

--[[ 宠物的目标设置 开始 ]]
option:check('pettarget', 'hideFrame', nil, 13, vertical - 8) -- 隐藏框体

-- 头像显示职业图标(玩家)
option:check('pettarget', 'portraitClass', 'hideFrame', nil, nil, nil, function(self)
	BC:setDB('pettarget', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('pettarget', 'healthBarClass', 'portraitClass') -- 体力条职业色(玩家)

-- 隐藏名字
option:check('pettarget', 'hideName', 'healthBarClass', nil, nil, nil, function(self)
	if self:GetChecked() then
		option.pettarget.nameFontSizeText:SetTextColor(.5, .5, .5)
		BlizzardOptionsPanel_Slider_Disable(option.pettarget.nameFontSize)
	else
		option.pettarget.nameFontSizeText:SetTextColor(1, .82, 0)
		BlizzardOptionsPanel_Slider_Enable(option.pettarget.nameFontSize)
	end
	BC:setDB('pettarget', 'hideName', self:GetChecked())
end)

-- 名字字体大小
option:slider('pettarget', 'nameFontSize', 'hideName', 5, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.pettarget.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('pettarget', 'nameFontSize') then BC:setDB('pettarget', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('pettarget', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.pettarget.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('pettarget', 'valueFontSize') then BC:setDB('pettarget', 'valueFontSize', value) end
end)

option:downMenu('pettarget', 'valueStyle', option:valueStyleList(2, 3, 5, 7, 8), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式
--[[ 宠物的目标设置 结束 ]]

--[[ 目标设置 开始 ]]
option:check('target', 'portraitCombat', nil, 13, vertical - 8) -- 头像上显示战斗信息
option:check('target', 'combatFlash', 'portraitCombat') -- 战斗状态边框红光

-- 头像显示职业图标(玩家)
option:check('target', 'portraitClass', 'combatFlash', nil, nil, nil, function(self)
	BC:setDB('target', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('target', 'miniIcon', 'portraitClass') -- 显示职业小图标(玩家)/NPC种类小图标
option:check('target', 'threatLeft', 'miniIcon') -- 居左显示威胁值
option:check('target', 'healthBarClass', 'threatLeft') -- 体力条职业色(玩家)
option:check('target', 'statusBarClass', 'healthBarClass') -- 状态栏背景职业色(玩家)

-- 状态栏透明度
option:slider('target', 'statusBarAlpha', 'statusBarClass', 5, vertical - 20, nil, nil, '0', '1', 0, 1, .1, function(self, value)
	value = floor(value * 10 + 0.5)
	value = value / 10
	option.target.statusBarAlphaText:SetText(L.statusBarAlpha .. ': ' .. value)
	if value ~= BC:getDB('target', 'statusBarAlpha') then BC:setDB('target', 'statusBarAlpha', value) end
end)

-- 名字字体大小
option:slider('target', 'nameFontSize', 'statusBarAlpha', 0, vertical - 20, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	option.target.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('target', 'nameFontSize') then BC:setDB('target', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('target', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	option.target.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('target', 'valueFontSize') then BC:setDB('target', 'valueFontSize', value) end
end)

option:downMenu('target', 'valueStyle', L.valueStyleList, 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 和玩家框体水平对齐
option:button('target', 'pointPlayerAlignment', nil, horizontal + 2, -20, 160, function()
	option.player.scale:SetValue(1)
	option.target.scale:SetValue(1)
	if BC:getDB('target', 'anchor') then
		BC:setDB('target', 'offsetY', 0)
	else
		local relative = BC:getDB('player', 'relative')
		local offsetX
		if string.match(relative, 'LEFT') then
			offsetX = BC.target:GetLeft()
		elseif string.match(relative, 'RIGHT') then
			offsetX = BC.target:GetRight() - UIParent:GetWidth()
		else
			offsetX = BC.target:GetLeft() - (UIParent:GetWidth() - BC.target:GetWidth()) / 2
		end
		BC:setDB('target', 'relative', relative)
		BC:setDB('target', 'offsetX', floor(offsetX + .5))
		BC:setDB('target', 'offsetY', BC:getDB('player', 'offsetY'))
	end
end)

-- 和玩家框体水平居中
option:button('target', 'pointPlayerCenter', 'pointPlayerAlignment', 164, 0, 160, function()
	option.player.scale:SetValue(1)
	option.target.scale:SetValue(1)
	local relative
	if BC:getDB('target', 'anchor') then
		relative = BC.player:GetPoint()
		if string.match(relative, 'TOP') then
			relative = 'TOPLEFT'
		elseif string.match(relative, 'BOTTOM') then
			relative = 'BOTTOMLEFT'
		else
			relative = 'LEFT'
		end

		BC:setDB('player', 'relative', relative)
		BC:setDB('player', 'offsetX', floor(UIParent:GetWidth() - BC:getDB('target', 'offsetX') - BC.target:GetWidth() + 0.5)/2)
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
		local offsetX = floor(BC.player:GetLeft() / 2 - BC.target:GetLeft() / 2 + .5)
		BC:setDB('player', 'relative', relative)
		BC:setDB('player', 'offsetX', offsetX)
		BC:setDB('target', 'relative', relative)
		BC:setDB('target', 'offsetX', -offsetX)
		BC:setDB('target', 'offsetY', BC:getDB('player', 'offsetY'))
	end
end)

option:check('target', 'drag', 'pointPlayerAlignment', -2, vertical - 4) -- 非战斗中按住Shift左击拖动

-- 锚定玩家位置
option:check('target', 'anchor', 'drag', nil, nil, nil, function(self)
	local offsetX, offsetY
	if self:GetChecked() then
		offsetX = BC.target:GetLeft() - BC.player:GetLeft()
		offsetY = BC.target:GetTop() - BC.player:GetTop()
		option.target.scale:SetValue(1)
		option.target.scaleText:SetTextColor(.5, .5, .5)
		BlizzardOptionsPanel_Slider_Disable(option.target.scale)
		BC:setDB('target', 'anchor', 'PlayerFrame')
	else
		offsetX = BC.target:GetLeft()
		offsetY = BC.target:GetTop() - UIParent:GetHeight()
		option.target.scaleText:SetTextColor(1, .82, 0)
		BlizzardOptionsPanel_Slider_Enable(option.target.scale)
		BC:setDB('target', 'anchor', nil)
	end
	BC:setDB('target', 'relative', 'TOPLEFT')
	BC:setDB('target', 'offsetX', floor(offsetX + .5))
	BC:setDB('target', 'offsetY', floor(offsetY + .5))
end)

-- 框体缩放
option:slider('target', 'scale', 'anchor', 4, vertical - 20, nil, nil, '50%', '150%', .5, 1.5, .05, function(self, value)
	value = floor(value * 100 + .5)
	option.target.scaleText:SetText(L.scale .. ': ' .. value .. '%')
	value = value / 100
	if value ~= BC:getDB('target', 'scale') then BC:setDB('target', 'scale', value) end
end)

option:check('target', 'selfCooldown', 'scale', -4, vertical - 8) -- 只显示我施放的Buff/Debuff倒计时(OmniCC)
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

-- 头像显示职业图标(玩家)
option:check('targettarget', 'portraitClass', nil, 13, vertical - 8, nil, function(self)
	BC:setDB('targettarget', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('targettarget', 'healthBarClass', 'portraitClass') -- 体力条职业色(玩家)

-- 隐藏名字
option:check('targettarget', 'hideName', 'healthBarClass', nil, nil, nil, function(self)
	if self:GetChecked() then
		option.targettarget.nameFontSizeText:SetTextColor(.5, .5, .5)
		BlizzardOptionsPanel_Slider_Disable(option.targettarget.nameFontSize)
	else
		option.targettarget.nameFontSizeText:SetTextColor(1, .82, 0)
		BlizzardOptionsPanel_Slider_Enable(option.targettarget.nameFontSize)
	end
	BC:setDB('targettarget', 'hideName', self:GetChecked())
end)

-- 名字字体大小
option:slider('targettarget', 'nameFontSize', 'hideName', 5, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
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
	BC:setDB('targettarget', 'point', nil)
	BC:setDB('targettarget', 'relative', nil)
	BC:setDB('targettarget', 'offsetX', nil)
	BC:setDB('targettarget', 'offsetY', nil)
end)

option:check('targettarget', 'drag', 'pointDefault', -2, vertical - 4) -- 非战斗中按住Shift左击拖动
--[[ 目标的目标设置 结束 ]]

--[[ 焦点设置 开始 ]]
option:check('focus', 'portraitCombat', nil, 13, vertical - 8) -- 头像上显示战斗信息
option:check('focus', 'combatFlash', 'portraitCombat') -- 战斗状态边框红光

-- 头像显示职业图标(玩家)
option:check('focus', 'portraitClass', 'combatFlash', nil, nil, nil, function(self)
	BC:setDB('focus', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('focus', 'miniIcon', 'portraitClass') -- 显示职业小图标(玩家)/NPC种类小图标
option:check('focus', 'threatLeft', 'miniIcon') -- 居左显示威胁值
option:check('focus', 'healthBarClass', 'threatLeft') -- 体力条职业色(玩家)
option:check('focus', 'statusBarClass', 'healthBarClass') -- 状态栏背景职业色(玩家)

-- 状态栏透明度
option:slider('focus', 'statusBarAlpha', 'statusBarClass', 5, vertical - 20, nil, nil, '0', '1', 0, 1, .1, function(self, value)
	value = floor(value * 10 + 0.5)
	value = value / 10
	option.focus.statusBarAlphaText:SetText(L.statusBarAlpha .. ': ' .. value)
	if value ~= BC:getDB('focus', 'statusBarAlpha') then BC:setDB('focus', 'statusBarAlpha', value) end
end)


-- 名字字体大小
option:slider('focus', 'nameFontSize', 'statusBarAlpha', 0, vertical - 20, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	option.focus.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('focus', 'nameFontSize') then BC:setDB('focus', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('focus', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 8, 18, 8, 18, 1, function(_, value)
	value = floor(value + .5)
	option.focus.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('focus', 'valueFontSize') then BC:setDB('focus', 'valueFontSize', value) end
end)

option:downMenu('focus', 'valueStyle', L.valueStyleList, 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 和玩家框体水平对齐
option:button('focus', 'pointPlayerAlignment', nil, horizontal + 2, -20, 160, function()
	option.player.scale:SetValue(1)
	option.focus.scale:SetValue(1)
	if BC:getDB('focus', 'anchor') then
		BC:setDB('focus', 'offsetY', 0)
	else
		local relative = BC:getDB('player', 'relative')
		local offsetX
		if string.match(relative, 'LEFT') then
			offsetX = BC.focus:GetLeft()
		elseif string.match(relative, 'RIGHT') then
			offsetX = BC.focus:GetRight() - UIParent:GetWidth()
		else
			offsetX = BC.focus:GetLeft() - (UIParent:GetWidth() - BC.focus:GetWidth()) / 2
		end
		BC:setDB('focus', 'relative', relative)
		BC:setDB('focus', 'offsetX', floor(offsetX + .5))
		BC:setDB('focus', 'offsetY', BC:getDB('player', 'offsetY'))
	end
end)

-- 相对玩家垂直对齐
option:button('focus', 'pointPlayerVertical', 'pointPlayerAlignment', 164, 0, 160, function()
	option.player.scale:SetValue(1)
	option.focus.scale:SetValue(1)
	if BC:getDB('focus', 'anchor') then
		BC:setDB('focus', 'offsetX', 39)
	else
		local relative = BC:getDB('focus', 'relative')
		if string.match(relative, 'TOP') then
			BC:setDB('focus', 'relative', 'TOPLEFT')
		elseif string.match(relative, 'BOTTOM') then
			BC:setDB('focus', 'relative', 'BOTTOMLEFT')
		else
			BC:setDB('focus', 'relative', 'LEFT')
		end
		BC:setDB('focus', 'offsetX', BC.player:GetLeft() + 39)
	end
end)

option:check('focus', 'drag', 'pointPlayerAlignment', -2, vertical - 4) -- 非战斗中按住Shift左击拖动
-- 框体缩放

-- 锚定玩家位置
option:check('focus', 'anchor', 'drag', nil, nil, nil, function(self)
	local offsetX, offsetY
	if self:GetChecked() then
		offsetX = BC.focus:GetLeft() - BC.player:GetLeft()
		offsetY = BC.focus:GetTop() - BC.player:GetTop()
		option.focus.scale:SetValue(1)
		option.focus.scaleText:SetTextColor(.5, .5, .5)
		BlizzardOptionsPanel_Slider_Disable(option.focus.scale)
		BC:setDB('focus', 'anchor', 'PlayerFrame')
	else
		offsetX = BC.focus:GetLeft()
		offsetY = BC.focus:GetTop() - UIParent:GetHeight()
		option.focus.scaleText:SetTextColor(1, .82, 0)
		BlizzardOptionsPanel_Slider_Enable(option.focus.scale)
		BC:setDB('focus', 'anchor', nil)
	end
	BC:setDB('focus', 'relative', 'TOPLEFT')
	BC:setDB('focus', 'offsetX', floor(offsetX + .5))
	BC:setDB('focus', 'offsetY', floor(offsetY + .5))
end)

option:slider('focus', 'scale', 'anchor', 4, vertical - 20, nil, nil, '50%', '150%', .5, 1.5, .05, function(self, value)
	value = floor(value * 100 + .5)
	option.focus.scaleText:SetText(L.scale .. ': ' .. value .. '%')
	value = value / 100
	if value ~= BC:getDB('focus', 'scale') then BC:setDB('focus', 'scale', value) end
end)

option:check('focus', 'selfCooldown', 'scale', -4, vertical - 8) -- 只显示我施放的Buff/Debuff倒计时(OmniCC)
option:check('focus', 'dispelCooldown', 'selfCooldown') -- 只显示可以驱散的Buff/Debuff倒计时(OmniCC)
option:check('focus', 'dispelStealable', 'dispelCooldown') -- 高亮显示可以驱散的Buff/Debuff

-- Buff/Debuff图标大小
option:slider('focus', 'auraSize', 'dispelStealable', 4, vertical - 20, nil, nil, 12, 64, 12, 64, 1, function(self, value)
	value = floor(value)
	option.focus.auraSizeText:SetText(L.auraSize .. ': ' .. value)
	if value ~= BC:getDB('focus', 'auraSize') then BC:setDB('focus', 'auraSize', value) end
end)

-- 一行Buff/Debuff数量
option:slider('focus', 'auraRows', 'auraSize', 0, vertical - 20, nil, nil, 1, 32, 1, 32, 1, function(self, value)
	value = floor(value)
	option.focus.auraRowsText:SetText(L.auraRows .. ': ' .. value)
	if value ~= BC:getDB('focus', 'auraRows') then BC:setDB('focus', 'auraRows', value) end
end)

-- Buff/Debuf起始X轴位置
option:slider('focus', 'auraX', 'auraRows', 0, vertical - 20, nil, nil, -256, 256, -256, 256, 1, function(self, value)
	value = floor(value)
	option.focus.auraXText:SetText(L.auraX .. ': ' .. value)
	if value ~= BC:getDB('focus', 'auraX') then BC:setDB('focus', 'auraX', value) end
end)

-- Buff/Debuf起始Y轴位置
option:slider('focus', 'auraY', 'auraX', 0, vertical - 20, nil, nil, -256, 256, -256, 256, 1, function(self, value)
	value = floor(value)
	option.focus.auraYText:SetText(L.auraY .. ': ' .. value)
	if value ~= BC:getDB('focus', 'auraY') then BC:setDB('focus', 'auraY', value) end
end)
--[[ 焦点设置 结束 ]]

--[[ 焦点的目标设置 开始 ]]

-- 头像显示职业图标(玩家)
option:check('focustarget', 'portraitClass', nil, 13, vertical - 8, nil, function(self)
	BC:setDB('focustarget', 'portrait', self:GetChecked() and 1 or 0)
end)

option:check('focustarget', 'healthBarClass', 'portraitClass') -- 体力条职业色(玩家)

-- 隐藏名字
option:check('focustarget', 'hideName', 'healthBarClass', nil, nil, nil, function(self)
	if self:GetChecked() then
		option.focustarget.nameFontSizeText:SetTextColor(.5, .5, .5)
		BlizzardOptionsPanel_Slider_Disable(option.focustarget.nameFontSize)
	else
		option.focustarget.nameFontSizeText:SetTextColor(1, .82, 0)
		BlizzardOptionsPanel_Slider_Enable(option.focustarget.nameFontSize)
	end
	BC:setDB('focustarget', 'hideName', self:GetChecked())
end)

-- 名字字体大小
option:slider('focustarget', 'nameFontSize', 'hideName', 5, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.focustarget.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('focustarget', 'nameFontSize') then BC:setDB('focustarget', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('focustarget', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.focustarget.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('focustarget', 'valueFontSize') then BC:setDB('focustarget', 'valueFontSize', value) end
end)

option:downMenu('focustarget', 'valueStyle', option:valueStyleList(2, 3, 7, 8), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 恢复默认位置
option:button('focustarget', 'pointDefault', nil, horizontal + 2, -20, nil, function()
	BC:setDB('focustarget', 'point', nil)
	BC:setDB('focustarget', 'relative', nil)
	BC:setDB('focustarget', 'offsetX', nil)
	BC:setDB('focustarget', 'offsetY', nil)
end)

option:check('focustarget', 'drag', 'pointDefault', -2, vertical - 4) -- 非战斗中按住Shift左击拖动
--[[ 焦点的目标设置 结束 ]]

--[[ 队友设置 开始 ]]
option:check('party', 'hideFrame', nil, 13, vertical - 8) -- 隐藏框体
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
	if self:GetChecked() then
		option.party.nameFontSizeText:SetTextColor(.5, .5, .5)
		BlizzardOptionsPanel_Slider_Disable(option.party.nameFontSize)
	else
		option.party.nameFontSizeText:SetTextColor(1, .82, 0)
		BlizzardOptionsPanel_Slider_Enable(option.party.nameFontSize)
	end
	BC:setDB('party', 'hideName', self:GetChecked())
end)

-- 名字字体大小
option:slider('party', 'nameFontSize', 'hideName', 4, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.party.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('party', 'nameFontSize') then BC:setDB('party', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('party', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.party.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('party', 'valueFontSize') then BC:setDB('party', 'valueFontSize', value) end
end)

option:downMenu('party', 'valueStyle', L.valueStyleList, 'valueFontSize', -1, vertical - 8, 170) -- 数值样式

-- 恢复默认位置
option:button('party', 'pointDefault', nil, horizontal + 2, -20, nil, function()
	BC:setDB('party', 'point', nil)
	BC:setDB('party', 'relative', nil)
	BC:setDB('party', 'offsetX', nil)
	BC:setDB('party', 'offsetY', nil)
end)

option:check('party', 'drag', 'pointDefault', -2, vertical - 4) -- 非战斗中按住Shift左击拖动

-- 框体缩放
option:slider('party', 'scale', 'drag', 4, vertical - 20, nil, nil, '50%', '150%', .5, 1.5, .05, function(self, value)
	value = floor(value * 100 + .5)
	option.party.scaleText:SetText(L.scale .. ': ' .. value .. '%')
	value = value / 100
	if value ~= BC:getDB('party', 'scale') then BC:setDB('party', 'scale', value) end
end)

option:check('party', 'selfCooldown', 'scale', -4, vertical - 8, 'buffCooldown') -- 只显示我施放的Buff倒计时(OmniCC)
option:check('party', 'dispelCooldown', 'selfCooldown', nil, nil, 'debuffCooldown') -- 只显示可以驱散的Debuff倒计时(OmniCC)
option:check('party', 'dispelStealable', 'dispelCooldown', nil, nil, 'debuffStealable') -- 高亮显示可以驱散的Debuff

-- Buff/Debuff图标大小
option:slider('party', 'auraSize', 'dispelStealable', 4, vertical - 20, nil, nil, 12, 64, 12, 64, 1, function(self, value)
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
	option.party.auraXText:SetText(L.auraX .. ': ' .. value)
	if value ~= BC:getDB('party', 'auraX') then BC:setDB('party', 'auraX', value) end
end)

-- Buff/Debuf起始Y轴位置
option:slider('party', 'auraY', 'auraX', 0, vertical - 20, nil, nil, -256, 256, -256, 256, 1, function(self, value)
	value = floor(value + .5)
	option.party.auraYText:SetText(L.auraY .. ': ' .. value)
	if value ~= BC:getDB('party', 'auraY') then BC:setDB('party', 'auraY', value) end
end)
--[[ 队友设置 结束 ]]

--[[ 队友的宠物设置 开始 ]]
option:check('partypet', 'hideFrame', nil, 13, vertical - 8) -- 隐藏框体

-- 隐藏名字
option:check('partypet', 'hideName', 'hideFrame', nil, nil, nil, function(self)
	if self:GetChecked() then
		option.partypet.nameFontSizeText:SetTextColor(.5, .5, .5)
		BlizzardOptionsPanel_Slider_Disable(option.partypet.nameFontSize)
	else
		option.partypet.nameFontSizeText:SetTextColor(1, .82, 0)
		BlizzardOptionsPanel_Slider_Enable(option.partypet.nameFontSize)
	end
	BC:setDB('partypet', 'hideName', self:GetChecked())
end)

-- 名字字体大小
option:slider('partypet', 'nameFontSize', 'hideName', 5, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.partypet.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('partypet', 'nameFontSize') then BC:setDB('partypet', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('partypet', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.partypet.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('partypet', 'valueFontSize') then BC:setDB('partypet', 'valueFontSize', value) end
end)

option:downMenu('partypet', 'valueStyle', option:valueStyleList(2, 3, 5, 7, 8), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式
--[[ 队友的宠物设置 结束 ]]

--[[ 队友目标的设置 开始 ]]
option:check('partytarget', 'hideFrame', nil, 13, vertical - 8) -- 隐藏框体
option:check('partytarget', 'healthBarClass', 'hideFrame') -- 体力条职业色(玩家)

-- 头像显示职业图标(玩家)
option:check('partytarget', 'portraitClass', 'healthBarClass', nil, nil, nil, function(self)
	BC:setDB('partytarget', 'portrait', self:GetChecked() and 1 or 0)
end)

-- 隐藏名字
option:check('partytarget', 'hideName', 'portraitClass', nil, nil, nil, function(self)
	if self:GetChecked() then
		option.partytarget.nameFontSizeText:SetTextColor(.5, .5, .5)
		BlizzardOptionsPanel_Slider_Disable(option.partytarget.nameFontSize)
	else
		option.partytarget.nameFontSizeText:SetTextColor(1, .82, 0)
		BlizzardOptionsPanel_Slider_Enable(option.partytarget.nameFontSize)
	end
	BC:setDB('partytarget', 'hideName', self:GetChecked())
end)

-- 名字字体大小
option:slider('partytarget', 'nameFontSize', 'hideName', 5, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.partytarget.nameFontSizeText:SetText(L.nameFontSize .. ': ' .. value)
	if value ~= BC:getDB('partytarget', 'nameFontSize') then BC:setDB('partytarget', 'nameFontSize', value) end
end)

-- 数值字体大小
option:slider('partytarget', 'valueFontSize', 'nameFontSize', 0, vertical - 20, nil, nil, 6, 16, 6, 16, 1, function(_, value)
	value = floor(value + .5)
	option.partytarget.valueFontSizeText:SetText(L.valueFontSize .. ': ' .. value)
	if value ~= BC:getDB('partytarget', 'valueFontSize') then BC:setDB('partytarget', 'valueFontSize', value) end
end)

option:downMenu('partytarget', 'valueStyle', option:valueStyleList(2, 3, 5, 7, 8), 'valueFontSize', -1, vertical - 8, 170) -- 数值样式
--[[ 队友目标的设置 结束 ]]
