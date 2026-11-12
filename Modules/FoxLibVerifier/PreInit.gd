# This script block the game from starting if FoxLib is not present
const FoxLibAutoInstaller = "res://Modules/FoxLibAutoInstaller/PreInit.gd"
const EarlyInit = "res://Modules/FoxLib/EarlyInit.gd"
const ERROR_TEXT = "ERROR: FoxLib is missing."

# This is the earliest we can execute in BDCC codepaths
func _init():
	checkFoxLib()

func checkFoxLib():
	var file = File.new()
	if !(file.file_exists(EarlyInit) or file.file_exists(FoxLibAutoInstaller)):
		GlobalRegistry.connect("loadingUpdate", self, "_on_loadingUpdate")
		GlobalRegistry.emit_signal("loadingUpdate", 0, ERROR_TEXT)
		yield(GlobalRegistry.get_tree(), "idle_frame")
		yield(GlobalRegistry.get_tree(), "idle_frame")
		Log.error(ERROR_TEXT)
		file.close()
		OS.delay_msec(10000)
		GlobalRegistry.get_tree().quit()
		return
	file.close()

func _on_loadingUpdate(progress, text):
	if progress != 0 and text != ERROR_TEXT:
		GlobalRegistry.emit_signal("loadingUpdate", 0, ERROR_TEXT)

