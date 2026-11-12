extends "res://Game/Datapacks/UI/CrotchCode/CodeBlockBase.gd"
#class_name FoxCrotchBlock
#public_api

# Preload debug for children blocks
const FLMHDebug = preload("res://FoxLib/ModHelper/FLMHDebug.gd")
const FoxCrotchFlagsSlot = preload("res://FoxLib/CrotchBlocks/Slots/FoxCrotchFlagsSlot.gd")
const FoxLibInternalVars = "FoxLibInternalVars"

# Note: It's recommended to use this class or a children of this class for forward compatibility reason
func _init():
	pass

# Please don't put custom blocks in vanilla categories if you don't make it clear in the name the block comes from your mod
func getCategories():
	return ["Modded"]

# Get codecontext specific FoxLib vars
func getFoxLibInternalVars(_contex: CodeContex):
	var internalVar = null
	if _contex.has_meta(FoxLibInternalVars):
		internalVar = _contex.get_meta(FoxLibInternalVars)
	if internalVar == null:
		internalVar = {}
		_contex.set_meta(FoxLibInternalVars, internalVar)
	return internalVar


# Execute your own code there
func execute(_contex:CodeContex):
	pass

# Vanilla types are: CALL, VALUE, LOGIC, RETURNCALL
func getType():
	return CrotchBlocks.CALL

# Vanilla types are: label, rawstring, rawint, rawselector, slot, new_line, slot_list, anim, button_checks, image
# See: https://github.com/Alexofp/BDCC/blob/main/Game/Datapacks/UI/CrotchCode/CrotchBlockVisual.gd
func getTemplate():
	return [
		{
			type = "label",
			text = "ERROR",
		},
	]

# Don't forget to fill up this method if you use "slot" or "slot_list" in your template
func getSlot(_theSlot):
	pass

# Vanilla types are: ALL, SCENE, EVENT, QUEST
func getSupportedEditors():
	return CrotchBlockEditorType.ALL

# Vanilla themes are: themeVars, themeOutput, themeMath, themeLogic, themeControl, themeFlags, themeGame,
#  themeEvent, themeQuest, themeRNG, themeLewd, themeInventory, themeNPC, themeString, themeFlagGlobal
const themeModded = preload("res://FoxLib/CrotchBlocks/Themes/BlockModded.tres")
const themeModdedItem = preload("res://FoxLib/CrotchBlocks/Themes/BlockModdedItem.tres")
const themeDeprecated = preload("res://FoxLib/CrotchBlocks/Themes/BlockDeprecated.tres")

func getVisualBlockTheme():
	return themeModded

