extends Control

onready var optionsContainer = $VBoxContainer/ScrollContainer/ScrollVBox/OptionsContainer
onready var undoButton = $VBoxContainer/GridContainer/UndoButton
var optionsCategoryScene = preload("res://Modules/FoxLib/UI/FoxLibModOptionCategory.tscn")
var optionCategoryDisabled = preload("res://Modules/FoxLib/UI/FoxLibOptionDisabledType.tscn")
var optionCategorySlider = preload("res://Modules/FoxLib/UI/FoxLibOptionSliderType.tscn")
var optionCategoryButton = preload("res://Modules/FoxLib/UI/FoxLibOptionButtonType.tscn")
var optionCategoryUnknown = preload("res://UI/Options/OptionUnknownType.tscn")
var optionCategoryCheckbox = preload("res://UI/Options/OptionCheckboxType.tscn")
var optionCategoryList = preload("res://UI/Options/OptionListType.tscn")
var optionCategoryFloat = preload("res://UI/Options/OptionFloatType.tscn")
var optionCategoryInt = preload("res://UI/Options/OptionIntType.tscn")
var optionCategoryPriorityList = preload("res://UI/Options/OptionPriorityListType.tscn")
var optionCategoryString = preload("res://UI/Options/OptionStringType.tscn")

const FoxLibThemeManager = preload("res://Modules/FoxLib/Internal/FoxLibThemeManager.gd")
const FoxOptionsManager = preload("res://Modules/FoxLib/Internal/FoxOptionsManager.gd")
const FoxLibEventUtil = preload("res://Modules/FoxLib/Internal/FoxLibEventUtil.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const Globals = preload("res://FoxLib/Globals.gd")

const OPTION_ENABLE_ALWAYS = 0
const OPTION_ENABLE_INGAME = 1
const OPTION_ENABLE_MAIN_MENU = 2
const OPTION_ENABLE_NEVER = 3
const OPTION_HIDDEN = 4

var menuHandler = null
var optionCategories = {}
var populatingOptions = false
var originalValues = {}

# tooltipObject used for BDCC 0.1.11+ compat.
var tooltipObject = null

func _ready():
	self.updateOptions()
	self.originalValues.clear()
	self.undoButton.disabled = true

func generateCategory(name):
	if self.optionCategories.has(name):
		return self.optionCategories[name]
	var optionsCategory = optionsCategoryScene.instance()
	optionsContainer.add_child(optionsCategory)
	optionsCategory.setCategoryName(name)
	self.optionCategories[name] = optionsCategory
	return optionsCategory

func updateOptions():
	FoxUIManager.hideTooltip(self.tooltipObject)
	self.tooltipObject = null
	self.populatingOptions = true
	var FoxLibModule = Globals.ofModule("FoxLib")
	self.optionCategories.clear()
	Util.delete_children(optionsContainer)
	
	var optionButtons = FoxOptionsManager.getFoxOptionsButtons()
	# Make FoxLib always be on top
	generateCategory(FoxLibModule.getName())
	
	for priorityCategory in FoxOptionsManager.getFoxOptionsPriorityCategories():
		generateCategory(priorityCategory)
	
	for optionButton in optionButtons:
		if (FoxLibModule.showAdvancedModOptions or not optionButton.advancedOnly) and (optionButton.enable != OPTION_HIDDEN):
			var optionsCategory = generateCategory(optionButton.category)
			var optionType = optionButton.type
			var optionID = optionButton.optionID
			var optionName = optionButton.title
			var optionValue = optionButton.getOptionValue()
			var optionDescription = optionButton.description
			var optionEnabled = menuHandler.isModOptionEnabled(optionButton.enable)
			# Fake forced value disable the option and set the new value as display value
			var optionFakeForcedValue = optionButton.getFakeForcedOption()
			if optionFakeForcedValue != null:
				optionEnabled = false
				optionValue = optionFakeForcedValue
			
			var optionUIObject: Node = null
			var optionDisablePath = null
			var optionDisableAlt = false
			if(optionType == "checkbox"):
				optionUIObject = optionCategoryCheckbox.instance()
				optionDisablePath = "Checkbox"
			elif(optionType == "list"):
				optionUIObject = optionCategoryList.instance()
				optionDisablePath = "List"
			elif(optionType == "float"):
				optionUIObject = optionCategoryFloat.instance()
				optionDisablePath = "SpinBox"
				optionDisableAlt = true
			elif(optionType == "int"):
				optionUIObject = optionCategoryInt.instance()
				optionDisablePath = "SpinBox"
				optionDisableAlt = true
			elif(optionType == "string"):
				optionUIObject = optionCategoryString.instance()
				optionDisablePath = "LineEdit"
				optionDisableAlt = true
			elif(optionType == "slider"):
				optionUIObject = optionCategorySlider.instance()
				optionDisablePath = "Slider"
				optionDisableAlt = true
			elif(optionType == "button"):
				optionUIObject = optionCategoryButton.instance()
				optionDisablePath = "Button"
			elif(!optionEnabled):
				optionUIObject = optionCategoryDisabled.instance()
				optionType = "disabled"
			elif(optionType == "prioritylist"):
				optionUIObject = optionCategoryPriorityList.instance()
			else:
				optionUIObject = optionCategoryUnknown.instance()
			
			if(optionUIObject == null):
				continue
			
			optionsCategory.addModOptionNode(optionUIObject)
			optionUIObject.id = optionID
			optionUIObject.categoryID = optionButton.moduleID
			optionUIObject.setOptionName(optionName)
			optionUIObject.setOptionValue(optionValue)
			if(!optionEnabled):
				if optionDisableAlt:
					optionUIObject.get_node(optionDisablePath).editable = false
				else:
					optionUIObject.get_node(optionDisablePath).disabled = true
			elif(optionUIObject.has_signal("value_changed")):
				var _ok = optionUIObject.connect("value_changed", self, "onOptionChanged")
			
			if(optionType == "string" and optionButton.placeholder != null):
				optionUIObject.setPlaceholderValue(optionButton.placeholder)
			if(optionType == "button" and optionButton.placeholder != null):
				optionUIObject.setPlaceholderValue(optionButton.placeholder)
			if(optionType == "list"):
				optionUIObject.setValues(optionButton.values)
			if(optionType == "prioritylist"):
				optionUIObject.setValues(optionButton.values)
			
			if(optionDescription != null && optionUIObject.has_signal("mouse_entered")):
				var _ok = optionUIObject.connect("mouse_entered", self, "onOptionMouseEntered", [optionUIObject])
				var _ok2 = optionUIObject.connect("mouse_exited", self, "onOptionMouseExited", [optionUIObject])
				if(optionUIObject.has_method("setDescription")):
					optionUIObject.setDescription(optionDescription)
	self.undoButton.disabled = self.originalValues.empty()
	self.call_deferred("updateOptionsDeferred")

func updateOptionsDeferred():
	if is_instance_valid(self):
		self.populatingOptions = false

func onOptionMouseEntered(optionUIObject):
	if (not self.populatingOptions) and optionUIObject.has_method("getDescription"):
		var optionName = "Option"
		if(optionUIObject.has_method("getOptionName")):
			optionName = optionUIObject.getOptionName()
		var optionDescription = optionUIObject.getDescription()
		if optionDescription != null and optionDescription != "":
			FoxUIManager.showTooltip(optionUIObject, optionName, optionDescription)
			self.tooltipObject = optionUIObject

func onOptionMouseExited(_optionUIObject):
	FoxUIManager.hideTooltip(_optionUIObject)
	if self.tooltipObject == _optionUIObject:
		self.tooltipObject = null

func backupOptionValue(optionButton):
	if not optionButton in self.originalValues:
		self.originalValues[optionButton] = optionButton.getOptionValue()

func unbackupOptionValue(optionButton):
	if (optionButton in self.originalValues) and (self.originalValues[optionButton] == optionButton.getOptionValue()):
		self.originalValues.erase(optionButton)

func onOptionChanged(categoryID, optionID, optionNewValue):
	var optionButton = FoxOptionsManager.getOptionInternal(categoryID, optionID)
	self.backupOptionValue(optionButton)
	optionButton.setOptionValue(optionNewValue)
	self.unbackupOptionValue(optionButton)
	self.undoButton.disabled = self.originalValues.empty()
	# Special case for "Show Advanced Mod Options"
	if categoryID == "FoxLib" and optionID == "showAdvancedModOptions":
		self.updateOptions()

func _on_CloseButton_pressed():
	self.originalValues.clear()
	self.optionCategories.clear()
	self.undoButton.disabled = true
	FoxOptionsManager.optionalySave()
	if menuHandler != null:
		menuHandler.closeModOptions()
	FoxLibEventUtil.internalCallModulesHandlers("onModsOptionScreenClosed")
	if menuHandler.allowSceneReload() and FoxLibThemeManager.needSceneReload():
		FoxLibThemeManager.reloadMainMenuScene()

func _on_RevertButton_pressed():
	if self.populatingOptions:
		return
	var optionButtons = FoxOptionsManager.getFoxOptionsButtons()
	for optionButton in optionButtons:
		backupOptionValue(optionButton)
	FoxOptionsManager.resetToDefaults()
	for optionButton in optionButtons:
		unbackupOptionValue(optionButton)
	self.updateOptions()

func _on_UndoButton_pressed():
	if self.populatingOptions:
		return
	for optionButton in self.originalValues:
		optionButton.setOptionValue(self.originalValues[optionButton])
	self.originalValues.clear()
	self.undoButton.disabled = true
	self.updateOptions()

