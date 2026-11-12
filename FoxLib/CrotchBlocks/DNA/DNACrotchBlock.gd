extends "res://FoxLib/FoxCrotchBlock.gd"

# Work in progress.
const dna = ["vagina", "anus", "mouth", "pregancy", "fluids"]
const dnaFluidsKey = ["vagina", "anus", "mouth"]
var nameSlot := CrotchSlotVar.new()
var dnaSourceSlot := CrotchSlotVar.new()

func getCategories():
	return ["FoxLib (DNA)"]

func _init():
	nameSlot.setRawType(CrotchVarType.STRING)
	nameSlot.setRawValue("")
	dnaSourceSlot.setRawType(CrotchVarType.STRING)
	dnaSourceSlot.setRawValue("fluids")

func getType():
	return CrotchBlocks.VALUE

func getSlot(_id):
	if(_id == "name"):
		return nameSlot
	if(_id == "dnaSource"):
		return dnaSourceSlot

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "name"):
		if(_editor != null && _editor.has_method("getAllInvolvedCharIDs")):
			_visSlot.setPossibleValues(_editor.getAllInvolvedCharIDs())
	if(_id == "dnaSource"):
		if(_editor != null):
			_visSlot.setPossibleValues(dna)

func updateEditor(_editor):
	if(_editor != null):
		if(_editor.has_method("getAllInvolvedCharIDs")):
			nameSlot.setRawValue(_editor.getAllInvolvedCharIDs()[0] if _editor.getAllInvolvedCharIDs().size() > 0 else "")

func getDNAFluids(character, source):
	var dnaFluids = {}
	if source == "fluids":
		for fluidSource in dnaFluidsKey:
			appendDNAFluids(character, fluidSource, dnaFluids)
	elif source == "pregancy":
		appendDNAPregnancy(character, dnaFluids)
	else:
		appendDNAFluids(character, source, dnaFluids)
	return dnaFluids

func appendDNAFluids(character, source, dnaFluids):
	if source == "mouth":
		source = BodypartSlot.Head
	if (!character.hasBodypart(source)):
		return
	var bodypart = character.getBodypart(source)
	if (bodypart == null or bodypart.orifice == null):
		return
	var fluids = bodypart.orifice.fluids
	if (fluids == null):
		return
	for fluid in fluids.contents:
		var charID = fluid.fluidDNA.getCharacterID()
		if (charID != null and charID != ""):
			if not dnaFluids.has(charID):
				dnaFluids[charID] = 0.0
			dnaFluids[charID] = dnaFluids[charID] + fluid.amount

func appendDNAPregnancy(character, dnaFluids):
	var menstrualCycle = character.menstrualCycle
	if (menstrualCycle == null):
		return
	for egg in menstrualCycle.impregnatedEggCells:
		var charID = egg.fatherID
		if (charID != null and charID != ""):
			if not dnaFluids.has(charID):
				dnaFluids[charID] = 0.0
			dnaFluids[charID] = dnaFluids[charID] + 1.0
