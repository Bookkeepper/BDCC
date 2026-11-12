extends "res://FoxLib/FoxGameTest.gd"

func _init():
	name = "Static Characters"

func getTestCases():
	return GlobalRegistry.getCharacterClasses().keys()

func updateDisplay(display, testCase, _variant):
	display.setProgress("Checking: " + testCase)

func applyTest(display, testCase, _variant):
	var staticCharacter = GM.main.getCharacter(testCase)
	if staticCharacter == null:
		display.addExtra("- Missing static NPC: " + testCase)
		return false
	if not (staticCharacter is BaseCharacter):
		display.addExtra("- NPC ID is not extending BaseCharacter: " + testCase)
		return false
	if staticCharacter.id != testCase:
		display.addExtra("- NPC ID Missmatch for: " + testCase + "(Got: " + str(staticCharacter.id) + ")")
		return false
	# Call ".processTime(1)" to update the character status.
	staticCharacter.processTime(1)
	# Check that the character has all it's bodyparts if it's a dynamic or fox character.
	if staticCharacter.isDynamicCharacter():
		var missingParts = ""
		for bodypartSlot in BodypartSlot.getAll():
			if BodypartSlot.isEssential(bodypartSlot):
				if not staticCharacter.hasBodypart(bodypartSlot):
					missingParts = missingParts + bodypartSlot + ", "
		if not missingParts.empty():
			display.addExtra("- NPC Test for " + testCase + " has missing : " + missingParts.trim_suffix(", "))
			return false
	# Display the character to detect for errors/crashes
	GM.main.playAnimation(StageScene.Duo, "stand", {npc=testCase, npcBodyState={naked=true}})
	return true

func afterTest():
	GM.main.playAnimation(StageScene.Solo, "stand")

