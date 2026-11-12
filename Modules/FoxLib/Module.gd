extends "res://FoxLib/FoxModule.gd"

# Theses are included by importing FoxModule.gd
# const FoxCrotchBlockManager = preload("res://Modules/FoxLib/Internal/FoxCrotchBlockManager.gd")
# const FoxGameRegistry = preload("res://FoxLib/FoxGameRegistry.gd")
# const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
# const FoxFonts = preload("res://FoxLib/FoxFonts.gd")
# const Globals = preload("res://FoxLib/Globals.gd")
const FoxOptionsManager = preload("res://Modules/FoxLib/Internal/FoxOptionsManager.gd")
const FoxGameTestManager = preload("res://Modules/FoxLib/GameTest/FoxGameTestManager.gd")
const FoxLibThemeManager = preload("res://Modules/FoxLib/Internal/FoxLibThemeManager.gd")
const FoxLibHotFixes = preload("res://Modules/FoxLib/Internal/FoxLibHotFixes.gd")
const FoxLibUIEventUtil = preload("res://Modules/FoxLib/Internal/FoxLibUIEventUtil.gd")
const FoxLibModInitHelper = preload("res://Modules/FoxLib/Internal/FoxLibModInitHelper.gd")
const FoxTranslateManager = preload("res://Modules/FoxLib/Internal/FoxTranslateManager.gd")
const FoxUIOptionsManager = preload("res://Modules/FoxLib/Internal/FoxUIOptionsManager.gd")
const FoxLibStatusBarsManager = preload("res://Modules/FoxLib/Internal/FoxLibStatusBarsManager.gd")
const EventTriggerDatapackUpdate = preload("res://Modules/FoxLib/Internal/EventTriggerDatapackUpdate.gd")
const FoxLibAudioManager = preload("res://Modules/FoxLib/Internal/Audio/FoxLibAudioManager.gd")
const FoxSayParser = preload("res://Modules/FoxLib/Hooks/FoxSayParser.gd")

var showConsoleOnBoot = true
var showAdvancedModOptions = false
var debugTranslationRequests = false
var preventTranslationRequests = false
var enableModHotFixes = true
var runInSafeMode = false
var fileClass = File.new()
var hotfixes = null
var safeMode = false
var testAudio = null
var audioVolume = 100

func _init():
	id = "FoxLib"
	name = "FoxLib v0.10.7"
	author = "Fox2Code"
	# Check safe mode early
	safeMode = FoxOptionsManager.getOrFillBooleanOption("FoxLib", "runInSafeMode", false)
	if safeMode:
		name = name + " (Safe Mode)"
	# Theses are used to hook various components of the game
	items = [ "res://Modules/FoxLib/DynContent/DatapackItemImpl.gd", ]
	perks = [ "res://Modules/FoxLib/Hooks/Events/FoxLibPerkHook.gd", ]
	worldEdits = [ "res://Modules/FoxLib/Hooks/Events/FoxLibWorldEditHook.gd", ]
	gameExtenders = [
		"res://Modules/FoxLib/Hooks/Events/FoxLibGameExtenderHook.gd",
		"res://Modules/FoxLib/Internal/Audio/FoxLibAudioManager.gd",
		"res://Modules/FoxLib/Internal/FoxLibNPCDataSaver.gd",
		"res://Modules/FoxLib/Internal/FoxLibStatusBarsManager.gd",
	]
	# Register FoxLib CrotchBlocks (Note: You must extends FoxModule.gd to do that)
	crotchBlocks = [
		# Global blocks
		"res://FoxLib/CrotchBlocks/AddEndTheSceneButtonIfSoftlock.gd",
		"res://FoxLib/CrotchBlocks/HasSelectableButton.gd",
		"res://FoxLib/CrotchBlocks/ForceStashAllPlayerItems.gd",
		"res://FoxLib/CrotchBlocks/ForceUnequipAllPlayerItems.gd",
		"res://FoxLib/CrotchBlocks/IsModuleLoaded.gd",
		"res://FoxLib/CrotchBlocks/SetShowFightUI.gd",
		"res://FoxLib/CrotchBlocks/ShowConsole.gd",
		"res://FoxLib/CrotchBlocks/RunDelayed.gd",
		# NPC blocks
		"res://FoxLib/CrotchBlocks/HasNpcInScene.gd",
		"res://FoxLib/CrotchBlocks/GetFirstNpcOfScene.gd",
		"res://FoxLib/CrotchBlocks/GetNameOf.gd",
		"res://FoxLib/CrotchBlocks/GetRandomDynamicNPC.gd",
		"res://FoxLib/CrotchBlocks/ForceUnequip.gd",
		"res://FoxLib/CrotchBlocks/CharAddPerk.gd",
		"res://FoxLib/CrotchBlocks/CharRemovePerk.gd",
		"res://FoxLib/CrotchBlocks/CharTogglePerk.gd",
		"res://FoxLib/CrotchBlocks/CharUnlockedPerk.gd",
		"res://FoxLib/CrotchBlocks/InvHasRestraintAny.gd",
		"res://FoxLib/CrotchBlocks/InvSetRestraintLevel.gd",
		# Audio Blocks
		"res://FoxLib/CrotchBlocks/Audio/IsAudioMuted.gd",
		"res://FoxLib/CrotchBlocks/Audio/AudioPlaySFX.gd",
		"res://FoxLib/CrotchBlocks/Audio/AudioPlayBGM.gd",
		"res://FoxLib/CrotchBlocks/Audio/AudioGetBGM.gd",
		# DNA Blocks
		"res://FoxLib/CrotchBlocks/DNA/DNAGetAmount.gd",
		"res://FoxLib/CrotchBlocks/DNA/DNAGetAmountFrom.gd",
		"res://FoxLib/CrotchBlocks/DNA/DNAHasIn.gd",
		"res://FoxLib/CrotchBlocks/DNA/DNAHasInFrom.gd",
		"res://FoxLib/CrotchBlocks/DNA/DNAGetPrimarySource.gd",
		"res://FoxLib/CrotchBlocks/DNA/DNAGetSourceCount.gd",
		# Story checks
		"res://FoxLib/CrotchBlocks/Story/PlayerHasChastityEvents.gd",
		# Status Bar
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarExists.gd",
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarReset.gd",
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarShow.gd",
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarHide.gd",
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarIsVisible.gd",
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarGetValue.gd",
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarSetValue.gd",
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarGetMaxValue.gd",
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarSetMaxValue.gd",
		"res://FoxLib/CrotchBlocks/StatusBar/StatusBarSetOverrideText.gd",
		# General Item block
		"res://FoxLib/CrotchBlocks/Item/FoxHasDatapackItemID.gd",
		"res://FoxLib/CrotchBlocks/Item/FoxAddDatapackItemID.gd",
		"res://FoxLib/CrotchBlocks/Item/FoxRemoveDatapackItemID.gd",
		"res://FoxLib/CrotchBlocks/Item/FoxGetItemTexture.gd",
		# Init Item block
		"res://FoxLib/CrotchBlocks/Item/FoxRegisterItem.gd",
		"res://FoxLib/CrotchBlocks/Item/FoxItemSetVisibleName.gd",
		"res://FoxLib/CrotchBlocks/Item/FoxItemSetDescription.gd",
		"res://FoxLib/CrotchBlocks/Item/FoxItemSetItemTexture.gd",
	]
	# Register game tests
	gameTests = [
		"res://FoxLib/GameTest/ItemsGameTest.gd",
		"res://FoxLib/GameTest/BodypartGameTest.gd",
		"res://FoxLib/GameTest/StaticCharacterTest.gd",
		"res://FoxLib/GameTest/GenerateInmateTest.gd",
		"res://FoxLib/GameTest/GenerateGuardTest.gd",
		"res://FoxLib/GameTest/GenerateEngineerTest.gd",
		"res://FoxLib/GameTest/GenerateNurseTest.gd",
	]
	# Show our custom trigger in the editor
	registerDatapackTrigger("FoxLibDatapackUpdate")
	# Init FoxUIManager SceneTree
	FoxUIManager.getSceneTree()
	# Add unicode runic font as fallback font
	FoxFonts.addFallbackFont("res://Modules/FoxLib/Resources/NotoSansRunic-Regular.ttf", false, "runic")
	# Inject post launch hook
	GlobalRegistry.connect("loadingFinished", self, "onLoadingFinishedImpl")
	# That is very stupid, but it works
	FoxLibUIEventUtil.registerInternal(self, "onSceneChangedInternal")
	# Register FoxLib options
	if not safeMode:
		FoxLibThemeManager.initListOptionWithThemes(self)
		addSliderOption("audioVolume", "Audio Volume", "Set the audio volume, can use test audio to test the volume", 100).connect("option_changed", self, "onAudioVolumeChanged")
		addButtonOption("testAudioBtn", "Test Audio", "Test audio to test current volume").connect("option_changed", self, "onTestAudioClicked")
	addBooleanOption("showConsoleOnBoot", "Show console on boot",
		"Display the console when the game starts to better diagnose mod loading issues", true).alwaysInitialize()
	addBooleanOption("showAdvancedModOptions", "Show advanced mod options",
		"Display advanced mods options, ussually to test unfinished features or targeted at mod developers", false)
	addBooleanOption("enableModHotFixes", "Enable Mod Hotfixes",
		"Fix some mods to make sure they work properly, even if they have not been updated to support the BDCC version you are using.\n(Requires a restart to apply)", true).advanced().alwaysInitialize()
	addBooleanOption("debugTranslationRequests", "Debug Translation requests",
		"Print translation requests into the console", false).advanced()
	addBooleanOption("preventTranslationRequests", "Prevent Translation requests",
		"Prevent AutoTranslator from translating text and force original text to be returned", false).advanced()
	var runInSafeModeOption = addBooleanOption("runInSafeMode", "Run in safe mode",
		"Run FoxLib in safe mode to prevent crashes, will disable themes and some APIs!\n(Requires a restart to apply)", false)
	if not safeMode:
		runInSafeModeOption.advanced()
	# Hook up the theme engine if not in safe-mode
	if not safeMode:
		FoxUIManager.getSceneTree().connect("node_added", self, "onNodeAddedImpl")
	# Register generic status bars for datapacks
	registerFoxStatusBar("corruption", "Corruption", "#7700cc")
	registerFoxStatusBar("infestation", "Infestation", "#7700cc")
	# Register test audio and update audio manager volume
	self.onAudioVolumeChanged()
	testAudio = newAudio("TestAudio", "res://Modules/FoxLib/Resources/AudioTest.ogg").setAuthor("deraj").setPitchVariance(0.1)
	# Swap loaded mod name, or show error if FoxLib is loaded twice
	swapLoadedModNameOrShowError("FoxLib")
	# Show error screen when we are run on an incompatible game version.
	if not isBDCCAtLeast(0, 1, 7):
		FoxUIManager.fatalError(
			self.getName() + " requires BDCC 0.1.7+\n\n" +
			"Please get an updated BDCC version at:\n" +
			"[url]https://github.com/Alexofp/BDCC/releases[/url]")
	elif not isBDCCAtLeast(0, 1, 11):
		Log.print("[FoxLib] You are not running latest BDCC version FoxLib targets")
	# Check for conflicting mods, such as mods we yoinked features from
	if hasModFile("ModularDialoguePatch.json"):
		# This mod actually is executing too late, breaking FoxLib functionality.
		FoxUIManager.fatalError(
			"BDCC 0.1.7+ already implements \"Modular Dialogue Patch\"!\n" +
			"Please uninstall \"Modular Dialogue Patch\" and restart the game!\n" +
			"Mods relying on \"Modular Dialogue Patch\" should work as expected on BDCC 0.1.7+")
	var loadedMods = GlobalRegistry.getLoadedMods()
	var hasAcesWorldBuildingMod = false
	var hasIncompatibleForceFuck = false
	for mod in loadedMods:
		if mod.begins_with("AcesWorldBuildingModVer0."):
			hasAcesWorldBuildingMod = true
		if mod == "ForceFuck.zip" and isBDCCAtLeast(0, 1, 8):
			hasIncompatibleForceFuck = true
	if hasAcesWorldBuildingMod:
		FoxUIManager.fatalError(
			"\"AcesWorldBuildingMod\" already has been upstreamed to BDCC 0.1.5+\n" +
			"Please uninstall \"AcesWorldBuildingMod\" and restart the game!")
	if hasIncompatibleForceFuck:
		FoxUIManager.fatalError(
			"\"ForceFuck\" is incompatible with BDCC 0.1.8+\n" +
			"Please uninstall \"ForceFuck\" and restart the game!")
	# Only setup hotfixes if enabled.
	if self.enableModHotFixes:
		self.hotfixes = FoxLibHotFixes.new()
		self.hotfixes.computeHotfixes(self)

func postInit():
	# Check if BDCC.pck is corrupted
	if isBDCCCorrupted():
		# I'm assuming this error only happen on Android where the "Build BDCC.pck" button fixes the issue
		FoxUIManager.fatalError(
			"BDCC is severly corrupted, this issue is not caused by any of your mods.\n" +
			"Please click on \"Build BDCC.pck\" in the mod launcher to fix this issue.\n" +
			"Then wait about 10 seconds before closing the mod launcher or starting the game.", true)
	# Apply hotfixes
	if self.hotfixes != null:
		self.hotfixes.applyHotfixes()

func isBDCCCorrupted():
	if not hasAllModFile(["Scenes/WorldScene.gd", "Scenes/Intro/IntroScene.gd"]):
		return true
	if GlobalRegistry.scenes["IntroScene"] != null:
		return false
	# Check cache on BDCC 0.1.8+ to avoid misslabeling IntroScene as missing
	if isBDCCAtLeast(0, 1, 8) and GlobalRegistry.hasCachedID(GlobalRegistry.CACHE_SCENE, "IntroScene"):
		return false
	return true

func registerEventTriggers():
	GM.ES.registerEventTrigger("FoxLibDatapackUpdate", EventTriggerDatapackUpdate.new())

func getFlags():
	return {
		"bgmIdDatapackRestoreFlag": flag(FlagType.Text),
	}

func resetFlagsOnNewDay():
	FoxLibAudioManager.playBGM(null)
	GM.main.setModuleFlag("FoxLib", "bgmIdDatapackRestoreFlag", "")
	FoxGameRegistry.internalCallPlayerModulesHandlers("onNewDay", GM.pc)

func onLoadingFinishedImpl():
	if FoxUIManager.internalEarlyFatalError():
		return
	if self.hotfixes != null:
		self.hotfixes.applyLateHotfixes()
	FoxLibModInitHelper.callOnFoxLibModInitReal()
	if FoxUIManager.internalEarlyFatalError():
		return
	FoxGameRegistry.internalCallModulesHandlers("onLoadingFinishing")
	FoxGameRegistry.internalPostInitialize()
	FoxCrotchBlockManager.postInitialize()
	FoxGameRegistry.internalCallModulesHandlers("onLoadingFinished")
	Log.print("[FoxLib] The game is ready")
	FoxUIManager.onFinishedLoading()
	if FoxUIManager.hasFatalError():
		return
	var foxLibGameTest = 0
	var foxLibGameTestEnv = OS.get_environment("FoxLibGameTest")
	if foxLibGameTestEnv != null and foxLibGameTestEnv.length() != 0 and foxLibGameTestEnv.is_valid_integer():
		foxLibGameTest = foxLibGameTestEnv.to_int()
	if foxLibGameTest > 0:
		FoxGameTestManager.runGameTest(foxLibGameTest == 1)

func onSceneChangedInternal():
	if FoxUIManager.hasFatalError():
		return
	FoxTranslateManager.checkAutoTranslateHook()
	var currentScene = FoxUIManager.getCurrentScene()
	# Log.print("TEST: " + str(currentScene))
	if str(currentScene).begins_with("MainMenu:["):
		FoxUIOptionsManager.applyOnMainMenu()
		FoxGameTestManager.applyOnMainMenu()
		FoxLibStatusBarsManager.resetStatusBarData()
	elif str(currentScene).begins_with("MainScene:["):
		FoxGameTestManager.applyInGameTest()
		if not safeMode:
			FoxUIOptionsManager.applyOnInGameMenu()
			FoxLibStatusBarsManager.injectInGameStatusBars()
		self.call_deferred("onMainSceneLoadedDeffered")
	if not safeMode:
		FoxLibAudioManager.installOnScene()
	FoxGameRegistry.internalCallModulesHandlers("onSceneChanged", currentScene)
	if not safeMode:
		FoxLibThemeManager.applyThemeLoad(currentScene)
	if GM.ui != null:
		Log.print("[FoxLib] Applying SayParser hook: " + str(GM.ui.sayParser))
		if not (GM.ui.sayParser is FoxSayParser):
			GM.ui.sayParser = FoxSayParser.new()

func onMainSceneLoadedDeffered():
	if GM.main == null:
		return
	FoxLibStatusBarsManager.updateStatusBars()

func onAudioVolumeChanged(_ignored=null):
	FoxLibAudioManager.setVolume(audioVolume)

func onTestAudioClicked(_ignored=null):
	if testAudio != null:
		testAudio.playAsSFX()

func onNodeAddedImpl(node):
	FoxLibThemeManager.applyTheme(node)

func hasModFile(path):
	return fileClass.file_exists("res://" + path)

func hasAnyModFile(paths):
	for path in paths:
		if hasModFile(path):
			return true
	return false

func hasAllModFile(paths):
	for path in paths:
		if not hasModFile(path):
			return false
	return true
