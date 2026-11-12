const Globals = preload("res://FoxLib/Globals.gd")
const FoxGameTest = preload("res://FoxLib/FoxGameTest.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const FoxLibGameTestUI = "res://Modules/FoxLib/GameTest/FoxLibGameTestUI.tres"

# Workaround Godot Bug, as regular Gogot Button sometimes doesn't trigger pressed signals
const FoxButton = preload("res://FoxLib/UI/FoxButton.gd")

const GameTestToolTip = "Test many BDCC features to check for crashes and bugs!\n(Provided by FoxLib)"

class FoxGameTestHolder:
	var wantTesting = false
	var wantQuickTesting = false
	var registeredTests = []
	var registryTestCount = 0
	
	func runGameTest():
		self.wantTesting = true
		FoxUIManager.getSceneTree().change_scene("res://Game/MainScene.tscn")

static func runGameTest(quick=false):
	var gameTestHolder = Globals.of(FoxGameTestHolder)
	if gameTestHolder.wantTesting:
		return
	gameTestHolder.wantTesting = true
	gameTestHolder.wantQuickTesting = quick
	FoxUIManager.getSceneTree().change_scene("res://Game/MainScene.tscn")

static func applyOnMainMenu():
	var gameTestHolder = Globals.of(FoxGameTestHolder)
	gameTestHolder.wantTesting = false
	gameTestHolder.wantQuickTesting = false
	var mainMenu = FoxUIManager.getCurrentScene()
	var container = null
	if Globals.isBDCCAtLeast(0, 1, 11):
		container = mainMenu.get_node_or_null("MainHBox/CenterAreaVBox")
		# Fallback just in case, I like my code having plans to work long term
		if container == null:
			container = mainMenu.center_area_v_box
	else:
		container = mainMenu.get_node("HBoxContainer")
	var buttonGrid = container.get_node("DevToolsScreen/GridContainer")
	var runGameTestButton = FoxButton.new()
	runGameTestButton.connect_on_pressed(gameTestHolder, "runGameTest")
	runGameTestButton.margin_left = 482.0
	runGameTestButton.margin_top = 30.0
	runGameTestButton.margin_right = 616.0
	runGameTestButton.margin_bottom = 56.0
	runGameTestButton.size_flags_horizontal = 3
	runGameTestButton.hint_tooltip = GameTestToolTip
	runGameTestButton.text = "Run Game Test"
	buttonGrid.add_child(runGameTestButton)

static func applyInGameTest():
	var gameTestHolder = Globals.of(FoxGameTestHolder)
	if not gameTestHolder.wantTesting:
		return
	var mainScene = FoxUIManager.getCurrentScene()
	var foxLibGameTestUI = load(FoxLibGameTestUI).instance()
	FoxUIManager.deParent(foxLibGameTestUI)
	mainScene.add_child(foxLibGameTestUI)

static func isTesting():
	return Globals.of(FoxGameTestHolder).wantTesting

static func isQuickTesting():
	return Globals.of(FoxGameTestHolder).wantQuickTesting

static func registerGameTest(path):
	if not path.begins_with("res://"):
		Log.error("[FoxLib] Failed to register: " + path)
		Log.error("[FoxLib] GameTests must be inside your mod and cannot be auto generated")
		FoxUIManager.setHideConsoleAfterLoading(false)
		return null
	if not path.ends_with(".gd"):
		Log.error("[FoxLib] Failed to register: " + path)
		Log.error("[FoxLib] GameTests must be have the .gd extension")
		FoxUIManager.setHideConsoleAfterLoading(false)
		return null
	var newTestScript = load(path)
	if newTestScript == null:
		Log.error("[FoxLib] Failed to register: " + path)
		Log.error("[FoxLib] Please make sure your GameTest file is formatted correctly")
		FoxUIManager.setHideConsoleAfterLoading(false)
		return null
	var newGameTest = newTestScript.new()
	if not (newGameTest is FoxGameTest):
		Log.error("[FoxLib] Failed to register: " + path)
		Log.error("[FoxLib] Please make sure your GameTest file is formatted correctly")
		FoxUIManager.setHideConsoleAfterLoading(false)
		return null
	var holder = Globals.of(FoxGameTestHolder)
	if newGameTest.isRegistryTest:
		holder.registeredTests.insert(holder.registryTestCount, newGameTest)
		holder.registryTestCount = holder.registryTestCount + 1
	else:
		holder.registeredTests.append(newGameTest)
	return newGameTest

static func getGameTests():
	return Globals.of(FoxGameTestHolder).registeredTests
