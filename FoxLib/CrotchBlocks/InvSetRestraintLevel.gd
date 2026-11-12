extends "res://FoxLib/FoxCrotchBlock.gd"

var nameSlot := CrotchSlotVar.new()
var itemSlot := CrotchSlotVar.new()
var valSlot := CrotchSlotVar.new()

func _init():
	nameSlot.setRawType(CrotchVarType.STRING)
	nameSlot.setRawValue("")
	itemSlot.setRawType(CrotchVarType.STRING)
	itemSlot.setRawValue(InventorySlot.Body)
	valSlot.setRawType(CrotchVarType.NUMBER)
	valSlot.setRawValue(1)

func getCategories():
	return ["FoxLib (NPC)"]

func getType():
	return CrotchBlocks.CALL

func execute(_contex:CodeContex):
	var charName = nameSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(charName)):
		throwError(_contex, "Character name must a string, got "+str(charName)+" instead")
		return
	
	var statName = itemSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(statName)):
		throwError(_contex, "Inventory slot must a string, got "+str(statName)+" instead")
		return
	
	var restraintLevel = valSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isNumber(restraintLevel)):
		throwError(_contex, "Item amount must a number, got "+str(restraintLevel)+" instead")
		return
	
	var character = GM.main.getCharacter(charName)
	if character == null:
		throwError(_contex, "Did not found character "+str(charName))
		return
	var inventory = character.inventory
	if not inventory.hasSlotEquipped(statName):
		return
	var equipedItem = inventory.getEquippedItem(statName)
	if equipedItem != null and equipedItem.isRestraint():
		equipedItem.setRestraintLevel(restraintLevel)

func getTemplate():
	return [
		{
			type = "label",
			text = "Set ",
		},
		{
			type = "slot",
			id = "name",
			slot = nameSlot,
			slotType = CrotchBlocks.VALUE,
			expand=true,
		},
		{
			type = "slot",
			id = "item",
			slot = itemSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "label",
			text = "restrain level to",
		},
		{
			type = "slot",
			id = "valSlot",
			slot = valSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "valSlot"):
		return valSlot
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
