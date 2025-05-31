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
L.partypet = 'Рамка питомца группы'
L.partytarget = 'Рамка цели группы'
L.info = 'Электронная почта: ' .. GetAddOnMetadata(addonName, 'X-eMail')
L.cantSaveInCombat = 'Нельзя сохранить в бою!'
L.confirmResetDefault = 'Подтвердить сброс настроек?'
L.reset = 'Сброс'
L.config = 'Выберите параметры конфигурации'
L.public = 'Использовать общий профиль'
L.dark = 'Тёмные темы'
L.newClassIcon = 'Новый стиль значка класса'
L.healthBarColor = 'Цвет полосы здоровья меняется в зависимости от значения здоровья'
L.nameTextClassColor = 'Цвет имени соответствует цвету класса (игрок)'
L.dragSystemFarmes = 'Свободно перемещать системные рамки'
L.incomingHeals = 'Показывать входящее исцеление'
L.alwaysCompareItems = 'Включить сравнение экипировки'
L.disableAddons = 'Отключить конфликтующие аддоны'
L.autoTab = 'Автоматический выбор игроков в PvP через TAB'
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
L.portraitCombat = 'Отображать боевую информацию на портрете'
L.valueFont = 'Шрифт значений'
L.combatFlash = 'Красная вспышка в бою'
<<<<<<< HEAD
<<<<<<< HEAD
L.showThreat = "Показывать числовое значение угрозы"
L.statusBarClass = "Цвет фона полосы статуса по профессии"
L.statusBarAlpha = "Прозрачность полосы статуса"
L.healthBarClass = "Цвет фона полосы здоровья по классу"
L.powerSpark = "Искра маны/энергии"
=======
L.threatLeft = 'Отображать значение угрозы слева'
L.statusBarClass = 'Цвет фона полосы состояния по профессии'
L.statusBarAlpha = 'Прозрачность полосы состояния'
L.healthBarClass = 'Цвет фона полосы здоровья по классу'
>>>>>>> ad69242 (3.43.1)
=======
L.threatLeft = 'Отображать значение угрозы слева'
L.statusBarClass = 'Цвет фона полосы состояния по профессии'
L.statusBarAlpha = 'Прозрачность полосы состояния'
L.healthBarClass = 'Цвет фона полосы здоровья по классу'
>>>>>>> ad69242335bbe46a7f6b5c23d9502869f5e57e71
L.border = 'Рамка'
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
	[4] = 'Крутое лицо',
}
L.nameFontSize = 'Размер шрифта имени'
L.valueFontSize = 'Размер шрифта значений'
L.valueStyle = 'Стиль значений'
L.valueStyleList = {
	[1] = 'Текущее значение и процент по бокам',
	[2] = 'Процент в центре',
	[3] = 'Текущее значение в центре',
	[4] = 'Текущее/Максимум',
	[5] = 'Процент сбоку от текущего',
	[6] = 'Текущее/Максимум сбоку от процента',
	[7] = 'Процент сбоку',
	[8] = 'Текущее значение сбоку',
	[9] = 'Текущее/Максимум сбоку',
	[10] = 'Нет',
}
L.druidBar = 'Показывать пользовательскую полосу маны для друида'
L.hideName = 'Скрыть имя'
L.scale = 'Масштаб'
L.hideFrame = 'Скрыть рамку'
L.drag = 'Удерживайте Shift и перетаскивайте вне боя'
L.anchor = 'Привязка рамки игрока'
L.pointDefault = 'Восстановить положение по умолчанию'
L.pointTargetLeftTop = 'Позиция в левом верхнем углу'
L.pointTargetCenter = 'Горизонтально по центру'
L.pointPlayerAlignment = 'Горизонтальное выравнивание'
L.pointPlayerCenter = 'Горизонтально по центру'
L.pointPlayerVertical = 'Вертикальное выравнивание'
L.portraitClass = 'Портрет показывает значок класса'
L.showEnemyBuff  = 'Показывать баффы цели противника'
L.selfCooldown = 'Показывать только время восстановления моих аур'
L.dispelCooldown = 'Показывать время восстановления только для рассеиваемых аур'
L.dispelStealable = 'Подсвечивать ауры, которые можно рассеять'
L.buffCooldown = 'Показывать только время восстановления моих баффов'
L.debuffCooldown = 'Показывать время восстановления только рассеиваемых дебаффов'
L.debuffStealable = 'Подсвечивать дебаффы, которые можно рассеять'
L.auraSize = 'Размер значка ауры'
L.auraRows = 'Количество аур в строке'
L.auraX = 'Позиция баффа/дебаффа по оси X'
L.auraY = 'Позиция баффа/дебаффа по оси Y'
L.raidShowParty = 'В рейде показывать рамку группы'
L.showLevel = 'Показывать уровень'
L.outRange = 'Прозрачность за пределами досягаемости'
L.showCastBar = 'Показывать полосу заклинаний'
L.talentIcon = 'Показывать мини-значок (клик для смены талантов)'
L.autoTalentEquip = 'Автоматический набор экипировки по названию таланта'
L.equipmentIcon = 'Показывать значок экипировки'
L.hidePartyNumber = 'В рейде скрывать номер группы'
L.miniIcon = 'Показывать мини-значки (существо/класс)'
L.creatureList = {
	['Beast'] = 'Зверь',
	['Humanoid'] = 'Гуманоид',
	['Dragonkin'] = 'Драконид',
	['Mechanical'] = 'Механизм',
	['Demon'] = 'Демон',
	['Elemental'] = 'Элементаль',
	['Giant'] = 'Гигант',
	['Undead'] = 'Нежить',
	['Totem'] = 'Тотем',
	['Aberration'] = 'Аберрация',
	['Critter'] = 'Существо',
	['Gas Cloud'] = 'Газовое облако',
	['Non-combat Pet'] = 'Небоевое животное',
	['Not specified'] = 'Не указано',
}

L.playerClass = 'Класс игрока:'
L.creatureType = 'Тип существа:'
L.altKeyDown = 'Alt+Клик:'
L.invite = 'Пригласить'
L.ctrlKeyDown = 'Ctrl+Клик:'
L.trade = 'Обмен'
L.shiftKeyDown = 'Shift+Клик:'
L.copyName = 'Копировать имя'
L.leftButton = 'ЛКМ:'
L.inspect = 'Осмотреть цель'
L.rightButton = 'ПКМ:'
L.followUnit = 'Следовать за юнитом'
L.middleButton = 'СКМ:'
L.sendTell = 'Отправить сообщение'
L.primary = 'Основной талант'
L.secondary = 'Вторичный талант'
L.switch = 'Переключить'
L.switchAfter = 'Переключить экипировку после таланта'
L.nude = 'Раздеться одним кликом'
L.click = 'Клик мышью'
L.clickEquipment = 'Клик по экипировке'
L.saveEquipment = 'Сохранить экипировку'
