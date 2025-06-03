if GetLocale() ~= 'ruRU' then return end
local addonName = ...
local L = _G[addonName .. 'Locale']
--Translator ZamestoTV
L.player = 'Рамка игрока'
L.pet = 'Рамка питомца'
L.pettarget = 'Рамка цели питомца'
L.target = 'Рамка цели'
L.targettarget = 'Рамка цели цели'
L.party = 'Рамка группы'
L.partypet = 'Рамка питомцев группы'
L.partytarget = 'Рамка целей группы'
L.info = 'Электронная почта: ' .. GetAddOnMetadata(addonName, 'X-eMail')
L.cantSaveInCombat = 'Нельзя сохранять в бою!'
L.confirmResetDefault = 'Подтвердить сброс на настройки по умолчанию?'
L.reset = 'Сброс'
L.config = 'Выбрать параметры конфигурации'
L.public = 'Использовать общий профиль'
L.dark = 'Тёмные темы'
L.newClassIcon = 'Значок класса нового стиля'
L.healthBarColor = 'Цвет полосы здоровья изменяется в зависимости от значения здоровья'
L.nameClassColor = 'Цвет имени по цвету класса (игрок)'
L.dragSystemFarmes = 'Свободно перемещать системные рамки'
L.incomingHeals = 'Показывать входящее исцеление'
L.alwaysCompareItems = 'Включить сравнение экипировки'
L.autoTab = 'Автоматический выбор игроков клавишей TAB в PvP'
L.carry = 'Числовое сокращение'
L.carryW = 'Ван/И'
L.wan = 'Ван'
L.yi = 'И'
L.carryK = 'К/М'
L.nameFont = 'Шрифт имени'
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
		text = '2002 Полужирный',
		value = [[Fonts\2002B.ttf]],
	},
	[4] = {
		text = 'AR CrystalzcuheiGBK Полужирный',
		value = [[Fonts\ARHei.ttf]],
	},
	[5] = {
		text = 'AR ZhongkaiGBK Средний (Бой)',
		value = [[Fonts\ARKai_C.ttf]],
	},
	[6] = {
		text = 'AR ZhongkaiGBK Средний',
		value = [[Fonts\ARKai_T.ttf]],
	},
	[7] = {
		text = 'Arial Узкий',
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
L.fontFlags = 'Контур шрифта'
L.fontFlagsList = {
	[1] = {
		text = 'Нет',
		value = 'NONE',
	},
	[2] = {
		text = 'Тонкий',
		value = 'OUTLINE',
	},
	[3] = {
		text = 'Толстый',
		value = 'THICKOUTLINE',
	},
	[4] = {
		text = 'Монохромный',
		value = 'MONOCHROME',
	},
}
L.portraitCombat = 'Отображать информацию о бое на портрете'
L.valueFont = 'Шрифт значений'
L.combatFlash = 'Красная вспышка в бою'
L.showThreat = 'Показывать числовое значение угрозы'
L.statusBarClass = 'Цвет фона полосы статуса по профессии'
L.statusBarAlpha = 'Прозрачность полосы статуса'
L.healthBarClass = 'Цвет фона полосы здоровья по классу'
L.border = 'Граница'
L.borderList = {
	[1] = 'Обычная',
	[2] = 'Редкая',
	[3] = 'Редкая элитная',
	[4] = 'Элитная',
}
L.portrait = 'Портрет'
L.portraitList = {
	[0] = 'По умолчанию',
	[1] = 'Значок класса',
	[2] = 'Кот',
	[3] = 'Собака',
	[4] = 'Панда',
	[5] = 'Лунный совух',
	[6] = 'Крутое лицо',
}
L.nameFontSize = 'Размер шрифта имени'
L.valueFontSize = 'Размер шрифта значений'
L.valueStyle = 'Стиль значений'
L.valueStyleList = {
	[1] = 'Текущее значение и процент с обеих сторон',
	[2] = 'Процент в центре',
	[3] = 'Текущее значение в центре',
	[4] = 'Текущее/Максимум',
	[5] = 'Процент сбоку от текущего',
	[6] = 'Текущее/Максимум и процент сбоку',
	[7] = 'Процент сбоку',
	[8] = 'Текущее значение сбоку',
	[9] = 'Текущее/максимальное сбоку',
	[10] = 'Нет',
}
L.druidBar = 'Показывать полосы маны для друидов'
L.hideName = 'Скрыть имя'
L.scale = 'Масштаб'
L.hideFrame = 'Скрыть рамку'
L.drag = 'Удерживайте Shift и перетаскивайте вне боя'
L.anchor = 'Привязка рамки игрока'
L.pointDefault = 'По умолчанию'
L.pointTargetLeftTop = 'Позиция вверху слева'
L.pointTargetCenter = 'По центру по горизон.'
L.pointPlayerAlignment = 'По горизонт.'
L.pointPlayerCenter = 'По центру по горизонт.'
L.pointPlayerVertical = 'Вертикальное выравнивание'
L.portraitClass = 'Портрет показывает значок класса'
L.showEnemyBuff = 'Показывать баффы симуляции вражеской цели'
L.selfCooldown = 'Показывать только КД аур, наложенных мной'
L.dispelCooldown = 'Показывать только КД аур, которые можно рассеять'
L.dispelStealable = 'Подсвечивать ауры, которые можно рассеять'
L.buffCooldown = 'Показывать только КД баффов, наложенных мной'
L.debuffCooldown = 'Показывать только КД дебаффов, которые рассеивается'
L.debuffStealable = 'Подсвечивать дебаффы, которые можно рассеять'
L.auraSize = 'Размер значка ауры'
L.auraPercent = 'Процент наложения ауры другими'
L.auraRows = 'Количество аур в строке'
L.auraX = 'Позиция баффа/дебаффа по оси X'
L.auraY = 'Позиция баффа/дебаффа по оси Y'
L.raidShowParty = 'Показывать рамки группы в рейде'
L.showLevel = 'Показывать уровень'
L.outRange = 'Прозрачность вне зоны действия'
L.showCastBar = 'Показывать полосу заклинаний'
L.talentIcon = 'Показывать мини-значок (для смены талантов)'
L.autoTalentEquip = 'Автоматический набор экипировки по названию талантов (ItemRack)'
L.equipmentIcon = 'Показывать значок экипировки (ItemRack)'
L.hidePartyNumber = 'Скрывать номер группы в рейде'
L.miniIcon = 'Показывать мини-значки (существо/класс)'
L.creatureList = {
	['Зверь'] = 1,
	['Гуманоид'] = 2,
	['Драконоид'] = 3,
	['Механизм'] = 4,
	['Демон'] = 5,
	['Элементаль'] = 6,
	['Великан'] = 7,
	['Нежить'] = 8,
	['Тотем'] = 9,
	['Аберрация'] = 10,
	['Существо'] = 11,
	['Газовое облако'] = 12,
	['Небоевое животное'] = 13,
	['Не указано'] = 14,
}
L.playerClass = 'Класс игрока:'
L.creatureType = 'Тип существа:'
L.altKeyDown = 'Alt-Клик:'
L.invite = 'Пригласить'
L.ctrlKeyDown = 'Ctrl-Клик:'
L.trade = 'Обмен'
L.shiftKeyDown = 'Shift-Клик:'
L.copyName = 'Копировать имя'
L.leftButton = 'ЛКМ:'
L.inspect = 'Осмотреть цель'
L.rightButton = 'ПКМ'
L.followUnit = 'Следовать за юнитом'
L.middleButton = 'СКМ'
L.sendTell = 'Отправить сообщение'
L.primary = 'Основной талант'
L.secondary = 'Вторичный талант'
L.switch = 'Переключить'
L.switchAfter = 'Переключить экипировку после таланта'
L.nude = 'Раздеться одним кликом'
L.click = 'Клик мыши'
L.clickEquipment = 'Клик по экипировке'
L.saveEquipment = 'Сохранить экипировку'
L.confirmEquipmentSet = 'Подтвердить перезапись набора с именем %s?'
