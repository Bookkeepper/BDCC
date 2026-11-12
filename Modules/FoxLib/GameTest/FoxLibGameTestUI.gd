extends Panel

const Globals = preload("res://FoxLib/Globals.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const FoxGameTestManager = preload("res://Modules/FoxLib/GameTest/FoxGameTestManager.gd")

const CHECKING_SUFFIX = " [wave amp=50 freq=2]...[/wave]"
const SUCCESS_SUFFIX = " [color=green]✓[/color]"
const FAILURE_SUFFIX = " [color=red]✗[/color]"
const SKIPPED_SUFFIX = " [color=yellow]?[/color]"
const SUCCESS = true
const FAILURE = false
const SKIPPED = null
const InitialGameTestText = "[[[ FoxLib GameTest ]]]\n"
const InitialTestName = "GameTest Injection"
const FinishGameTestText = "\n\n[[[ GameTest Completed! ]]]"

onready var game_test_textbox = $RichTextLabel
onready var main_menu_button = $HBoxContainer/MainMenuButton
var invalidSpecies = []
var testingFinished = false
var fullText = ""
var suffix = ""
var progress = ""
var extra = ""

func _ready():
	runGameTest()

func updateDisplayText():
	game_test_textbox.bbcode_text = self.fullText + self.suffix + self.extra + self.progress

func pushStatus(status, testName):
	if status == null:
		self.fullText = self.fullText + SKIPPED_SUFFIX + self.extra
		Log.print("[FoxLib] GameTest: Skipped " + testName)
	elif status:
		self.fullText = self.fullText + SUCCESS_SUFFIX + self.extra
		Log.print("[FoxLib] GameTest: Test " + testName + " ran successfully")
	else:
		self.fullText = self.fullText + FAILURE_SUFFIX + self.extra
		Log.error("[FoxLib] GameTest: Test " + testName + " failed")
	self.suffix = ""
	self.progress = ""
	self.extra = ""

func pushTest(testName):
	self.fullText = self.fullText + "\n" + testName
	self.suffix = CHECKING_SUFFIX
	Log.print("[FoxLib] GameTest: Running " + testName)

func _on_RichTextLabel_meta_clicked(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		Log.print("Opened link '%s' successfully!" % meta)
	else:
		Log.print("Failed opening the link '%s'!" % meta)

func _on_ConsoleButton_pressed():
	FoxUIManager.showGameConsole()

func _on_MainMenuButton_pressed():
	if self.testingFinished:
		FoxUIManager.getSceneTree().change_scene("res://UI/MainMenu/MainMenu.tscn")

# GameTest Display Impl
func addExtra(text):
	self.extra = self.extra + "\n" + text

func setProgress(text):
	self.progress = "\n" + text

func addSpeciesInvalid(species):
	if (species is String):
		if not species in invalidSpecies:
			invalidSpecies.append(species)
	elif species != null:
		for speciesElement in species:
			if (speciesElement is String) and not speciesElement in invalidSpecies:
				invalidSpecies.append(speciesElement)

func isSpeciesInvalid(species):
	return species in invalidSpecies or "any" in invalidSpecies

# GameTest logic, we cannot split this into isolated methods
# because of how godot handle the "yield" instruction.  :(
func runGameTest():
	main_menu_button.disabled = true
	Log.print("[FoxLib] GameTest running...")
	var tree = FoxUIManager.getSceneTree()
	self.fullText = InitialGameTestText
	self.suffix = CHECKING_SUFFIX
	self.updateDisplayText()
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	self.pushTest(InitialTestName)
	self.updateDisplayText()
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	self.pushStatus(SUCCESS, InitialTestName)
	self.updateDisplayText()
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	var hadNoFailures = true
	for gameTest in FoxGameTestManager.getGameTests():
		var testName = str(gameTest.name)
		self.pushTest(testName)
		self.updateDisplayText()
		yield(tree, "idle_frame")
		yield(tree, "idle_frame")
		var testCases = gameTest.getTestCases()
		var testVariants = gameTest.getTestVariants()
		if testCases == null or testCases.empty() or testVariants == null or testVariants.empty():
			self.pushStatus(SKIPPED, testName)
			self.updateDisplayText()
			continue
		var first = true
		var testStatus = true
		for testCase in testCases:
			for testVariant in testVariants:
				gameTest.updateDisplay(self, testCase, testVariant)
				self.updateDisplayText()
				yield(tree, "idle_frame")
				yield(tree, "idle_frame")
				if first:
					first = false
					gameTest.beforeTest()
				var caseStatus = gameTest.applyTest(self, testCase, testVariant)
				testStatus = testStatus and (caseStatus == true)
				# If variant failed, skip next variants.
				if caseStatus != true:
					break
		if not first:
			gameTest.afterTest()
		self.pushStatus(testStatus, testName)
		self.updateDisplayText()
		hadNoFailures = hadNoFailures and testStatus
		yield(tree, "idle_frame")
		yield(tree, "idle_frame")
	Log.print("[FoxLib] GameTest completed!")
	self.fullText = self.fullText + FinishGameTestText
	self.updateDisplayText()
	self.testingFinished = true
	main_menu_button.disabled = false
	# When quick testing, go back to the main menu if no errors happened.
	if hadNoFailures and FoxGameTestManager.isQuickTesting():
		FoxUIManager.getSceneTree().change_scene("res://UI/MainMenu/MainMenu.tscn")

