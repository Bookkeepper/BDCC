extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")

func getCategories():
	return ["FoxLib"]

func execute(_contex:CodeContex):
	FoxUIManager.showGameConsole()

func getTemplate():
	return [
		{
			type = "label",
			text = "Show game console",
		},
	]
