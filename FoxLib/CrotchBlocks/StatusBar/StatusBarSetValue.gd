extends "res://FoxLib/CrotchBlocks/StatusBar/StatusBarCrotchBlock.gd"

var varSlot := CrotchSlotVar.new()

func _init():
	varSlot.setRawType(CrotchVarType.NUMBER)
	varSlot.setRawValue(0)

func execute(_contex:CodeContex):
	var statusBar = getFoxStatusBar(_contex)
	if statusBar == null:
		return
	var amValue = varSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isNumber(amValue)):
		throwError(_contex, "Second argument must be a number, got "+str(amValue)+" instead")
		return
	statusBar.setValue(amValue)

func getTemplate():
	return [
		{
			type = "label",
			text = "Set status bar",
		},
		{
			type = "slot",
			id = "statusBarId",
			slot = statusBarIdSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "label",
			text = "value to",
		},
		{
			type = "slot",
			id = "varSlot",
			slot = varSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "statusBarId"):
		return statusBarIdSlot
	if(_id == "varSlot"):
		return varSlot
