local addonName = ...
_G[addonName .. 'Locale'] = {}
local L = _G[addonName .. 'Locale']

L.player = 'Player Frame'
L.pet = 'Pet Frame'
L.pettarget = 'Pet Target Frame'
L.target = 'Target Frame'
L.targettarget = 'Target Target Frame'
L.focus = 'Focus Frame'
L.focustarget = 'Focus Target Frame'
L.party = 'Party Frame'
L.partypet = 'Party Pet Frame'
L.partytarget = 'Party Target Frame'
L.info = GetAddOnMetadata(addonName, 'X-Website')
L.reset = 'Restore default settings'
L.config = 'Select config options'
L.public = 'Use common profile'
L.dark = 'Use dark themes'
L.healthBarColor = 'Life bar color changes according to life value'
L.nameTextClassColor = 'Name color class color (player)'
L.dragSystemFarmes = 'Freely drag the system frame'
L.incomingHeals = 'Show alert heals'
L.alwaysCompareItems = 'Enable equipment comparison'
L.autoTab = 'PVP automatic TAB selects players'
L.dalaran = 'Dalaran'
L.autoNameplate = 'Dalaran automatically closes nameboard'
L.carry = 'Numeric carry'
L.carryW = 'Wan/Yi'
L.wan = 'Wan'
L.yi = 'Yi'
L.carryK = 'K/M'
L.nameFont = 'First name font'
L.fontList = {
	[1] = {
		text = 'Friz Quadrata TT',
		value = [[Fonts\FRIZQT__.ttf]],
	},
	[2] = {
		text = '2002',
		value = [[Fonts\2002.ttf]],
	},
	[3] = {
		text = '2002 Bold',
		value = [[Fonts\2002B.ttf]],
	},
	[4] = {
		text = 'AR CrystalzcuheiGBK Demibold',
		value = [[Fonts\ARHei.ttf]],
	},
	[5] = {
		text = 'AR ZhongkaiGBK Medium (Combat)',
		value = [[Fonts\ARKai_C.ttf]],
	},
	[6] = {
		text = 'AR ZhongkaiGBK Medium',
		value = [[Fonts\ARKai_T.ttf]],
	},
	[7] = {
		text = 'Arial Narrow',
		value = [[Fonts\ARIALN.ttf]],
	},
	[8] = {
		text = 'MoK',
		value = [[Fonts\K_Pagetext.ttf]],
	},
	[9] = {
		text = 'Morpheus',
		value = [[Fonts\MORPHEUS_CYR.ttf]],
	},
	[10] = {
		text = 'Nimrod MT',
		value = [[Fonts\NIM_____.ttf]],
	},
	[11] = {
		text = 'Skurri',
		value = [[Fonts\SKURRI_CYR.ttf]],
	},
}
L.fontFlags = 'Font Outline'
L.fontFlagsList = {
	[1] = {
		text = 'None',
		value = 'NONE',
	},
	[2] = {
		text = 'Thin',
		value = 'OUTLINE',
	},
	[3] = {
		text = 'Thick',
		value = 'THICKOUTLINE',
	},
	[4] = {
		text = 'Monochrome',
		value = 'MONOCHROME',
	},
}
L.portraitCombat = 'Display combat information on the avatar'
L.valueFont = 'Value Font'
L.combatFlash = 'Combat Red Flash'
L.statusBarClass = 'Status bar background professional color'
L.statusBarAlpha = 'Status bar alpha'
L.healthBarClass = 'Health bar background class color'
L.fiveSecondRule = 'Five Second Rule'
L.border = 'Border'
L.borderList = {
	[1] = 'Normal',
	[2] = 'Rare',
	[3] = 'RareElite',
	[4] = 'Elite',
}
L.portrait = 'Portrait'
L.portraitList = {
	[0] = 'Default',
	[1] = 'Class Icon',
	[2] = 'Cat',
	[3] = 'Dog',
	[4] = 'Panda',
	[5] = 'CoolFace',
}
L.nameFontSize = 'Name Font Size'
L.valueFontSize = 'Value Font Size'
L.valueStyle = 'Value Style'
L.valueStyleList = {
	[1] = 'Current value and percentage on both sides',
	[2] = 'Middle percent',
	[3] = 'Middle current value',
	[4] = 'Current/Max',
	[5] = 'Current Side percentage',
	[6] = 'Current/Max Side percentage',
	[7] = 'Side percentage',
	[8] = 'Side current value',
	[9] = 'Side current/maximum',
	[10] = 'None',
}
L.druidBar = 'Show custom druid mana bars'
L.druidBarEnergy = 'Display energy bar in bear form'
L.hideName = 'Hide Name'
L.scale = 'Scale'
L.hideFrame = 'Hide Frame'
L.drag = 'Hold down Shift and drag when not in combat'
L.defaultPoint = 'Restore default point'
L.centerHorizontally = 'Horizontal centering'
L.alignHorizontally = 'Align horizontally'
L.portraitClass = 'The avatar shows the class icon'
L.selfCooldown = 'Only display the countdown of aura I cast (OmniCC)'
L.dispelCooldown = 'Only display aura countdown that can be dispelled (OmniCC)'
L.dispelStealable = 'Highlight aura that you can dispel'
L.buffCooldown = 'Only display the countdown of Buffs I cast (OmniCC)'
L.debuffCooldown = 'Only display Debuff countdown that can be dispelled (OmniCC)'
L.debuffStealable = 'Highlight Debuffs that can be dispelled'
L.threatLeft = 'Display threat value on the left'
L.raidShowParty = 'Raid show party frame'
L.showLevel = 'Show level'
L.outRange = 'Translucent beyond range'
L.showCastBar = 'Show cast bar'
L.talentIcon = 'Show mini icon (click to switch talents)'
L.autoTalentEquip = 'Automatic equipment corresponding set'
L.equipmentIcon = 'Display mini equipment icons (up to 6)'
L.hidePartyNumber = 'In raid hide party number'
L.miniIcon = 'Show mini icons (creature/class)'
L.creatureList = {
	['Beast'] = 1,
	['Humanoid'] = 2,
	['Dragonkin'] = 3,
	['Mechanical'] = 4,
	['Demon'] = 5,
	['Elemental'] = 6,
	['Giant'] = 7,
	['Undead'] = 8,
	['Totem'] = 9,
	['Aberration'] = 10,
	['Critter'] = 11,
	['Gas Cloud'] = 12,
	['Non-combat Pet'] = 13,
	['Not specified'] = 14,
}

L.playerClass = 'Player class:'
L.creatureType = 'Creature type:'
L.altKeyDown = 'Alt-click:'
L.invite = 'Invite'
L.ctrlKeyDown = 'Ctrl-click:'
L.trade = ' Trade'
L.shiftKeyDown = 'Shift-click:'
L.copyName = 'Copy name'
L.leftButton = 'Left mouse click:'
L.inspect = 'Inspect target'
L.rightButton = 'Right mouse click'
L.followUnit = 'Follow unit'
L.middleButton = 'Middle mouse button'
L.sendTell = 'Send tell'
L.action = 'current'
L.primary = 'Primary talent'
L.secondary = 'Secondary talent'
L.switch = 'Switch'
L.switchAfter = 'Switch equipment after talent'
L.noEquip = 'Not saved'
L.nude = 'One click to undress'
L.click = 'Mouse click'
L.clickEquipment = 'Click equipment: %s'
L.shiftKeyDownSave = 'Shift-click: Save'
