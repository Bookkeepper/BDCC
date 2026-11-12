extends "res://FoxLib/CrotchBlocks/Item/FoxItemCrotchBlock.gd"

var imageSlot := CrotchSlotVar.new()

func _init():
	initializationBlock = true
	imageSlot.setRawType(CrotchVarType.STRING)
	imageSlot.setRawValue("")

func execute(_contex:CodeContex):
	var initItem = getInitItemFromContext(_contex)
	if(initItem == null):
		throwError(_contex, "Must be executed from an item init block!")
		return
	var theValue = str(imageSlot.getValue(_contex))
	if(_contex.hadAnError()):
		return
	if (not theValue.begins_with("res://")) or (theValue.ends_with(".gd")) or (not ResourceLoader.exists(theValue)):
		throwError(_contex, "Invalid texture path: " + theValue)
		return
	initItem.itemTexture = theValue

func getTemplate():
	return [
		{
			type = "label",
			text = "Set Item Inventory Image",
		},
		{
			type = "slot",
			id = "image",
			slot = imageSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "image"):
		return imageSlot

#func updateEditor(_editor):
#	if(_editor != null && _editor.has_method("getAllImageIDs")):
#		imageSlot.setRawValue(_editor.getAllImageIDs()[0] if _editor.getAllImageIDs().size() > 0 else "")
#
#func updateVisualSlot(_editor, _id, _visSlot):
#	if(_id == "image"):
#		if(_editor != null && _editor.has_method("getAllImageIDs")):
#			_visSlot.setPossibleValues(_editor.getAllImageIDs())
