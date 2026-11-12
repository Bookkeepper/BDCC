extends "res://FoxLib/FoxOption.gd"

var flagModule = null
var flagID = null

func _init():
	enable = OPTION_ENABLE_INGAME

func getOptionValueImpl():
	if flagID == null:
		return defaultValue
	if flagModule == null:
		return GM.main.getFlag(flagID, defaultValue)
	else:
		return GM.main.getModuleFlag(flagModule, flagID, defaultValue)

func setOptionValueImpl(value):
	if flagID == null:
		return
	if flagModule == null:
		GM.main.setFlag(flagID, value)
	else:
		GM.main.setModuleFlag(flagModule, flagID, value)

func resetOptionValueImpl():
	if flagID == null:
		return
	if flagModule == null:
		GM.main.clearFlag(flagID)
	else:
		GM.main.clearDatapackFlag(flagModule, flagID)

