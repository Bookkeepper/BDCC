extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")

func getCategories():
	return ["FoxLib"]

func execute(_contex:CodeContex):
	var playerInventory = _contex.charMethod("pc", "getInventory", [])
	var playerInventoryEquippedItemsCopy = playerInventory.equippedItems.values().duplicate()
	# Equiped items need to be stashed separatelly.
	for item in playerInventoryEquippedItemsCopy:
		# Do not remove inmate collar
		if item.restraintData is RestraintUnremovable:
			continue
		playerInventory.removeEquippedItem(item)
		playerInventory.addItem(item)
	return null

func getTemplate():
	return [
		{
			type = "label",
			text = "Force unequip all player items",
		},
	]
