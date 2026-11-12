extends Object
#class_name FoxStatusBar
#public_api

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")

var id = null
var value = 0
var visible = false
var maxValue = 100
var defaultMaxValue = 100
var name = "Status"
var overrideText = null
var colorGradient = null
var internalProgressNode = null

static func getFromId(statusBarId):
	return load("res://Modules/FoxLib/Internal/FoxLibStatusBarsManager.gd").getFromId(statusBarId)

static func getOrMakeFromId(statusBarId):
	return load("res://Modules/FoxLib/Internal/FoxLibStatusBarsManager.gd").getOrMakeFromId(statusBarId)

func getValue():
	return value

func setValue(newValue):
	if newValue == null:
		newValue = 0
	if value == newValue:
		return
	value = newValue
	updateDisplay()

func getVisible():
	return visible

func setVisible(newVisible):
	if visible == newVisible:
		return
	visible = newVisible
	updateDisplay(true)

func getMaxValue():
	return maxValue

func setMaxValue(newMaxValue):
	if newMaxValue == null or newMaxValue < 1:
		newMaxValue = 1
	if maxValue == newMaxValue:
		return
	maxValue = newMaxValue
	updateDisplay()

func getName():
	return name

func setName(newName):
	if newName == null:
		newName = 0
	if name == newName:
		return
	name = newName
	updateDisplay()

func getOverrideText():
	return overrideText

func setOverrideText(newOverrideText):
	if overrideText == newOverrideText:
		return
	overrideText = newOverrideText
	updateDisplay()

func setGradient(gradientData, gradientData2=null):
	colorGradient = FoxUIManager.asGradient(gradientData, gradientData2)
	updateDisplay()

func getStatusText():
	if overrideText == "%":
		return str(floor((float(value) * 100) / maxValue)) + "%"
	if overrideText != null:
		return overrideText
	return str(value) + " / " + str(maxValue)

# This will return false for NPC bars when FoxLib support NPCs status bars.
func isForPlayer():
	return true

func updateDisplay(force=false):
	if not (force or visible):
		return
	if internalProgressNode == null:
		return
	internalProgressNode.visible = visible
	if colorGradient != null:
		internalProgressNode.colorGradient = colorGradient
	internalProgressNode.setProgressBarValueInt(value, maxValue)
	internalProgressNode.setTextLeft(name)
	internalProgressNode.setText(getStatusText())

func loadData(data={}):
	visible = SAVE.loadVar(data, "visible", false)
	value = SAVE.loadVar(data, "value", 0)
	maxValue = SAVE.loadVar(data, "maxValue", defaultMaxValue)
	overrideText = SAVE.loadVar(data, "overrideText", "null")
	if overrideText == "null":
		overrideText = null
	updateDisplay()

func saveData():
	var overrideTextSave = overrideText
	if overrideTextSave == null:
		overrideTextSave = "null"
	return {
		"visible": visible,
		"value": value,
		"maxValue": maxValue,
		"overrideText": overrideTextSave,
	}

func resetBar():
	visible = false
	value = 0
	maxValue = defaultMaxValue
	overrideText = null
	updateDisplay(true)

func internalTestPassValue(valuePass):
	return valuePass

