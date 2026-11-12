extends "res://FoxLib/FoxCrotchBlock.gd"

const DatapackItemRegistry = preload("res://Modules/FoxLib/DynContent/DatapackItemRegistry.gd")
const FoxLibDatapackItemVar = "FoxLibDatapackItem" # Used for initialization
const FoxLibCurrentItemVar = "FoxLibCurrentItem" # Used for usage handlers

var initializationBlock = false
var globalDatapackItemBlock = false

func getCategories():
	return ["FoxLib (Items)"]

func getInitItemFromContext(_contex: CodeContex):
	return getFoxLibInternalVars(_contex).get(FoxLibDatapackItemVar)

func setInitItemFromContext(_contex: CodeContex, initItem):
	getFoxLibInternalVars(_contex)[FoxLibDatapackItemVar] = initItem

func getImplItemFromContext(_contex: CodeContex):
	return getFoxLibInternalVars(_contex).get(FoxLibCurrentItemVar)

func setImplItemFromContext(_contex: CodeContex, implItem):
	getFoxLibInternalVars(_contex)[FoxLibCurrentItemVar] = implItem

func getSupportedEditors():
	if globalDatapackItemBlock:
		return CrotchBlockEditorType.ALL
	return CrotchBlockEditorType.EVENT

func getVisualBlockTheme():
	if initializationBlock:
		return themeModdedItem
	return themeModded

