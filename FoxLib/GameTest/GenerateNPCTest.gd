extends "res://FoxLib/FoxGameTest.gd"

var npcGenerator = null

func _init():
	name = "Inmate Species Generation"

func getTestCases():
	return GlobalRegistry.getAllPlayableSpecies().keys()

func getTestVariants():
	return ["base", "male", "female"]

func updateDisplay(display, testCase, variant):
	display.setProgress("Checking: " + testCase + " (" + variant + ")")

func beforeTest():
	npcGenerator = makeGenerator()

func applyTest(display, testCase, variant):
	if display.isSpeciesInvalid(testCase):
		display.addExtra("- Playable species id skipped from previous test: " + testCase)
		return false
	if variant == "base":
		var species = GlobalRegistry.getSpecies(testCase)
		if species == null:
			display.addExtra("- Playable species id doesn't exists: " + testCase)
			return false
	# Generate 3 inmate, the first 100% random, the second male, the last female.
	var extraSlotCheck = ""
	var generatorArgs = {
		NpcGen.Species: testCase,
	}
	var extraGenderTest = null
	if variant == "male":
		generatorArgs[NpcGen.Gender] = NpcGender.Male
		extraSlotCheck = BodypartSlot.Penis
		extraGenderTest = Gender.Male
	if variant == "female":
		generatorArgs[NpcGen.Gender] = NpcGender.Female
		extraSlotCheck = BodypartSlot.Vagina
		extraGenderTest = Gender.Female
	var _npcID = NpcFinder.generateNpcForPool(getCharacterPool(), npcGenerator, generatorArgs)
	var generatedCharacter = GM.main.getCharacter(_npcID)
	if _npcID == null or _npcID == "" or generatedCharacter == null:
		display.addExtra("- Failed to do NPC gen for: " + testCase)
		return false
	if generatedCharacter.id != _npcID:
		display.addExtra("- NPC ID Missmatch for: " + testCase)
		return false
	if extraGenderTest != null and generatedCharacter.getGender() != extraGenderTest:
		display.addExtra("- NPC Does not respect requested gender: " + testCase)
		return false
	# Call ".processTime(1)" to update the character status.
	generatedCharacter.processTime(1)
	# Check that the character has all it's bodyparts
	var missingParts = ""
	for bodypartSlot in BodypartSlot.getAll():
		if BodypartSlot.isEssential(bodypartSlot) or extraSlotCheck == bodypartSlot:
			if not generatedCharacter.hasBodypart(bodypartSlot):
				missingParts = missingParts + bodypartSlot + ", "
	if not missingParts.empty():
		display.addExtra("- NPC Test for " + testCase + " has missing : " + missingParts.trim_suffix(", "))
		return false
	# Display the character to detect for errors/crashes
	GM.main.playAnimation(StageScene.Duo, "stand", {npc=_npcID, npcBodyState={naked=true}})
	return true

func afterTest():
	GM.main.playAnimation(StageScene.Solo, "stand")
	npcGenerator = null

func makeGenerator():
	return null

func getCharacterPool():
	return null
