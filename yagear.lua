local addonName, addonTable = ...

-- 常量
local ROW, COL, FLYOUT_LIMIT, SET_LIMIT = 7, 6, 23, 10

-- 解析位置信息
local function UnpackLocation(loc)
	if loc < 0 then return false, false, false, 0 end
	local p = bit.band(loc, ITEM_INVENTORY_LOCATION_PLAYER) ~= 0
	local b = bit.band(loc, ITEM_INVENTORY_LOCATION_BANK) ~= 0
	local g = bit.band(loc, ITEM_INVENTORY_LOCATION_BAGS) ~= 0
	if p then
		loc = loc - ITEM_INVENTORY_LOCATION_PLAYER
	elseif b then
		loc = loc - ITEM_INVENTORY_LOCATION_BANK
	end
	if not g then return p, b, g, loc end
	loc = loc - ITEM_INVENTORY_LOCATION_BAGS
	local bag = bit.rshift(loc, ITEM_INVENTORY_BAG_BIT_OFFSET)
	local slot = loc - bit.lshift(bag, ITEM_INVENTORY_BAG_BIT_OFFSET)
	if b then bag = bag + ITEM_INVENTORY_BANK_BAG_OFFSET end
	return p, b, g, slot, bag
end

-- 获取玩家图标
local function GetPlayerIcons()
	local icons, sets = {}, C_EquipmentSet.GetEquipmentSetIDs()
	for _, id in ipairs(sets) do
		local _, tex = C_EquipmentSet.GetEquipmentSetInfo(id)
		if tex then tinsert(icons, tex) end
	end
	local equip = {}
	for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local list = {}
		GetInventoryItemsForSlot(i, list)
		for loc in pairs(list) do
			local p, b, g, slot, bag = UnpackLocation(loc)
			local tex = not g and GetInventoryItemTexture('player', slot) or
					C_Item.GetItemIconByID(C_Container.GetContainerItemID(bag, slot))
			if tex then equip[tex] = true end
		end
	end
	for tex in pairs(equip) do tinsert(icons, tex) end
	local talent = {}
	for i = 1, GetNumTalentTabs() do
		for j = 1, GetNumTalents(i) do
			local _, tex = GetTalentInfo(i, j)
			talent[tex] = true
		end
	end
	for tex in pairs(talent) do tinsert(icons, tex) end
	return icons
end

-- 放置光标物品
local function PlaceCursorItemInBags()
	if C_Container.GetContainerNumFreeSlots(0) > 0 then
		PutItemInBackpack()
		return
	end
	for i = 1, 4 do
		if C_Container.GetContainerNumFreeSlots(i) > 0 then
			PutItemInBag(C_Container.ContainerIDToInventoryID(i))
			return
		end
	end
	local slots = C_Container.GetContainerFreeSlots(-1)
	if slots[1] and slots[1] < NUM_BANKGENERIC_SLOTS then
		PickupInventoryItem(slots[1] + BankButtonIDToInvSlotID(0))
		return
	end
	for i = 5, 10 do
		if C_Container.GetContainerNumFreeSlots(i) > 0 then
			PutItemInBag(C_Container.ContainerIDToInventoryID(i))
			return
		end
	end
	ClearCursor()
	UIErrorsFrame:AddMessage(ERR_EQUIPMENT_MANAGER_BAGS_FULL, 1.0, 0.1, 0.1, 1.0)
end

-- UI辅助函数
local function HideParent(self) self:GetParent():Hide() end
local function TipLeave(self) GameTooltip:Hide() end
local function TipEnter(self)
	local txt = self.name
	if not txt or txt == '' then return end
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:SetText(txt, 1, 1, 1)
end

-- 图标选择
local function SelectPopupIconInternal(popup, offset, sel, state)
	if not sel then return end
	local i = sel - offset * ROW
	if i > 0 and i <= ROW * COL then popup.items[i]:SetChecked(state) end
end
local function SelectPopupIcon(popup, offset, sel)
	SelectPopupIconInternal(popup, offset, popup.selected, false)
	SelectPopupIconInternal(popup, offset, sel, true)
	popup.selected = sel
end

-- 管理器选择
local function SelectManagerItem(manager, sel)
	if not sel then
		manager.selected = nil
	elseif sel ~= manager.selected then
		if manager.selected then manager.selected:SetChecked(false) end
		manager.selected = sel
	end
	if sel then sel:SetChecked(true) end
	local enabled = sel and true or false
	manager.buttonDelete:SetEnabled(enabled)
	manager.buttonEquip:SetEnabled(enabled)
end

-- 忽略槽位
local function ClearIgnoredSlots(manager)
	C_EquipmentSet.ClearIgnoredSlotsForSave()
	for _, slot in ipairs(manager.slotButtons) do
		slot.ignored = nil
		slot.ignoreTexture:Hide()
	end
end
local function RefreshIgnoredSlots(manager, id)
	local ignores = C_EquipmentSet.GetIgnoredSlots(id)
	C_EquipmentSet.ClearIgnoredSlotsForSave()
	local slots = manager.slotButtons
	for i, t in ipairs(ignores) do
		local slot = slots[i]
		slot.ignored = t
		slot.ignoreTexture:SetShown(t)
		if t then C_EquipmentSet.IgnoreSlotForSave(i) end
	end
end

-- 事件处理
local function OnManagerItemClick(item)
	local manager = item:GetParent()
	if not item.name or item.name == '' then
		item:Disable()
		item:SetChecked(false)
		return
	end
	if item == manager.selected then
		manager.selected = nil
		return
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	RefreshIgnoredSlots(manager, item.setId)
	SelectManagerItem(manager, item)
	if manager.popup:IsShown() then
		local popup = manager.popup
		popup.editor:SetText(item.name)
		local pos = item:GetID()
		if item.icon:GetTexture() == popup.icons[pos] then
			SelectPopupIcon(popup, 0, pos)
		end
	end
end
local function OnManagerItemEnter(item)
	if not item.name or item.name == '' then return end
	GameTooltip_SetDefaultAnchor(GameTooltip, item)
	GameTooltip:SetEquipmentSet(item.name)
end
local function OnManagerItemDrag(item)
	if not item.name or item.name == '' then return end
	C_EquipmentSet.PickupEquipmentSet(item.setId)
end

-- 按钮事件
local function OnManagerButtonSave(button)
	local manager = button:GetParent()
	manager.popup:Show()
end
local function OnManagerButtonDelete(button)
	local manager = button:GetParent()
	local item = manager.selected
	if not item then return end
	local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', item.name)
	if dialog then
		dialog.data = item.setId
	else
		UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
	end
end
local function OnManagerButtonEquip(button)
	local manager = button:GetParent()
	local item = manager.selected
	if not item then return end
	if C_EquipmentSet.EquipmentSetContainsLockedItems(item.setId) or UnitCastingInfo('player') then
		UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
		return
	end
	C_EquipmentSet.UseEquipmentSet(item.setId)
end

-- 更新管理器
local function UpdateManager(manager)
	local items = manager.items
	local sets = C_EquipmentSet.GetEquipmentSetIDs()
	for i, id in ipairs(sets) do
		local name, texture = C_EquipmentSet.GetEquipmentSetInfo(id)
		local item = items[i]
		item:Enable()
		item.name = name
		item.setId = id
		item.text:SetText(name)
		item.icon:SetTexture(texture or 'Interface/Icons/INV_Misc_QuestionMark')
		item:SetChecked(false)
	end
	for i = #sets + 1, SET_LIMIT do
		local item = items[i]
		item:Disable()
		item:SetChecked(false)
		item.name = nil
		item.setId = nil
		item.text:SetText('')
		item.icon:SetTexture('')
	end
	if manager.selected and not manager.selected:IsEnabled() then
		manager.selected = nil
	end
	SelectManagerItem(manager, manager.selected)
end

-- 修复忽略槽位
local function FixIgnoredSlotsAfterCreation(manager, id)
	for _, t in ipairs(C_EquipmentSet.GetIgnoredSlots(id)) do
		if t then return end
	end
	local found = false
	for _, slot in ipairs(manager.slotButtons) do
		if slot.ignored then
			found = true
break
		end
	end
	if not found then return end
	C_Timer.After(0.5, function() C_EquipmentSet.SaveEquipmentSet(id) end)
end

-- 事件处理器
local function OnManagerEvent(manager, event, ...)
	if event == 'EQUIPMENT_SETS_CHANGED' then
		UpdateManager(manager)
		if not manager.newSetCount then return end
		local item = manager.items[manager.newSetCount + 1]
		manager.newSetCount = nil
		if not item.setId then return end
		SelectManagerItem(manager, item)
		FixIgnoredSlotsAfterCreation(manager, item.setId)
	elseif event == 'EQUIPMENT_SWAP_FINISHED' then
		local success, id = ...
		if not success or not manager:IsShown() then return end
		UpdateManager(manager)
		RefreshIgnoredSlots(manager, id)
	end
end

-- 显示/隐藏事件
local function OnManagerShow(manager)
	addonTable.gear:SetButtonState('PUSHED', 1)
	manager:RegisterEvent('EQUIPMENT_SETS_CHANGED')
	PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
	manager.selected = nil
	ClearIgnoredSlots(manager)
	UpdateManager(manager)
end
local function OnManagerHide(manager)
	addonTable.gear:SetButtonState('NORMAL')
	manager:UnregisterEvent('EQUIPMENT_SETS_CHANGED')
	PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	manager.selected = nil
	ClearIgnoredSlots(manager)
end

-- 飞出功能
local function OnFlyoutSeatEnter(seat)
	local loc = seat.location
	if not loc then return end
	GameTooltip:SetOwner(seat, 'ANCHOR_RIGHT')
	if loc < 0 then
		GameTooltip:SetText(seat.name)
		return
	end
	local _, slot, bag = unpack(seat.info)
	if not bag then
		GameTooltip:SetInventoryItem('player', slot)
	else
		GameTooltip:SetBagItem(bag, slot)
	end
end
local function DisplayFlyoutSeat(seat, baseSlot, loc)
	seat.info = nil
	seat.location = loc
	if not loc then return end
	seat:Show()
	if loc >= 0 then
		local p, b, g, slot, bag = UnpackLocation(loc)
		if not g then
			seat.icon:SetTexture(GetInventoryItemTexture('player', slot))
		else
			seat.icon:SetTexture(C_Item.GetItemIconByID(C_Container.GetContainerItemID(bag, slot)))
		end
		seat.info = { g, slot, bag }
	elseif loc == -2 then
		seat.icon:SetTexture('Interface/PaperDollInfoFrame/UI-GearManager-ItemIntoBag')
		seat.name = EQUIPMENT_MANAGER_PLACE_IN_BAGS
	elseif loc == -1 then
		seat.icon:SetTexture(baseSlot.ignored and 'Interface/PaperDollInfoFrame/UI-GearManager-Undo' or
			'Interface/PaperDollInfoFrame/UI-GearManager-LeaveItem-Opaque')
		seat.name = baseSlot.ignored and EQUIPMENT_MANAGER_UNIGNORE_SLOT or EQUIPMENT_MANAGER_IGNORE_SLOT
	end
	seat.icon:Show()
	if seat:IsMouseOver() then OnFlyoutSeatEnter(seat) end
end
local function OnFlyoutSeatClick(seat, button, down)
	local loc = seat.location
	local flyout = addonTable.flyout
	local baseSlot = flyout.owner
	if not loc or not baseSlot then return end
	local id = baseSlot:GetID()
	if loc == -1 then
		if baseSlot.ignored then
			baseSlot.ignored = nil
			baseSlot.ignoreTexture:Hide()
			C_EquipmentSet.UnignoreSlotForSave(id)
		else
			baseSlot.ignored = 1
			baseSlot.ignoreTexture:Show()
			C_EquipmentSet.IgnoreSlotForSave(id)
		end
		DisplayFlyoutSeat(seat, baseSlot, loc)
		return
	end
	if UnitAffectingCombat('player') then return end
	flyout:UnregisterAllEvents()
	if loc >= 0 then
		local _, slot, bag = unpack(seat.info)
		if not bag then
			PickupInventoryItem(slot)
		else
			C_Container.PickupContainerItem(bag, slot)
		end
	elseif loc == -2 then
		PickupInventoryItem(id)
	end
	if not CursorHasItem() then return end
	flyout:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
	if loc >= 0 then
		PickupInventoryItem(id)
		ClearCursor()
	elseif loc == -2 then
		PlaceCursorItemInBags()
	end
end
local function OnFlyoutAreaLeave(area)
	if area:IsMouseOver() then return end
	GameTooltip:Hide()
	area:GetParent():Hide()
end
local function OnFlyoutSeatLeave(seat) OnFlyoutAreaLeave(seat:GetParent()) end
local function OnFlyoutHide(flyout)
	local slot = flyout.owner
	flyout.owner = nil
	if slot and slot.hasItem and GameTooltip:IsShown() then
		local seat = GameTooltip:GetOwner()
		if seat and seat:GetParent() == flyout.area then
			GameTooltip:SetOwner(slot, 'ANCHOR_RIGHT')
			GameTooltip:SetInventoryItem('player', slot:GetID(), nil, true)
		end
	end
end

-- 显示飞出
local function DisplayFlyout(flyout, slot)
	if not slot then return end
	local id = slot:GetID()
	local list, arr = {}, {}
	if slot.hasItem then tinsert(arr, -2) end
	if addonTable.manager and addonTable.manager:IsShown() then tinsert(arr, -1) end
	GetInventoryItemsForSlot(id, list)
	for loc in pairs(list) do
		if loc - id ~= ITEM_INVENTORY_LOCATION_PLAYER then tinsert(arr, loc) end
	end
	table.sort(arr)
	local num = min(#arr, FLYOUT_LIMIT)
	if num == 0 then
		flyout:Hide()
return
	end
	flyout.owner = slot
	local area = flyout.area
	local seats = area.seats
	while #seats < num do
		local seat = CreateFrame('Button', nil, area, 'ItemButtonTemplate')
		seat:SetScript('OnEnter', OnFlyoutSeatEnter)
		seat:SetScript('OnLeave', OnFlyoutSeatLeave)
		seat:SetScript('OnClick', OnFlyoutSeatClick)
		local len = #seats
		local cy = len / 5
		if cy == 0 then
			seat:SetPoint('TOPLEFT', area, 'TOPLEFT', 3, -3)
		elseif floor(cy) == cy then
			seat:SetPoint('TOPLEFT', seats[len - 4], 'BOTTOMLEFT', 0, -3)
		else
			seat:SetPoint('TOPLEFT', seats[len], 'TOPRIGHT', 4, 0)
		end
		tinsert(seats, seat)
	end
	for i, seat in ipairs(seats) do
		if i <= num then
			DisplayFlyoutSeat(seat, slot, arr[i])
		else
			seat:Hide()
		end
	end
	flyout:ClearAllPoints()
	flyout:SetFrameLevel(slot:GetFrameLevel() - 1)
	flyout:SetPoint('TOPLEFT', slot, 'TOPLEFT', -3, 3)
	if id >= 16 and id <= 18 then
		area:SetPoint('TOPLEFT', flyout, 'BOTTOMLEFT', 0, -3)
	else
		area:SetPoint('TOPLEFT', flyout, 'TOPRIGHT', 0, 0)
	end
	local cx = min(5, num)
	area:SetSize(cx * 37 + (cx - 1) * 4 + 5, 43 + floor((num - 1) / 5) * 43)
	flyout:Show()
	flyout:Raise()
	if slot.hasItem and GameTooltip:IsOwned(slot) then
		GameTooltip:SetOwner(seats[cx], 'ANCHOR_RIGHT', 4, 0)
		GameTooltip:SetInventoryItem('player', id, nil, true)
	end
end

-- 飞出事件
local function OnFlyoutItemChanged(flyout, event, ...)
	flyout:UnregisterAllEvents()
	DisplayFlyout(flyout, flyout.owner)
end
local function OnFlyoutModify(slot, event, key, down)
	if event ~= 'MODIFIER_STATE_CHANGED' or not (key == 'LALT' or key == 'RALT') then return end
	local flyout = addonTable.flyout
	if down == 1 then
		DisplayFlyout(flyout, slot)
	else
		flyout:Hide()
	end
end
local function OnEquipSlotEnter(slot)
	OnFlyoutModify(slot, 'MODIFIER_STATE_CHANGED', 'LALT', IsAltKeyDown() and 1 or 0)
end
local function OnEquipSlotUpdate(slot)
	if not slot.ignoreTexture then return end
	if not addonTable.manager:IsShown() then slot.ignored = nil end
	if slot.ignored then
		slot.ignoreTexture:Show()
	else
		slot.ignoreTexture:Hide()
	end
end

-- 弹窗功能
local function OnPopupButtonOkay(button)
	local popup = button:GetParent()
	local name = strtrim(popup.editor:GetText())
	if name == '' then
		popup.editor:SetFocus()
return
	end
	local id = C_EquipmentSet.GetEquipmentSetID(name)
	local icon = popup.icons[popup.selected]
	local manager = popup:GetParent()
	manager.newSetCount = nil
	if id then
		local dialog = StaticPopup_Show('CONFIRM_OVERWRITE_EQUIPMENT_SET_' .. addonName, name)
		if dialog then
			dialog.data = id
			dialog.selectedIcon = icon
		else
			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
		end
		return
	end
	local count = C_EquipmentSet.GetNumEquipmentSets()
	if count >= SET_LIMIT then
		UIErrorsFrame:AddMessage(EQUIPMENT_SETS_TOO_MANY, 1.0, 0.1, 0.1, 1.0)
		return
	end
	manager.newSetCount = count
	C_EquipmentSet.CreateEquipmentSet(name, icon)
	popup:Hide()
end
local function OnPopupHide(popup)
	popup.editor:SetText('')
	popup.editor:ClearFocus()
	popup.selected = nil
	popup.icons = nil
	local manager = popup:GetParent()
	manager.buttonSave:Enable()
end
local function UpdatePopup(popup)
	local items = popup.items
	local icons = popup.icons
	local scroll = popup.scrollFrame
	local slider = scroll.slider
	local offset = floor(slider:GetValue() + 0.5)
	local range = ceil(#popup.icons / ROW)
	slider.ScrollUpButton:SetEnabled(offset > 0)
	slider.ScrollDownButton:SetEnabled(offset < range - COL)
	for i = 1, ROW * COL do
		local item = items[i]
		local icon = icons[(offset * ROW) + i]
		item.icon:SetTexture(icon or '')
		item:SetChecked(false)
		item:SetEnabled(icon and true or false)
	end
	SelectPopupIconInternal(popup, offset, popup.selected, true)
end
local function OnPopupScrollWheel(scroll, offset)
	local slider = scroll.slider
	slider:SetValue(slider:GetValue() - offset)
end
local function OnPopupScroll(scroll, offset) UpdatePopup(scroll:GetParent()) end
local function OnPopupShow(popup)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
	local manager = popup:GetParent()
	manager.buttonSave:Disable()
	popup.editor:SetFocus()
	popup.icons = GetPlayerIcons()
	local range = ceil(#popup.icons / ROW)
	local scroll = popup.scrollFrame
	local slider = scroll.slider
	if range > COL then
		local h = slider:GetHeight() * COL / range
		if h > 24 then slider.ThumbTexture:SetHeight(h) end
		slider:SetMinMaxValues(0, range - COL)
		scroll:SetScript('OnVerticalScroll', OnPopupScroll)
		scroll:SetScript('OnMouseWheel', OnPopupScrollWheel)
	else
		slider:SetMinMaxValues(0, 0)
		slider.ScrollDownButton:Disable()
		slider.ScrollUpButton:Disable()
		scroll:SetScript('OnVerticalScroll', nil)
		scroll:SetScript('OnMouseWheel', nil)
	end
	slider:SetValue(0)
	if manager.selected then
		local set = manager.selected
		local pos = set:GetID()
		if set.icon:GetTexture() == popup.icons[pos] then popup.selected = pos end
		popup.editor:SetText(set.name)
	end
	UpdatePopup(popup)
end
local function OnPopupIconClick(icon)
	local popup = icon:GetParent()
	local scroll = popup.scrollFrame
	local offset = floor(scroll.slider:GetValue() + 0.5)
	local selected = (offset * ROW) + icon:GetID()
	if selected == popup.selected then
		popup.selected = nil
		return
	end
	SelectPopupIcon(popup, offset, selected)
end
local function OnPopupScrollUp(self)
	local slider = self:GetParent()
	slider:SetValue(slider:GetValue() - 1)
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
end
local function OnPopupScrollDown(self)
	local slider = self:GetParent()
	slider:SetValue(slider:GetValue() + 1)
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
end
local function InitializePopupScroll(popup)
	local scroll = CreateFrame('ScrollFrame', nil, popup)
	scroll:SetSize(344, 266)
	scroll:SetPoint('TOPRIGHT', popup, 'TOPRIGHT', -13, -88)
	local slider = CreateFrame('Slider', nil, scroll, 'UIPanelScrollBarTemplate')
	slider:SetPoint('TOPLEFT', scroll, 'TOPRIGHT', -20, -16)
	slider:SetPoint('BOTTOMLEFT', scroll, 'BOTTOMRIGHT', 6, 16)
	slider:SetMinMaxValues(0, 0)
	slider:SetValue(0)
	scroll.slider = slider
	slider.ScrollUpButton:SetScript('OnClick', OnPopupScrollUp)
	slider.ScrollDownButton:SetScript('OnClick', OnPopupScrollDown)
	slider.ThumbTexture:SetTextureSliceMargins(6, 8, 6, 8)
	return scroll
end
local function InitializePopup(manager)
	local popup = CreateFrame('Frame', nil, manager, 'SelectionFrameTemplate')
	popup:Hide()
	popup:ClearAllPoints()
	popup:SetSize(372, 392)
	popup:SetPoint('TOPLEFT', manager, 'BOTTOMLEFT', 0, 8)
	popup:SetScript('OnShow', OnPopupShow)
	popup:SetScript('OnHide', OnPopupHide)
	popup.OnCancel = HideParent
	popup.OnOkay = OnPopupButtonOkay
	local label = popup:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	label:SetPoint('TOPLEFT', 24, -18)
	label:SetText(GEARSETS_POPUP_TEXT)
	local label2 = popup:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	label2:SetPoint('TOPLEFT', 24, -69)
	label2:SetText(MACRO_POPUP_CHOOSE_ICON)
	local bg = popup:CreateTexture(nil, 'BACKGROUND')
	bg:SetPoint('TOPLEFT', 7, -7)
	bg:SetPoint('BOTTOMRIGHT', -7, 7)
	bg:SetColorTexture(0, 0, 0, 0.8)
	local editor = CreateFrame('EditBox', nil, popup, 'InputBoxTemplate')
	editor:SetSize(182, 20)
	editor:SetPoint('TOPLEFT', 26, -35)
	editor:SetMaxLetters(16)
	editor:SetAutoFocus(false)
	editor:SetHistoryLines(0)
	editor:SetScript('OnEscapePressed', HideParent)
	popup.editor = editor
	popup.scrollFrame = InitializePopupScroll(popup)
	local items = {}
	for i = 1, ROW * COL do
		local item = CreateFrame('CheckButton', nil, popup, 'SimplePopupButtonTemplate')
		item:SetID(i)
		item:SetScript('OnClick', OnPopupIconClick)
		item:SetNormalTexture('')
		local icon = item:GetNormalTexture()
		icon:SetPoint('CENTER', 0, -1)
		icon:SetSize(36, 36)
		item.icon = icon
		item:SetHighlightTexture('Interface/Buttons/ButtonHilight-Square', 'ADD')
		item:SetCheckedTexture('Interface/Buttons/CheckButtonHilight')
		item:GetCheckedTexture():SetBlendMode('ADD')
		local cy = (i - 1) / ROW
		if cy == 0 then
			item:SetPoint('TOPLEFT', 24, -90)
		elseif cy == floor(cy) then
			item:SetPoint('TOPLEFT', items[i - ROW], 'BOTTOMLEFT', 0, -8)
		else
			item:SetPoint('TOPLEFT', items[i - 1], 'TOPRIGHT', 8, 0)
		end
		tinsert(items, item)
	end
	popup.items = items
	return popup
end

-- 初始化
local function ConfirmManagerOverwrite(self)
	C_EquipmentSet.SaveEquipmentSet(self.data, self.selectedIcon)
	addonTable.manager.popup:Hide()
end
local function InitializeManager(parent)
	local manager = CreateFrame('Frame', nil, parent, 'UIPanelDialogTemplate')
	manager:SetSize(261, 155)
	manager:SetPoint('TOPLEFT', parent, 'TOPRIGHT', -38, -10)
	manager:SetFrameStrata('HIGH')
	manager:SetToplevel(true)
	manager.Title:SetText(EQUIPMENT_MANAGER)
	local close = manager:GetChildren()
	close:SetPoint('TOPRIGHT', 2, 1)
	close:SetScript('OnClick', HideParent)
	local items = {}
	for i = 1, 10 do
		local item = CreateFrame('CheckButton', nil, manager, 'PopupButtonTemplate')
		item:SetID(i)
		if i == 1 then
			item:SetPoint('TOPLEFT', manager, 'TOPLEFT', 16, -32)
		elseif i == 6 then
			item:SetPoint('TOP', items[1], 'BOTTOM', 0, -10)
		else
			item:SetPoint('LEFT', items[i - 1], 'RIGHT', 13, 0)
		end
		item:SetScript('OnClick', OnManagerItemClick)
		item:SetScript('OnEnter', OnManagerItemEnter)
		item:SetScript('OnLeave', TipLeave)
		item:SetScript('OnDragStart', OnManagerItemDrag)
		item:RegisterForDrag('LeftButton')
		local text, _, icon = item:GetRegions()
		item.text = text
		item.icon = icon
		tinsert(items, item)
	end
	manager.items = items
	manager:Hide()
	manager:SetScript('OnShow', OnManagerShow)
	manager:SetScript('OnHide', OnManagerHide)
	manager:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
	manager:SetScript('OnEvent', OnManagerEvent)
	local mk = function(anchor, pt, x, y, text, onclick)
		local button = CreateFrame('Button', nil, anchor, 'UIPanelButtonTemplate')
		button:SetSize(78, 22)
		button:SetPoint(pt, x, y)
		button:SetScript('OnClick', onclick)
		button:SetText(text)
		return button
	end
	manager.buttonEquip = mk(manager, 'BOTTOMLEFT', 93, 12, EQUIPSET_EQUIP or 'Equip', OnManagerButtonEquip)
	manager.buttonDelete = mk(manager, 'BOTTOMLEFT', 11, 12, DELETE or 'Delete', OnManagerButtonDelete)
	manager.buttonSave = mk(manager, 'BOTTOMRIGHT', -8, 12, SAVE or 'Save', OnManagerButtonSave)
	local buttons = { PaperDollItemsFrame:GetChildren() }
	local slots = {}
	for i = 1, 19 do
		local button = buttons[i]
		slots[button:GetID()] = button
		local tex = button:CreateTexture(nil, 'OVERLAY')
		tex:Hide()
		tex:SetSize(40, 40)
		tex:SetPoint('CENTER')
		tex:SetTexture('Interface/PaperDollInfoFrame/UI-GearManager-LeaveItem-Transparent')
		button.ignoreTexture = tex
	end
	manager.slotButtons = slots
	hooksecurefunc('PaperDollItemSlotButton_Update', OnEquipSlotUpdate)
	manager.popup = InitializePopup(manager)
	local overwrite = CreateFromMixins(StaticPopupDialogs['CONFIRM_OVERWRITE_EQUIPMENT_SET'], { OnAccept = ConfirmManagerOverwrite })
	StaticPopupDialogs['CONFIRM_OVERWRITE_EQUIPMENT_SET_' .. addonName] = overwrite
	return manager
end

-- 主功能
local function ToggleGear(gear)
	local manager = addonTable.manager
	if not manager then
		manager = InitializeManager(gear:GetParent())
		addonTable.manager = manager
	end
	if manager:IsShown() then
		manager:Hide()
	else
		manager:Show()
manager:Raise()
	end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_LOGIN')
frame:SetScript('OnEvent', function(self)
	self:UnregisterEvent('PLAYER_LOGIN')
	self:SetScript('OnEvent', nil)
	if GearManagerToggleButton and GearManagerToggleButton:IsShown() then return end
	local gear = CreateFrame('Button', nil, PaperDollFrame)
	gear:SetSize(32, 32)
	gear:SetPoint('TOPRIGHT', -44, -39)
	gear:SetNormalTexture('Interface/PaperDollInfoFrame/UI-GearManager-Button')
	gear:SetPushedTexture('Interface/PaperDollInfoFrame/UI-GearManager-Button-Pushed')
	gear:SetHighlightTexture('Interface/Buttons/UI-MicroButton-Hilight', 'ADD')
	gear:GetHighlightTexture():SetTexCoord(0, 1, 0.390625, 0.96875)
	gear:SetScript('OnEnter', TipEnter)
	gear:SetScript('OnLeave', TipLeave)
	gear:SetScript('OnClick', ToggleGear)
	gear.name = EQUIPMENT_MANAGER or GetAddOnMetadata(addonName, 'Title')
	PaperDollFrame[addonName] = gear
	addonTable.gear = gear
	local flyout = CreateFrame('Frame', nil, PaperDollFrame)
	flyout:SetSize(43, 43)
	flyout:EnableMouse(false)
	flyout:SetFrameStrata('HIGH')
	flyout:Hide()
	flyout:SetScript('OnEvent', OnFlyoutItemChanged)
	flyout:SetScript('OnHide', OnFlyoutHide)
	local tex = flyout:CreateTexture(nil, 'OVERLAY')
	tex:SetSize(50, 50)
	tex:SetPoint('LEFT', -4, 0)
	tex:SetTexture('Interface/PaperDollInfoFrame/UI-GearManager-ItemButton-Highlight')
	tex:SetTexCoord(0, 0.78125, 0, 0.78125)
	local area = CreateFrame('Frame', nil, flyout)
	area:SetPoint('TOPLEFT', flyout, 'TOPRIGHT')
	area:SetFrameStrata('DIALOG')
	area:SetScript('OnLeave', OnFlyoutAreaLeave)
	area.seats = {}
	flyout.area = area
	addonTable.flyout = flyout
	hooksecurefunc('PaperDollItemSlotButton_OnEvent', OnFlyoutModify)
	hooksecurefunc('PaperDollItemSlotButton_OnEnter', OnEquipSlotEnter)
end)
