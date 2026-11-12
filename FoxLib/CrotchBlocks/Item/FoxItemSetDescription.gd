extends "res://FoxLib/CrotchBlocks/Item/FoxItemCrotchBlock.gd"

var descSlot := CrotchSlotVar.new()

func _init():
	initializationBlock = true
	descSlot.setRawType(CrotchVarType.STRING)
	descSlot.setRawValue("")

func execute(_contex:CodeContex):
	var initItem = getInitItemFromContext(_contex)
	if(initItem == null):
		throwError(_contex, "Must be executed from an item init block!")
		return
	var theValue = str(descSlot.getValue(_contex))
	if(_contex.hadAnError()):
		return
	initItem.description = DatapackItemRegistry.makeDynStr(theValue, false)

func getTemplate():
	return [
		{
			type = "label",
			text = "Set Item Description",
		},
		{
			type = "new_line",
		},
		{
			type = "slot",
			id = "descSlot",
			slot = descSlot,
			slotType = CrotchBlocks.VALUE,
			extraType = 1,
			expand = true,
		},
	]

func getSlot(_id):
	if(_id == "descSlot"):
		return descSlot

func shouldExpandTemplate():
	return true
