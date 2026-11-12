extends SceneBase
#class_name FoxScene
#public_api

# For Debug support
const FLMHDebug = preload("res://FoxLib/ModHelper/FLMHDebug.gd")

# APIs
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const Globals = preload("res://FoxLib/Globals.gd")

var initialSceneCharacters = []
var allowSoftlock = false

func _initScene(_args = []):
	for initialSceneCharacter in initialSceneCharacters:
		addCharacter(initialSceneCharacter)

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	setState(_action)

func run():
	.run()
	if not sceneEndedFlag and not allowSoftlock:
		FoxUIManager.addEndTheSceneButtonIfSoftlock()

func addEndTheSceneButtonIfSoftlock(text: String = "End The Scene", tooltip: String = "Mistakes were made", method: String = "endthescene", args = []):
	FoxUIManager.addEndTheSceneButtonIfSoftlock(text, tooltip, method, args)

func hasSelectableButton():
	return FoxUIManager.hasSelectableButton()

func drawFileContent(file):
	saynn(Util.readFile(file))

