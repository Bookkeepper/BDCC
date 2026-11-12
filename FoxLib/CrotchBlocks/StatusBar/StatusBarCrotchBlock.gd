extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxLibStatusBarsManager = preload("res://Modules/FoxLib/Internal/FoxLibStatusBarsManager.gd")

var statusBarIdSlot := CrotchSlotVar.new()

func getCategories():
	return ["FoxLib (Status Bars)"]

func _init():
	statusBarIdSlot.setRawType(CrotchVarType.STRING)
	var allStatusBarsIDs = FoxLibStatusBarsManager.getAllStatusBars().keys()
	statusBarIdSlot.setRawValue(allStatusBarsIDs[0] if allStatusBarsIDs.size() > 0 else "")

func getType():
	return CrotchBlocks.LOGIC

func getSlot(_id):
	if(_id == "statusBarId"):
		return statusBarIdSlot

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "statusBarId"):
		if(_editor != null):
			_visSlot.setPossibleValues(FoxLibStatusBarsManager.getAllStatusBars().keys())

func updateEditor(_editor):
	if(_editor != null):
		var allStatusBarsIDs = FoxLibStatusBarsManager.getAllStatusBars().keys()
		statusBarIdSlot.setRawValue(allStatusBarsIDs[0] if allStatusBarsIDs.size() > 0 else "")

func getFoxStatusBar(_contex:CodeContex):
	var statusBarId = statusBarIdSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return null
	if(!isString(statusBarId)):
		throwError(_contex, "Status bar ID must be a string, got "+str(statusBarId)+" instead")
		return null
	return FoxLibStatusBarsManager.getFromId(statusBarId)
