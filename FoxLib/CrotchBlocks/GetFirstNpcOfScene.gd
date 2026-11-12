extends "res://FoxLib/FoxCrotchBlock.gd"

func getCategories():
	return ["FoxLib (NPC)"]

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	if GM.main == null:
		return ""
	var currentScene = GM.main.getCurrentScene()
	if currentScene == null:
		return ""
	for id in currentScene.currentCharactersVariants:
		if (id != "pc" and GlobalRegistry.getCharacter(id) != null):
			var realId = _contex.getCharacterActualID(id)
			if realId != null and realId != "":
				if realId == "pc":
					continue
				return realId
			return id
	return ""

func getTemplate():
	return [
		{
			type = "label",
			text = "Get First NPC Of Scene",
		},
	]
