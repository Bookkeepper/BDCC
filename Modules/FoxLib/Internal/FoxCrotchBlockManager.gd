const Globals = preload("res://FoxLib/Globals.gd")
const FoxButton = preload("res://FoxLib/UI/FoxButton.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const VisSlotVar = preload("res://Game/Datapacks/UI/CrotchCode/VisualSlots/VisSlotVar.gd")

class FoxCrotchBlockRegistry extends Object:
	var registry = {}
	var allTriggers = null

static func postInitialize():
	# We will hook the AlwaysTrue block to allow listening to code block selectors
	var hookAlwaysTrue = load("res://Modules/FoxLib/Hooks/CrotchBlocks/AlwaysTrue.gd")
	GlobalRegistry.codeblocksCache["AlwaysTrue"] = hookAlwaysTrue

static func registerCrotchBlockFile(fileName):
	if not fileName.begins_with("res://"):
		Log.error("[FoxLib] Failed to register: " + fileName)
		Log.error("[FoxLib] CrotchBlocks must be inside your mod and cannot be auto generated")
		FoxUIManager.setHideConsoleAfterLoading(false)
		return
	if not fileName.ends_with(".gd"):
		Log.error("[FoxLib] Failed to register: " + fileName)
		Log.error("[FoxLib] CrotchBlocks must be have the .gd extension")
		FoxUIManager.setHideConsoleAfterLoading(false)
		return
	# Register Crotchblocks
	var id = "../../../../../" + fileName.substr(6, fileName.length() - 9)
	# The first calls always return something, the second call is more representative
	var newCodeBlock = CrotchBlocks.createBlock(id)
	var newCodeBlock2 = CrotchBlocks.createBlock(id)
	if newCodeBlock == null or newCodeBlock2 == null:
		Log.error("[FoxLib] Failed to register: " + fileName)
		Log.error("[FoxLib] Please make sure your CrotchBlock file is formatted correctly")
		FoxUIManager.setHideConsoleAfterLoading(false)
		return
	# Test that getVar is implemented correctly, as if getVar is not implemeted correctly it may cause the game to segfault
	var failedTest = false
	var failedMessage = "[FoxLib] Missing or broken getVar() implementation for: "
	for entry in newCodeBlock2.getTemplate():
		if(entry["type"] in CodeBlockBase.savedSlotTypes):
			var slotId = entry["id"]
			var varSlot = newCodeBlock2.getSlot(slotId)
			if varSlot == null or varSlot != entry["slot"]:
				failedMessage = failedMessage + slotId + ", "
				failedTest = true
	if failedTest:
		Log.error("[FoxLib] Failed to register: " + fileName)
		Log.error(failedMessage.substr(0, failedMessage.length() - 2))
		FoxUIManager.setHideConsoleAfterLoading(false)
		return
	Globals.of(FoxCrotchBlockRegistry).registry[id] = fileName

static func registerCustomTrigger(trigger):
	var registry = Globals.of(FoxCrotchBlockRegistry)
	var triggerName = DatapackSceneTriggerType.getName(trigger)
	if registry.allTriggers == null:
		registry.allTriggers = DatapackSceneTriggerType.getAllWithNames()
	registry.allTriggers.append([trigger, triggerName])

# GUI Stuff
# const collapseScene = preload("res://Game/Datapacks/UI/PackVarsCollapsableRegion.tscn")

class TriggerTypeSelectorWrapper:
	var allTriggers = null
	var originalTriggerTypeSelector = null
	func setData(_dataLine:Dictionary):
		_dataLine.values = self.allTriggers
		self.originalTriggerTypeSelector.setData(_dataLine)

class GuiUpdateScheduler extends Node:
	var registry = null
	var codeBlockList = null
	var datapackSceneEditor = null
	func appendRegistry():
		var filter:int = codeBlockList.filter
		var editor = codeBlockList.editor
		var collapsables = codeBlockList.collapsables
		var no_category_list = codeBlockList.no_category_list
		var categories_list = codeBlockList.categories_list
		var collapseScene = codeBlockList.collapseScene
		# Partial copy of Game/Datapacks/UI/CrotchCode/PossibleCodeBlocksList.gd
		for blockID in registry.registry.keys():
			# Log.print("[FoxLib] Checking CrotchBlock: " + blockID)
			var testCodeblock = CrotchBlocks.createBlock(blockID)
			
			if testCodeblock == null:
				Log.error("[FoxLib] Failing CrotchBlock: " + blockID)
				continue
			
			var supportedEditors:int = testCodeblock.getSupportedEditors()
			if(!(filter & supportedEditors)):
				continue
			
			# Log.print("[FoxLib] Adding CrotchBlock: " + blockID)
			var categories = testCodeblock.getCategories()
			
			for category in categories:
				var nodeToAddTo = null
				if(category == ""):
					nodeToAddTo = null
				else:
					if(collapsables.has(category)):
						nodeToAddTo = collapsables[category]
					else:
						var newCollapse = collapseScene.instance()
						newCollapse.editor = editor
						categories_list.add_child(newCollapse)
						newCollapse.makeCodeBlockMode()
						newCollapse.setText(category)
						collapsables[category] = newCollapse
						nodeToAddTo = newCollapse
				
				var visualScene = load("res://Game/Datapacks/UI/CrotchCode/CrotchBlockVisual.tscn").instance()
				if(visualScene == null):
					continue
				visualScene.editor = editor
				visualScene.id = blockID
				visualScene.setIsPickedVersion()
				if(nodeToAddTo == null):
					no_category_list.add_child(visualScene)
				else:
					nodeToAddTo.addToRegion(visualScene)
				visualScene.setCodeBlock(testCodeblock)
		# Install the extra triggers types
		if datapackSceneEditor != null and registry.allTriggers != null:
			var trigger_type_selector = datapackSceneEditor.trigger_type_selector
			if not ("allTriggers" in trigger_type_selector):
				var wrapped_trigger_type_selector = TriggerTypeSelectorWrapper.new()
				wrapped_trigger_type_selector.allTriggers = registry.allTriggers
				wrapped_trigger_type_selector.originalTriggerTypeSelector = trigger_type_selector
				datapackSceneEditor.trigger_type_selector = wrapped_trigger_type_selector
		# Log.print("[FoxLib] Append registry done!")
		self.call_deferred("free")

static func getDatapackSceneEditorFromNode(node):
	var toCheck = node
	while(toCheck != null):
		if(toCheck.has_method("updateSelectedTrigger")):
			return toCheck
		toCheck = toCheck.get_parent()
	return null

# https://github.com/Alexofp/BDCC/blob/main/Game/Datapacks/UI/CrotchCode/PossibleCodeBlocksList.gd
# https://gamedev.stackexchange.com/questions/192245/how-to-disconnect-all-signals-of-an-emitter
static func checkCodeContainers():
	var registry = Globals.of(FoxCrotchBlockRegistry)
	var signals = CrotchFavBlocks.get_signal_connection_list("onBlocksChanged")
	for cur_signal in signals:
		var target = cur_signal.target
		# Log.print("[FoxLib] Target: " + str(target))
		# TODO: Check for code block entries in a better way
		if target is VBoxContainer:
			var hasScheduler = false
			for node in target.get_children():
				if node is GuiUpdateScheduler:
					hasScheduler = true
			if target.categories_list.get_child_count() < 3 and not hasScheduler:
				var scheduler = GuiUpdateScheduler.new()
				scheduler.registry = registry
				scheduler.codeBlockList = target
				scheduler.datapackSceneEditor = getDatapackSceneEditorFromNode(target)
				target.add_child(scheduler)
				scheduler.call_deferred("appendRegistry")

# https://github.com/Alexofp/BDCC/blob/main/Game/Datapacks/UI/CrotchCode/VisualSlots/VisSlotVar.gd
# https://github.com/Alexofp/BDCC/blob/main/Game/Datapacks/UI/CrotchCode/VisualSlots/BlockCatcherPanel.gd
const flagsPickingScene = preload("res://Modules/FoxLib/UI/FlagsPickingWindow.tscn")

class FoxCrotchFlagsSlotHandler extends Object:
	var foxCrotchFlagSlot
	var blockCatcherPanel
	var placeholder
	var buttonRef
	
	func onButtonPressed():
		var newWindow = flagsPickingScene.instance()
		self.blockCatcherPanel.add_child(newWindow)
		newWindow.buttonRef = self.buttonRef
		var nonNullPlaceholder = self.placeholder
		if nonNullPlaceholder == null:
			nonNullPlaceholder = ""
		newWindow.setData({
			value = foxCrotchFlagSlot.rawValue,
			values = blockCatcherPanel.rawPossibleValues,
			placeholder = nonNullPlaceholder,
			impliedFlags = foxCrotchFlagSlot.impliedFlags,
			exclusiveFlags = foxCrotchFlagSlot.exclusiveFlags,
			forceAtLeastOneFlag = foxCrotchFlagSlot.forceAtLeastOneFlag,
		})
		newWindow.connect("onCancel", self.blockCatcherPanel, "onMapButtonClosed")
		newWindow.connect("onConfirm", self.blockCatcherPanel, "onAdvPickerConfirmPressed")
		newWindow.popup_centered()

static func checkFoxCrotchFlagSlot(foxCrotchFlagSlot):
	var signals = foxCrotchFlagSlot.get_signal_connection_list("onBlockChanged")
	for cur_signal in signals:
		var target = cur_signal.target
		if target is VisSlotVar and target.is_inside_tree():
			var blockCatcherPanel = target.block_catcher_panel
			var marginContainer = blockCatcherPanel.get_node("MarginContainer")
			var hasFoxButton = false
			for node in marginContainer.get_children():
				if node is FoxButton:
					hasFoxButton = true
			if hasFoxButton:
				return
			blockCatcherPanel.extraMode = -1
			blockCatcherPanel.rawPossibleValues = []
			blockCatcherPanel.updateRawVis()
			var handler = FoxCrotchFlagsSlotHandler.new()
			handler.foxCrotchFlagSlot = foxCrotchFlagSlot
			handler.blockCatcherPanel = blockCatcherPanel
			handler.placeholder = marginContainer.get_node("LineEdit").placeholder_text
			var button = FoxButton.new()
			handler.buttonRef = weakref(button)
			button.connect_on_pressed(handler, "onButtonPressed")
			marginContainer.add_child(button)
			button.text = foxCrotchFlagSlot.rawValue

