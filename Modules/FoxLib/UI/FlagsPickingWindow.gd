extends WindowDialog

const FLAGS_DELIMITER = ", "
const CHECKED_SUFFIX = " ✓"

var values = []
var allFlags = []
var selectedValue
var selectedFlags
var placeholder = ""
var impliedFlags = {}
var impliedFlagsRev = {}
var exclusiveFlags = []
var forceAtLeastOneFlag = false
var id

var buttonRef = null
var visibleValues = []

onready var filter_edit = $MarginContainer/VBoxContainer/FilterEdit
onready var item_list = $MarginContainer/VBoxContainer/ItemList

signal onConfirm(window, value)
signal onCancel(window)

func setData(_data):
	var updateImplied = false
	if(_data.has("values")):
		values = _data["values"]
	if(_data.has("value")):
		selectedValue = _data["value"]
		selectedFlags = selectedValue.split(FLAGS_DELIMITER)
		var emptyIndex = selectedFlags.find("")
		if emptyIndex != -1:
			selectedFlags.remove(emptyIndex)
		updateImplied = true
	if(_data.has("placeholder")):
		placeholder = _data["placeholder"]
	if(_data.has("impliedFlags")):
		impliedFlags = _data["impliedFlags"]
		impliedFlagsRev.clear()
		for flagSrc in impliedFlags.keys():
			var flagDst = impliedFlags.get(flagSrc)
			if impliedFlagsRev.has(flagDst):
				impliedFlagsRev.get(flagDst).append(flagSrc)
			else:
				impliedFlagsRev[flagDst] = [flagSrc]
		updateImplied = true
	if(_data.has("exclusiveFlags")):
		exclusiveFlags = _data["exclusiveFlags"]
	if(_data.has("forceAtLeastOneFlag")):
		forceAtLeastOneFlag = _data["forceAtLeastOneFlag"]
	if updateImplied:
		for flag in selectedFlags:
			if impliedFlags.has(flag):
				var impliedFlag = impliedFlags.get(flag)
				if not selectedFlags.has(impliedFlag):
					selectedFlags.append(impliedFlag)
	updateItemList()

func updateItemList():
	item_list.clear()
	allFlags.clear()
	visibleValues.clear()
	
	var filterText = filter_edit.text.to_lower()
	
	for value in values:
		var valueText = str(value)
		if(value is Array):
			valueText = str(value[1])
		
		if(filterText != "" && !(filterText in valueText.to_lower())):
			continue
		visibleValues.append(value)
	
	for value in visibleValues:
		var valueIndex = allFlags.size()
		var valueText = str(value)
		var valueValue = value
		var valueTooltip = valueText
		if(value is Array):
			valueValue = value[0]
			valueText = value[1]
			valueTooltip = valueText
			if value.size() >= 3:
				valueTooltip = value[2]
		
		if selectedFlags.has(valueValue):
			valueText = valueText + CHECKED_SUFFIX
		
		item_list.add_item(valueText)
		item_list.set_item_tooltip(valueIndex, valueTooltip)
		allFlags.append(valueValue)
	item_list.unselect_all()

func _on_FilterEdit_text_changed(_new_text):
	updateItemList()

func _on_ItemList_item_selected(index):
	on_ItemList_item_selected_ex(index, true)

func on_ItemList_item_selected_ex(index, root):
	var flagValue = allFlags[index]
	var flagIndex = selectedFlags.find(flagValue)
	if flagIndex != -1:
		if forceAtLeastOneFlag and selectedFlags.size() == 1:
			return
		selectedFlags.remove(flagIndex)
		if root and impliedFlagsRev.has(flagValue):
			for impliedBy in impliedFlagsRev.get(flagValue):
				var impliedByIndex = allFlags.find(impliedBy)
				if impliedByIndex != -1 and selectedFlags.find(impliedBy) != -1:
					on_ItemList_item_selected_ex(impliedByIndex, false)
	else:
		for exclusiveFlag in exclusiveFlags:
			if flagValue in exclusiveFlag:
				for flagToExclude in exclusiveFlag:
					var flagToExcludeIndex = selectedFlags.find(flagToExclude)
					if flagToExcludeIndex != -1:
						selectedFlags.remove(flagToExcludeIndex)
		selectedFlags.append(flagValue)
		if root and impliedFlags.has(flagValue):
			var impliedFlag = impliedFlags.get(flagValue)
			var impliedIndex = allFlags.find(impliedFlag)
			if impliedIndex != -1 and selectedFlags.find(impliedFlag) == -1:
				on_ItemList_item_selected_ex(impliedIndex, false)
	if root:
		updateItemList()

func _on_ConfirmButton_pressed():
	var rawValue
	if selectedFlags.size() == 0:
		rawValue = ""
	elif impliedFlags.size() == 0:
		rawValue = selectedFlags.join(FLAGS_DELIMITER)
	else:
		var selectedFlagsExlude = []
		for flag in selectedFlags:
			if impliedFlags.has(flag):
				selectedFlagsExlude.append(impliedFlags.get(flag))
		var selectedFlagsExluded = PoolStringArray()
		for flag in selectedFlags:
			if not selectedFlagsExlude.has(flag):
				selectedFlagsExluded.append(flag)
		rawValue = selectedFlagsExluded.join(FLAGS_DELIMITER)
	if (buttonRef != null):
		var button = buttonRef.get_ref()
		if (button != null):
			var textValue = rawValue
			if textValue == "":
				textValue = self.placeholder
			button.text = textValue
	
	emit_signal("onConfirm", self, rawValue)

func _on_CancelButton_pressed():
	emit_signal("onCancel", self)

func _on_AdvancedPickingWindow_popup_hide():
	emit_signal("onCancel", self)
