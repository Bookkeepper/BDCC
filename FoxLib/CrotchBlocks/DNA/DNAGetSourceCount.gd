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
	return getDNAFluids(character, source).size()

func getTemplate():
	return [
		{
			type = "label",
			text = "Get DNA Source Count",
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
