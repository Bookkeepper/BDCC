extends "res://FoxLib/CrotchBlocks/DNA/DNACrotchBlock.gd"

var nameTargetSlot := CrotchSlotVar.new()

func _init():
	nameTargetSlot.setRawType(CrotchVarType.STRING)
	nameTargetSlot.setRawValue("")

func execute(_contex:CodeContex):
	var charName = nameSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(charName)):
		throwError(_contex, "Character name must be a string, got "+str(charName)+" instead")
		return
	var source = dnaSourceSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(source)):
		throwError(_contex, "DNA Source name must be a string, got "+str(charName)+" instead")
		return
	var charTargetName = nameTargetSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(charTargetName)):
		throwError(_contex, "Character target name must be a string, got "+str(charName)+" instead")
		return
	var character = GM.main.getCharacter(charName)
	if character == null:
		throwError(_contex, "Did not found character "+str(charName))
		return
	var dnaAmounts = getDNAFluids(character, source)
	var dnaAmount = 0.0
	if dnaAmounts.has(charTargetName):
		dnaAmount = dnaAmounts[charTargetName]
	return dnaAmount

func getTemplate():
	return [
		{
			type = "label",
			text = "Get DNA amount of",
		},
		{
			type = "slot",
			id = "name",
			slot = nameSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "slot",
			id = "dnaSource",
			slot = dnaSourceSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "label",
			text = "from",
		},
		{
			type = "slot",
			id = "nameTarget",
			slot = nameTargetSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "nameTarget"):
		return nameTargetSlot
	return .getSlot(_id)


func updateVisualSlot(_editor, _id, _visSlot):
	.updateVisualSlot(_editor, _id, _visSlot)
	if(_id == "nameTarget"):
		if(_editor != null && _editor.has_method("getAllInvolvedCharIDs")):
			_visSlot.setPossibleValues(_editor.getAllInvolvedCharIDs())

func updateEditor(_editor):
	.updateEditor(_editor)
	if(_editor != null):
		if(_editor.has_method("getAllInvolvedCharIDs")):
			nameTargetSlot.setRawValue(_editor.getAllInvolvedCharIDs()[0] if _editor.getAllInvolvedCharIDs().size() > 0 else "")
