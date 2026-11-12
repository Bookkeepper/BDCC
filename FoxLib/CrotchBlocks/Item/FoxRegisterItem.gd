extends "res://FoxLib/CrotchBlocks/Item/FoxItemCrotchBlock.gd"

var itemIDSlot := CrotchSlotVar.new()
var initSlot := CrotchSlotCalls.new()

func _init():
	initializationBlock = true
	itemIDSlot.setRawType(CrotchVarType.STRING)
	itemIDSlot.setRawValue("")

func setItemIDSlotBlock(theBlock):
	itemIDSlot.setBlock(theBlock)

func addInitBlock(theBlock):
	initSlot.addBlock(theBlock)

func execute(_contex:CodeContex):
	if(getInitItemFromContext(_contex) != null):
		throwError(_contex, "Cannot init item from another item init block!")
		return
	
	var datapackItemID = itemIDSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return false
	if(_contex.shouldReturn()):
		return true
	if(!isString(datapackItemID)):
		throwError(_contex, "Datapack Item ID must be a string, got "+str(datapackItemID)+" instead")
		return
	if(DatapackItemRegistry.isInvalidNewItemId(datapackItemID)):
		throwError(_contex, "Datapack Item ID is invalid, got "+str(datapackItemID))
		return
	var newDatapackItem = DatapackItemRegistry.genNewDatapackItem(datapackItemID)
	if(newDatapackItem != null):
		setInitItemFromContext(_contex, newDatapackItem)
		if getInitItemFromContext(_contex) != newDatapackItem:
			throwError(_contex, "Internal critical failure")
			return false
		var ret = initSlot.execute(_contex)
		setInitItemFromContext(_contex, null)
		return ret
	
	return false

func shouldExpandTemplate():
	return true

func getTemplate():
	return [
		{
			type = "label",
			text = "Register item",
		},
		{
			type = "slot",
			id = "itemIDSlot",
			slot = itemIDSlot,
			slotType = CrotchBlocks.VALUE,
			expand = true,
		},
		{
			type = "slot_list",
			id = "initSlot",
			slot = initSlot,
		},
	]

func getSlot(_id):
	if(_id == "itemIDSlot"):
		return itemIDSlot
	if(_id == "initSlot"):
		return initSlot

