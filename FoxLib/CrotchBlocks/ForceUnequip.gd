extends "res://FoxLib/FoxCrotchBlock.gd"

var nameSlot := CrotchSlotVar.new()
var itemSlot := CrotchSlotVar.new()

func getCategories():
	return ["FoxLib (NPC)"]

func _init():
	nameSlot.setRawType(CrotchVarType.STRING)
	nameSlot.setRawValue("")
	itemSlot.setRawType(CrotchVarType.STRING)
	itemSlot.setRawValue(InventorySlot.Eyes)

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
		throwError(_contex, "Item slot must a string, got "+str(statName)+" instead")
		return	
	
	var inventory = _contex.charMethod(charName, "getInventory", [])
	
	if(inventory.hasSlotEquipped(statName)):
		var storedItem = inventory.removeItemFromSlot(statName)
		if(!storedItem.isRestraint() || storedItem.isImportant()):
			inventory.addItem(storedItem)

func getTemplate():
	return [
		{
			type = "label",
			text = "Force unequip",
		},
		{
			type = "slot",
			id = "item_slot",
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
	if(_id == "item_slot"):
		return itemSlot

func updateEditor(_editor):
	if(_editor != null && _editor.has_method("getAllInvolvedCharIDs")):
		nameSlot.setRawValue(_editor.getAllInvolvedCharIDs()[0] if _editor.getAllInvolvedCharIDs().size() > 0 else "")

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "name"):
		if(_editor != null && _editor.has_method("getAllInvolvedCharIDs")):
			_visSlot.setPossibleValues(_editor.getAllInvolvedCharIDs())
	if(_id == "item_slot"):
		_visSlot.setPossibleValues(InventorySlot.getAll())
