extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxLibAudioManager = preload("res://Modules/FoxLib/Internal/FoxLibAudioManager.gd")

var nameSlot := CrotchSlotVar.new()

func _init():
	nameSlot.setRawType(CrotchVarType.STRING)
	nameSlot.setRawValue("")

func getCategories():
	return ["FoxLib"]

func execute(_contex:CodeContex):
	var audioName = nameSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(audioName)):
		throwError(_contex, "Audio name must be a string, got " + str(audioName) + " instead")
		return
	FoxLibAudioManager.playNamedSFX(audioName)

func getTemplate():
	return [
		{
			type = "label",
			text = "Play Sound Effect",
		},
		{
			type = "slot",
			id = "name",
			slot = nameSlot,
			slotType = CrotchBlocks.VALUE,
			expand=true,
		},
	]

func getSlot(_id):
	if(_id == "name"):
		return nameSlot

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "name"):
		_visSlot.setPossibleValues(FoxLibAudioManager.getAllAudioIDs())

