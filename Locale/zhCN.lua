﻿if GetLocale() ~= 'zhCN' then return end
local addonName = ...
local L = _G[addonName .. 'Locale']

L.player = '├玩家'
L.pet = '├宠物'
L.pettarget = '├─宠物的目标'
L.target = '├目标'
L.targettarget = '├─目标的目标'
L.party = '├队友'
L.partypet = '├─队友的宠物'
L.partytarget = '└─队友的目标'
L.info = 'QQ讨论群: 377298123'
L.cantSaveInCombat = '战斗中无法更改设置'
L.confirmResetDefault = '确定要恢复默认设置?'
L.reset = '重置'
L.config = '选择配置'
L.public = '账号通用'
L.dark = '暗黑主题'
L.newClassIcon = '新风格职业图标'
L.healthBarColor = '体力条颜色按体力值变化'
L.nameTextClassColor = '名字颜色职业色(玩家)'
L.dragSystemFarmes = '自由拖动系统框体'
L.incomingHeals = '显示预治疗'
L.alwaysCompareItems = '启用装备对比'
L.autoTab = 'PVP自动TAB选择玩家'
L.carry = '数值单位'
L.carryW = '万/亿'
L.wan = '万'
L.yi = '亿'
L.carryK = 'K/M'
L.nameFont = '名字字体'
L.fontList = {
	[1] = {
		text = '默认',
		value = 'Fonts\\ARKai_T.ttf',
	},
	[2] = {
		text = '聊天',
		value = 'Fonts\\ARHei.ttf',
	},
	[3] = {
		text = '伤害数字',
		value = 'Fonts\\ARKai_C.ttf',
	},
}
L.fontFlags = '字体轮廓'
L.fontFlagsList = {
	[1] = {
		text = '无',
		value = 'NONE',
	},
	[2] = {
		text = '细边',
		value = 'OUTLINE',
	},
	[3] = {
		text = '粗边',
		value = 'THICKOUTLINE',
	},
	[4] = {
		text = '锐利',
		value = 'MONOCHROME',
	},
}
L.portraitCombat = '头像上显示战斗信息'
L.valueFont = '数值字体'
L.combatFlash = '战斗状态边框红光'
L.showThreat = '显示威胁百分比'
L.statusBarClass = '状态栏背景职业色(玩家)'
L.statusBarAlpha = '状态栏透明度'
L.healthBarClass = '体力条职业色(玩家)'
L.border = '边框'
L.borderList = {
	[1] = '普通',
	[2] = '稀有',
	[3] = '稀有精英',
	[4] = '精英',
}
L.portrait = '头像'
L.portraitList = {
	[0] = '默认',
	[1] = '职业图标',
	[2] = '猫猫',
	[3] = '狗狗',
	[4] = '熊猫',
	[5] = '酷脸',
}
L.nameFontSize = '名字字体大小'
L.valueFontSize = '数值字体大小'
L.valueStyle = '数值样式'
L.valueStyleList = {
	[1] = '两边当前值和百分比',
	[2] = '中间百分比',
	[3] = '中间当前值',
	[4] = '中间当前值/最大值',
	[5] = '中间当前值 侧边百分比',
	[6] = '中间当前值/最大值 侧边百分比',
	[7] = '侧边百分比',
	[8] = '侧边当前值',
	[9] = '侧边当前值/最大值',
	[10] = '都不显示',
}
L.druidBar = '显示自定义德鲁伊法力条'
L.hideName = '隐藏名字'
L.scale = '框体缩放'
L.hideFrame = '隐藏框体'
L.drag = '非战斗中按住Shift拖动'
L.anchor = '锚定玩家框体'
L.pointDefault = '恢复默认位置'
L.pointTargetLeftTop = '恢复左上角位置'
L.pointTargetCenter = '恢复水平居中位置'
L.pointPlayerAlignment = '和玩家框体水平对齐'
L.pointPlayerCenter = '和玩家框体水平居中'
L.pointPlayerVertical = '和玩家框体垂直对齐'
L.portraitClass = '头像显示职业图标(玩家)'
L.showEnemyBuff  = '显示敌对目标模拟Buff'
L.selfCooldown = '只显示我施放的Buff/Debuff倒计时(OmniCC)'
L.dispelCooldown = '只显示可以驱散的Buff/Debuff倒计时(OmniCC)'
L.dispelStealable = '高亮显示可以驱散的Buff/Debuff'
L.buffCooldown = '只显示我施放的Buff倒计时(OmniCC)'
L.debuffCooldown = '只显示可以驱散的Debuff倒计时(OmniCC)'
L.debuffStealable = '高亮显示可以驱散的Debuff'
L.auraSize = 'Buff/Debuff图标大小'
L.auraRows = '一行Buff/Debuff数量'
L.auraX = 'Buff/Debuf X轴位置'
L.auraY = 'Buff/Debuff Y轴位置'
L.threatLeft = '居左显示威胁值'
L.raidShowParty = '团队显示小队框体'
L.showLevel = '显示等级'
L.outRange = '超出范围半透明'
L.showCastBar = '显示施法条'
L.talentIcon = '显示天赋小图标(点击切换天赋)'
L.autoTalentEquip = '切换天赋后装备天赋名套装(ItemRack)'
L.equipmentIcon = '显示装备小图标(ItemRack)'
L.hidePartyNumber = '在团队中隐藏小队编号'
L.miniIcon = '显示小图标(职业/种类)'
L.creatureList = {
	['野兽'] = 1,
	['人型生物'] = 2,
	['龙类'] = 3,
	['机械'] = 4,
	['恶魔'] = 5,
	['元素生物'] = 6,
	['巨人'] = 7,
	['亡灵'] = 8,
	['图腾'] = 9,
	['畸变怪'] = 10,
	['小动物'] = 11,
	['气体云雾'] = 12,
	['非战斗宠物'] = 13,
	['未指定'] = 14,
}

L.playerClass = '玩家职业'
L.creatureType = '生物类型'
L.altKeyDown = '按住Alt点击'
L.invite = '邀请加入'
L.ctrlKeyDown = '按住Ctrl点击'
L.trade = '请求交易'
L.copyName = '复制名字'
L.shiftKeyDown = '按住Shift点击'
L.leftButton = '鼠标左击'
L.inspect = '观察目标'
L.rightButton = '鼠标右击'
L.followUnit = '跟随目标'
L.middleButton = '鼠标中键'
L.sendTell = '私聊对方'
L.primary = '主天赋'
L.secondary = '副天赋'
L.switch = '切换'
L.switchAfter = '切换天赋后装备'
L.nude = '一键脱装'
L.click = '点击'
L.clickEquipment = '点击装备套装'
L.saveEquipment = '保存套装'
L.confirmEquipmentSet = '确定要覆盖名为%s的套装?'
