extends "res://FoxLib/FoxCrotchBlock.gd"

var nameSlot := CrotchSlotVar.new()

func _init():
	nameSlot.setRawType(CrotchVarType.STRING)
	nameSlot.setRawValue("")

func getCategories():
	return ["FoxLib (NPC)"]

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	var charName = nameSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(charName)):
		throwError(_contex, "Character name must be a string, got "+str(charName)+" instead")
		return
	if charName == "":
		return ""
	return _contex.charMethod(charName, "getName", [])

func getTemplate():
	return [
		{
			type = "label",
			text = "Get Name Of",
		},
		{
			type = "slot",
			id = "name",
			slot = nameSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "name"):
		return nameSlot

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "name"):
		if(_editor != null && _editor.has_method("getAllInvolvedCharIDs")):
			_visSlot.setPossibleValues(_editor.getAllInvolvedCharIDs())
