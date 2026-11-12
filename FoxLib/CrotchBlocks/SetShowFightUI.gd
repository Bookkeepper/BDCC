extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")

var varValueSlot := CrotchSlotVar.new()

func _init():
	varValueSlot.setRawType(CrotchVarType.BOOL)
	varValueSlot.setRawValue(true)

func getCategories():
	return ["FoxLib"]

func execute(_contex:CodeContex):
	if _contex is DatapackSceneCodeContext:
		var scene = _contex.scene
		var value = varValueSlot.getValue(_contex)
		scene.showFightUI = true if value else false
	else:
		_contex.throwError(self, "Set show fight UI called outside a scene")

func getTemplate():
	return [
		{
			type = "label",
			text = "Set show fight UI",
		},
		{
			type = "slot",
			id = "value",
			slot = varValueSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(theSlot):
	if theSlot == "value":
		return varValueSlot

func getSupportedEditors():
	return CrotchBlockEditorType.SCENE

