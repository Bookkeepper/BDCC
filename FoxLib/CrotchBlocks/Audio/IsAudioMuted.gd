extends "res://FoxLib/FoxCrotchBlock.gd"

const Globals = preload("res://FoxLib/Globals.gd")

func getCategories():
	return ["FoxLib"]

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	return Globals.ofModule("FoxLib").audioVolume == 0

func getTemplate():
	return [
		{
			type = "label",
			text = "Is audio Muted",
		},
	]
