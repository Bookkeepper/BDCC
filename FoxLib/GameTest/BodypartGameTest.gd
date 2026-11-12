extends "res://FoxLib/FoxGameTest.gd"

var savedPlayer = null

var needSensitiveZone = [BodypartSlot.Breasts, BodypartSlot.Penis, BodypartSlot.Vagina, BodypartSlot.Anus]

func _init():
	name = "Registered Bodyparts"
	isRegistryTest = true

func getTestCases():
	return GlobalRegistry.getBodypartRefs().keys()

func updateDisplay(display, testCase, _variant):
	display.setProgress("Checking: " + testCase)

func beforeTest():
	self.savedPlayer = GM.pc.saveData()
	GM.main.playAnimation(StageScene.Solo, "stand", {bodyState={naked=true}})

func applyTest(display, testCase, _variant):
	var bodypart = GlobalRegistry.createBodypart(testCase)
	if bodypart == null:
		display.addExtra("- Failed to create bodypart: " + testCase)
		return false
	if not (bodypart is Bodypart):
		display.addExtra("- Bodypart ID is not extending Bodypart: " + testCase)
		return false
	if bodypart.id != testCase:
		display.addExtra("- Bodypart ID missmatch for: " + testCase)
		return false
	var bodypartSlot = bodypart.getSlot()
	if not (bodypartSlot in BodypartSlot.getAll()):
		display.addExtra("- Invalid bodypart slot " + str(bodypartSlot) + " for " + testCase)
		return false
	var invalidBodypart = false
	if bodypartSlot in needSensitiveZone:
		if bodypart.getSensitiveZone() == null:
			display.addExtra("- Sexual bodypart " + testCase + " is missing a sensitive zone!")
			invalidBodypart = true
	var bodypardScene = bodypart.getDoll3DScene()
	if bodypardScene != null and bodypardScene != "":
		if ResourceLoader.exists(bodypardScene):
			var loadedBodypardScene = load(bodypardScene)
			if loadedBodypardScene == null:
				display.addExtra("- Invalid doll3d scene for " + testCase)
				invalidBodypart = true
		else:
			display.addExtra("- Missing doll3d scene for " + testCase)
			invalidBodypart = true
	if invalidBodypart:
		display.addSpeciesInvalid(bodypart.getCompatibleSpecies())
		return false
	GM.pc.giveBodypart(bodypart)
	bodypart.processTime(1)
	return true

func afterTest():
	if self.savedPlayer != null:
		GM.pc.loadData(self.savedPlayer)
	self.savedPlayer = null
	GM.main.playAnimation(StageScene.Solo, "stand")

