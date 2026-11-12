extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")

func getCategories():
	return ["FoxLib"]

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	return FoxUIManager.hasSelectableButton()

func getTemplate():
	return [
		{
			type = "label",
			text = "Has selectable button",
		},
	]
