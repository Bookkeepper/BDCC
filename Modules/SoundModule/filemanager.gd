extends Node

const manager = preload("res://Modules/FoxLib/Internal/FoxLibAudioManager.gd")
const Globals = preload("res://FoxLib/Globals.gd")
const fui = preload("res://FoxLib/FoxUIManager.gd")


var fileDialog:FileDialog
var selected:String


func popup(_text, _args):
	var Dialog = AcceptDialog.new()
	Dialog._set_on_top(true)
	Dialog.dialog_text = _text
	var viewport = FoxUIManager.getCurrentScene().get_viewport()
	viewport.add_child(Dialog)
	Dialog.popup_centered_clamped(Vector2(300,200))
	yield(Dialog, "confirmed")
	
func getFile():
	fileDialog = FileDialog.new()
	fileDialog.mode = FileDialog.MODE_OPEN_FILE
	fileDialog.access = FileDialog.ACCESS_FILESYSTEM
	fileDialog.connect("file_selected", self, "on_file_selected")
	var viewport = FoxUIManager.getCurrentScene().get_viewport()
	viewport.add_child(fileDialog)
	fileDialog.set_meta("_created_by", self) # needed so the script is not directly freed after the run function. Would disconnect all signals otherwise
	fileDialog.popup(Rect2(0,0, 700, 500)) # Giving the dialog a predefined size

func on_file_selected(filename : String):
#	print(filename)
	selected = filename
	if (fileDialog != null):
		fileDialog.queue_free()
	return selected


