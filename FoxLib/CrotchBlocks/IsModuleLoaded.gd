extends "res://FoxLib/FoxCrotchBlock.gd"

var moduleSlot := CrotchSlotVar.new()

func getCategories():
	return ["FoxLib"]

func _init():
	moduleSlot.setRawType(CrotchVarType.STRING)
	moduleSlot.setRawValue("")

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	var contentType = moduleSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return false
	if(!isString(contentType)):
		throwError(_contex, "Module type must be a string, got "+str(contentType)+" instead")
		return false
	
	return GlobalRegistry.getModules()[contentType] != null

func getTemplate():
	return [
		{
			type = "label",
			text = "Is module loaded",
		},
		{
			type = "slot",
			id = "module",
			slot = moduleSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "module"):
		return moduleSlot

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "module"):
		if(_editor != null):
			_visSlot.setPossibleValues(GlobalRegistry.getModules().keys())

func updateEditor(_editor):
	if(_editor != null):
		var allModulesIDs = GlobalRegistry.getModules().keys()
		moduleSlot.setRawValue(allModulesIDs[0] if allModulesIDs.size() > 0 else "")
