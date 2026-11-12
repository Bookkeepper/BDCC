extends Object
#class_name FoxOption
#public_api

const FoxOptionsManager = preload("res://Modules/FoxLib/Internal/FoxOptionsManager.gd")

const OPTION_ENABLE_ALWAYS = 0
const OPTION_ENABLE_INGAME = 1
const OPTION_ENABLE_MAIN_MENU = 2
const OPTION_ENABLE_NEVER = 3
const OPTION_HIDDEN = 4

signal option_changed

var moduleID = null
var category = null
var optionID = null
var title = null
var description = null
var type = null
var defaultValue = null
var placeholder = null
var values = null # Used for list options
var advancedOnly = false # Hide option by default
var alwaysInitializeOption = false # Always fill option file
var enable = OPTION_ENABLE_ALWAYS # Tell when an option can be changed
var fakeForcedOption = null # Override that force disable option and replace it's value
var disableOptionReset = false

var listenerInstance
var listenerField

var selfRegistered = false # Tell if this FoxOption is registered
var registeredOption = null # Only used if selfRegistered is false

func getOptionValueImpl():
	if self.alwaysInitializeOption:
		return FoxOptionsManager.getOrFillOption(self.moduleID, self.optionID, self.defaultValue)
	else:
		return FoxOptionsManager.getOption(self.moduleID, self.optionID, self.defaultValue)

func setOptionValueImpl(newValue):
	if type != "button" or defaultValue != null or newValue != null:
		FoxOptionsManager.setOption(self.moduleID, self.optionID, newValue)
	else:
		FoxOptionsManager.clearOption(self.moduleID, self.optionID)

func resetOptionValueImpl():
	FoxOptionsManager.clearOption(self.moduleID, self.optionID)

func getOptionValue():
	if self.registeredOption != null:
		return self.registeredOption.getOptionValue()
	else:
		return self.getOptionValueImpl()

func setOptionValue(newValue):
	if self.registeredOption != null:
		self.registeredOption.setOptionValue(newValue)
	else:
		self.setOptionValueImpl(newValue)
		self.triggerOptionChangedInternal(newValue)

func resetOptionValue():
	if self.disableOptionReset:
		return
	if self.registeredOption != null:
		self.registeredOption.resetOptionValue()
	else:
		self.resetOptionValueImpl()
		self.triggerOptionChangedInternal(self.getOptionValueImpl())

func getFakeForcedOption():
	if self.registeredOption != null:
		return self.registeredOption.getFakeForcedOption()
	else:
		return self.fakeForcedOption

func setFakeForcedOption(newValue):
	if self.registeredOption != null:
		self.registeredOption.setFakeForcedOption(newValue)
	else:
		self.fakeForcedOption = newValue
	return self

func resetFakeForcedOption():
	self.setFakeForcedOption(null)
	return self

func register():
	var optionValue = self.getOptionValue()
	var registered = FoxOptionsManager.registerFoxOption(self)
	if registered != self:
		self.selfRegistered = false
		self.registeredOption = registered
		return registered
	if not self.selfRegistered:
		self.selfRegistered = true
		self.triggerOptionChangedInternal(optionValue)
	return self

func advanced():
	self.advancedOnly = true
	return self

func alwaysInitialize():
	self.alwaysInitializeOption = true
	return self

func enableInGameOnly():
	self.enable = OPTION_ENABLE_INGAME
	return self

func enableMainMenuOnly():
	self.enable = OPTION_ENABLE_MAIN_MENU
	return self

func hidden():
	self.enable = OPTION_HIDDEN
	return self

func noOptionReset():
	self.disableOptionReset = true
	return self

func setPlaceholder(_placeholder):
	self.placeholder = _placeholder
	return self

# Only one field can be bound at the same time
func bindToField(_listenerInstance, _listenerField):
	self.listenerInstance = _listenerInstance
	self.listenerField = _listenerField
	if self.listenerInstance != null and self.listenerField != null and self.selfRegistered:
		self.updateFieldValueInternal(self.getOptionValue())
	return self

# Internal helpers
func triggerOptionChangedInternal(newValue):
	self.updateFieldValueInternal(newValue)
	emit_signal("option_changed", newValue)

func updateFieldValueInternal(newValue):
	if self.listenerInstance != null and self.listenerField != null:
		if self.listenerInstance is Dictionary:
			self.listenerInstance[self.listenerField] = newValue
		else:
			self.listenerInstance.set(self.listenerField, newValue)

