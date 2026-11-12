extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")

func getCategories():
	return ["FoxLib"]

func execute(_contex:CodeContex):
	FoxUIManager.addEndTheSceneButtonIfSoftlock()

func getTemplate():
	return [
		{
			type = "label",
			text = "Add \"End The Scene\" button if softlock",
		},
	]
