extends "res://Game/Datapacks/UI/CrotchCode/CodeBlockBase.gd"

const FoxCrotchBlockManager = preload("res://Modules/FoxLib/Internal/FoxCrotchBlockManager.gd")

func getCategories():
	FoxCrotchBlockManager.checkCodeContainers()
	return ["Logic"]

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	return true

func getTemplate():
	return [
		{
			type = "label",
			text = "TRUE",
		},
	]
