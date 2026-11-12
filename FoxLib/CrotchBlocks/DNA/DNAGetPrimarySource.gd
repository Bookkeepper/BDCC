extends "res://FoxLib/CrotchBlocks/DNA/DNACrotchBlock.gd"

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
	var character = GM.main.getCharacter(charName)
	if character == null:
		throwError(_contex, "Did not found character "+str(charName))
		return
	var dnaAmounts = getDNAFluids(character, source)
	var currentDnaAmount = 0.0
	var currentDnaCharId = ""
	for key in dnaAmounts:
		var dnaAmount = dnaAmounts[key]
		if dnaAmount > currentDnaAmount:
			currentDnaAmount = dnaAmount
			currentDnaCharId = key
	return currentDnaCharId

func getTemplate():
	return [
		{
			type = "label",
			text = "Get DNA Primary Source",
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
	]
