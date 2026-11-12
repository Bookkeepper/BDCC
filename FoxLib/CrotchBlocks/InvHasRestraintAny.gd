extends "res://FoxLib/FoxCrotchBlock.gd"

var nameSlot := CrotchSlotVar.new()
var itemSlot := FoxCrotchFlagsSlot.new()

func _init():
	nameSlot.setRawType(CrotchVarType.STRING)
	nameSlot.setRawValue("")
	itemSlot.setRawType(CrotchVarType.STRING)
	itemSlot.setRawValue(InventorySlot.Body)
	itemSlot.forceAtLeastOneFlag = true

func getCategories():
	return ["FoxLib (NPC)"]

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	var charName = nameSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return false
	if(!isString(charName)):
		throwError(_contex, "Character name must a string, got "+str(charName)+" instead")
		return false
	
	var statName = itemSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return false
	if(!isString(statName)):
		throwError(_contex, "Inventory slot must a string, got "+str(statName)+" instead")
		return false
	
	var character = GM.main.getCharacter(charName)
	if character == null:
		throwError(_contex, "Did not found character "+str(charName))
		return false
	var inventory = character.inventory
	for slot in itemSlot.getFlags():
		var equipedItem = inventory.getEquippedItem(slot)
		if equipedItem != null && equipedItem.isRestraint():
			return true
	return false

func getTemplate():
	return [
		{
			type = "slot",
			id = "name",
			slot = nameSlot,
			slotType = CrotchBlocks.VALUE,
			expand=true,
		},
		{
			type = "label",
			text = "has restraint on",
		},
		{
			type = "slot",
			id = "item",
			slot = itemSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "item"):
		return itemSlot
	if(_id == "name"):
		return nameSlot

func updateEditor(_editor):
	if(_editor != null && _editor.has_method("getAllInvolvedCharIDs")):
		nameSlot.setRawValue(_editor.getAllInvolvedCharIDs()[0] if _editor.getAllInvolvedCharIDs().size() > 0 else "")

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "name"):
		if(_editor != null && _editor.has_method("getAllInvolvedCharIDs")):
			_visSlot.setPossibleValues(_editor.getAllInvolvedCharIDs())
	if(_id == "item"):
		_visSlot.setPossibleValues(InventorySlot.getAll())
