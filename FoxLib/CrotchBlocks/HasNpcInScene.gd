extends "res://FoxLib/FoxCrotchBlock.gd"

func getCategories():
	return ["FoxLib (NPC)"]

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	if GM.main == null:
		return false
	var currentScene = GM.main.getCurrentScene()
	if currentScene == null:
		return false
	for id in currentScene.currentCharactersVariants:
		if (id != "pc" and GlobalRegistry.getCharacter(id) != null):
			return true
	return false

func getTemplate():
	return [
		{
			type = "label",
			text = "Has NPC In Scene",
		},
	]
