extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxLibAudioManager = preload("res://Modules/FoxLib/Internal/FoxLibAudioManager.gd")

func getCategories():
	return ["FoxLib"]

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	return FoxLibAudioManager.getBGMId()

func getTemplate():
	return [
		{
			type = "label",
			text = "Get Background Music",
		},
	]

