extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")

func getCategories():
	return ["FoxLib"]

func execute(_contex:CodeContex):
	var playerInventory = _contex.charMethod("pc", "getInventory", [])
	var stashInventory = _contex.charMethod("playerstash", "getInventory", [])
	var playerInventoryItemsCopy = playerInventory.items.duplicate()
	var playerInventoryEquippedItemsCopy = playerInventory.equippedItems.values().duplicate()
	# Move all inventory items to stash.
	for item in playerInventoryItemsCopy:
		playerInventory.removeItem(item)
		stashInventory.addItem(item)
	# Equiped items need to be stashed separatelly.
	for item in playerInventoryEquippedItemsCopy:
		# Do not remove inmate collar
		if item.restraintData is RestraintUnremovable:
			continue
		playerInventory.removeEquippedItem(item)
		stashInventory.addItem(item)
	return null

func getTemplate():
	return [
		{
			type = "label",
			text = "Force stash all player items",
		},
	]
