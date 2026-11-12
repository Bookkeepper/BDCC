extends "res://FoxLib/CrotchBlocks/Item/FoxItemCrotchBlock.gd"

var nameSlot := CrotchSlotVar.new()

func _init():
	initializationBlock = true
	nameSlot.setRawType(CrotchVarType.STRING)
	nameSlot.setRawValue("")

func execute(_contex:CodeContex):
	var initItem = getInitItemFromContext(_contex)
	if(initItem == null):
		throwError(_contex, "Must be executed from an item init block!")
		return
	var theValue = str(nameSlot.getValue(_contex))
	if(_contex.hadAnError()):
		return
	initItem.visibleName = DatapackItemRegistry.makeDynStr(theValue, false)

func getTemplate():
	return [
		{
			type = "label",
			text = "Set Item Visible Name",
		},
		{
			type = "slot",
			id = "nameSlot",
			slot = nameSlot,
			slotType = CrotchBlocks.VALUE,
			expand = true,
		},
	]

func getSlot(_id):
	if(_id == "nameSlot"):
		return nameSlot

func shouldExpandTemplate():
	return true
