extends "res://FoxLib/CrotchBlocks/Item/FoxItemCrotchBlock.gd"

var itemSlot := CrotchSlotVar.new()

func _init():
	globalDatapackItemBlock = true
	itemSlot.setRawType(CrotchVarType.STRING)
	itemSlot.setRawValue("appleitem")

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	var statName = itemSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(statName)):
		throwError(_contex, "Item id must be a string, got "+str(statName)+" instead")
		return
	
	var item = GlobalRegistry.createItemNoID(statName)
	if item == null:
		throwError(_contex, "Item with the id "+str(statName)+" wasn't found")
		return false
	
	return item.getInventoryImage()

func getTemplate():
	return [
		{
			type = "label",
			text = "Get Item ID Texture",
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

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "item"):
		_visSlot.setPossibleValues(GlobalRegistry.getItemRefs().keys())
