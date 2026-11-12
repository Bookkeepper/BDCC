extends "res://FoxLib/FoxGameTest.gd"

func _init():
	name = "Registered Items"
	isRegistryTest = true

func getTestCases():
	return GlobalRegistry.getItemRefs().keys()

func updateDisplay(display, testCase, _variant):
	display.setProgress("Checking: " + testCase)

func applyTest(display, testCase, _variant):
	# Note: We always generate ID for items here.
	var item = GlobalRegistry.createItem(testCase)
	if item == null:
		display.addExtra("- Failed to create item: " + testCase)
		return false
	if not (item is ItemBase):
		display.addExtra("- Item ID is not extending ItemBase: " + testCase)
		return false
	if item.id != testCase:
		display.addExtra("- Item ID missmatch for: " + testCase)
		return false
	if item.getVisibleName() == null:
		display.addExtra("- Item visible name is null for: " + testCase)
		return null
	var success = true
	if item.getCasualName() == null:
		display.addExtra("- Item casual name is null for: " + testCase)
		success = false
	# Don't check getInventoryName if getStackName is null as it might crash the game.
	if item.getStackName() == null:
		display.addExtra("- Item stack name is null for: " + testCase)
		success = false
	elif item.getInventoryName() == null:
		display.addExtra("- Item inventory name is null for: " + testCase)
		success = false
	# Don't check getVisisbleDescription if getDescription is null as it might crash the game.
	if item.getDescription() == null:
		display.addExtra("- Item description is null for: " + testCase)
		success = false
	elif item.getVisisbleDescription() == null:
		display.addExtra("- Item visible description is null for: " + testCase)
		success = false
	# To avoid an edge case crash with some mods, set an inventory on the newly generated item.
	if item.currentInventory == null:
		item.currentInventory = GM.pc.inventory
	return success
