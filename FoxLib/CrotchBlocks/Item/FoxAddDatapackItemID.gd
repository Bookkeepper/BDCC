extends "res://FoxLib/CrotchBlocks/Item/FoxItemCrotchBlock.gd"

var nameSlot := CrotchSlotVar.new()
var itemSlot := CrotchSlotVar.new()

func _init():
	globalDatapackItemBlock = true
	nameSlot.setRawType(CrotchVarType.STRING)
	nameSlot.setRawValue("")
	itemSlot.setRawType(CrotchVarType.STRING)
	itemSlot.setRawValue("null")

func getType():
	return CrotchBlocks.CALL

func execute(_contex:CodeContex):
	var charName = nameSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(charName)):
		throwError(_contex, "Character name must be a string, got "+str(charName)+" instead")
		return
	
	var statName = itemSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(statName)):
		throwError(_contex, "Item id must be a string, got "+str(statName)+" instead")
		return
	
	var character = GM.main.getCharacter(charName)
	if character == null:
		throwError(_contex, "Did not found character "+str(charName))
		return
	var inventory = character.inventory
	var newItem = GlobalRegistry.createItem("FoxLibDatapackItem")
	if newItem == null:
		return false
	newItem.setDatapackItemID(statName)
	inventory.addItem(newItem)
	return true

func getTemplate():
	return [
		{
			type = "label",
			text = "Add datapack item id",
		},
		{
			type = "slot",
			id = "item",
			slot = itemSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "label",
			text = "to",
		},
		{
			type = "slot",
			id = "name",
			slot = nameSlot,
			slotType = CrotchBlocks.VALUE,
			expand=true,
		},
	]

func getSlot(_id):
	if(_id == "name"):
		return nameSlot
	if(_id == "item"):
		return itemSlot

func updateEditor(_editor):
	if(_editor != null && _editor.has_method("getAllInvolvedCharIDs")):
		nameSlot.setRawValue(_editor.getAllInvolvedCharIDs()[0] if _editor.getAllInvolvedCharIDs().size() > 0 else "")

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "name"):
		if(_editor != null && _editor.has_method("getAllInvolvedCharIDs")):
			_visSlot.setPossibleValues(_editor.getAllInvolvedCharIDs())
	#if(_id == "item"):
	#	_visSlot.setPossibleValues(GlobalRegistry.getItemRefs().keys())
