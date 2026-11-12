#nodebug
const Globals = preload("res://FoxLib/Globals.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const FoxLibModOptionsScreen = "res://Modules/FoxLib/UI/FoxLibModOptionsScreen.tres"

# Workaround Godot Bug, as regular Gogot Button sometimes doesn't trigger pressed signals
const FoxButton = preload("res://FoxLib/UI/FoxButton.gd")

const ModOptionsToolTip = "Allows to configure your mods (Provided by FoxLib)"

const OPTION_ENABLE_ALWAYS = 0
const OPTION_ENABLE_INGAME = 1
const OPTION_ENABLE_MAIN_MENU = 2
const OPTION_ENABLE_NEVER = 3
const OPTION_HIDDEN = 4

class FoxMainMenuHandler:
	var mainMenuBox
	var optionsScreen
	var modOptionsScreen
	
	func openModOptions():
		self.mainMenuBox.visible = false
		self.optionsScreen.visible = false
		self.modOptionsScreen.visible = true
	
	func closeModOptions():
		self.mainMenuBox.visible = true
		self.optionsScreen.visible = false
		self.modOptionsScreen.visible = false
	
	func isModOptionEnabled(enabledState):
		return enabledState == OPTION_ENABLE_ALWAYS or enabledState == OPTION_ENABLE_MAIN_MENU
	
	func allowSceneReload():
		return true

class FoxInGameMenuHandler:
	var inGameMenu
	var sidebarButtons
	var modOptionsScreen
	
	func openModOptions():
		self.inGameMenu.visible = false
		self.modOptionsScreen.visible = true
		for sidebarButton in sidebarButtons:
			if sidebarButton != null:
				sidebarButton.disabled = true
	
	func closeModOptions():
		self.inGameMenu.visible = true
		self.modOptionsScreen.visible = false
		for sidebarButton in sidebarButtons:
			if sidebarButton != null:
				sidebarButton.disabled = false
	
	func isModOptionEnabled(enabledState):
		return enabledState == OPTION_ENABLE_ALWAYS or enabledState == OPTION_ENABLE_INGAME
	
	func allowSceneReload():
		return false

static func applyOnMainMenu():
	var mainMenu = FoxUIManager.getCurrentScene()
	var mainMenuHandler = FoxMainMenuHandler.new()
	var container = null
	if Globals.isBDCCAtLeast(0, 1, 11):
		container = mainMenu.get_node_or_null("MainHBox/CenterAreaVBox")
		# Fallback just in case, I like my code having plans to work long term
		if container == null:
			container = mainMenu.center_area_v_box
	else:
		container = mainMenu.get_node("HBoxContainer")
	var mainMenuBox = container.get_node("MainVBox")
	var buttonGrid = mainMenuBox.get_node("GridContainer")
	var optionsScreen = container.get_node("OptionsScreen")
	var modOptionsScreen = load(FoxLibModOptionsScreen).instance()
	FoxUIManager.deParent(modOptionsScreen)
	modOptionsScreen.visible = false
	modOptionsScreen.menuHandler = mainMenuHandler
	container.add_child_below_node(optionsScreen, modOptionsScreen)
	mainMenuHandler.mainMenuBox = mainMenuBox
	mainMenuHandler.optionsScreen = optionsScreen
	mainMenuHandler.modOptionsScreen = modOptionsScreen
	var modsOptionsButton = FoxButton.new()
	modsOptionsButton.connect_on_pressed(mainMenuHandler, "openModOptions")
	modsOptionsButton.margin_left = 304.0
	modsOptionsButton.margin_top = 60.0
	modsOptionsButton.margin_right = 452.0
	modsOptionsButton.margin_bottom = 86.0
	modsOptionsButton.size_flags_horizontal = 3
	modsOptionsButton.hint_tooltip = ModOptionsToolTip
	modsOptionsButton.text = "Mods Options"
	if Globals.isBDCCAtLeast(0, 1, 8):
		var prePreChild = buttonGrid.get_child(11)
		buttonGrid.add_child_below_node(prePreChild, modsOptionsButton)
	else:
		buttonGrid.add_child(modsOptionsButton)

static func applyOnInGameMenu():
	var mainScene = FoxUIManager.getCurrentScene()
	var gameUI = null
	var container = null
	var inGameMenu = null
	var buttonVBox = null
	var sidebarButtons = null
	if Globals.isBDCCAtLeast(0, 1, 11):
		gameUI = mainScene.gameUI
		inGameMenu = gameUI.ingameMenuScreen
		container = inGameMenu.get_parent()
		buttonVBox = inGameMenu.get_node("MainMenu/MainMenuCenter/VBoxContainer")
		sidebarButtons = []
		appendToArrayIfNotNull(sidebarButtons, gameUI.save_button)
		appendToArrayIfNotNull(sidebarButtons, gameUI.load_button)
		appendToArrayIfNotNull(sidebarButtons, gameUI.skillsButton)
		appendToArrayIfNotNull(sidebarButtons, gameUI.debugPanelButton)
		appendToArrayIfNotNull(sidebarButtons, gameUI.rollbackButton)
		for extraButton in gameUI.save_button.get_parent().get_children():
			if (extraButton is Button) and not sidebarButtons.has(extraButton):
				sidebarButtons.append(extraButton)
		if gameUI.debugPanelButton != null:
			for extraButton in gameUI.debugPanelButton.get_parent().get_children():
				if (extraButton is Button) and not sidebarButtons.has(extraButton):
					sidebarButtons.append(extraButton)
	else:
		gameUI = mainScene.get_node("GameUI")
		container = gameUI.get_node("HBoxContainer")
		inGameMenu = container.get_node("InGameMenu")
		buttonVBox = inGameMenu.get_node("MainMenu/MainMenuCenter/VBoxContainer")
		sidebarButtons = [
			container.get_node("Panel2/MarginContainer/VBoxContainer/HBoxContainer2/SaveButton"),
			container.get_node("Panel2/MarginContainer/VBoxContainer/HBoxContainer2/LoadButton"),
			container.get_node("Panel2/MarginContainer/VBoxContainer/HBoxContainer3/SkillsButton"),
			container.get_node("Panel2/MarginContainer/VBoxContainer/HBoxContainer3/MenuButton"),
			container.get_node("Panel2/MarginContainer/VBoxContainer/HBoxContainer3/DebugMenu"),
			container.get_node("Panel2/MarginContainer/VBoxContainer/HBoxContainer/RollbackButton"),
		]
	var ingameMenuHandler = FoxInGameMenuHandler.new()
	var modOptionsScreen = load(FoxLibModOptionsScreen).instance()
	FoxUIManager.deParent(modOptionsScreen)
	modOptionsScreen.visible = false
	modOptionsScreen.menuHandler = ingameMenuHandler
	container.add_child_below_node(inGameMenu, modOptionsScreen)
	ingameMenuHandler.inGameMenu = inGameMenu
	ingameMenuHandler.sidebarButtons = sidebarButtons
	ingameMenuHandler.modOptionsScreen = modOptionsScreen
	var modsOptionsButton = FoxButton.new() # 46
	modsOptionsButton.connect_on_pressed(ingameMenuHandler, "openModOptions")
	modsOptionsButton.margin_top = 230.0
	modsOptionsButton.margin_right = 107.0
	modsOptionsButton.margin_bottom = 256.0
	modsOptionsButton.hint_tooltip = ModOptionsToolTip
	modsOptionsButton.text = "Mods Options"
	if FoxUIManager.isTouchFriendlyUI():
		modsOptionsButton.rect_min_size = Vector2(200, 50)
	buttonVBox.add_child(modsOptionsButton)

static func appendToArrayIfNotNull(array, value):
	if value != null:
		array.append(value)
