extends Control

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
onready var error_textbox = $RichTextLabel
onready var main_menu_button = $HBoxContainer/OpenMainMenuButton

func _ready():
	error_textbox.bbcode_text = FoxUIManager.internalGetErrorMessage()
	main_menu_button.visible = FoxUIManager.allowOpenMainMenu()

func _on_RichTextLabel_meta_clicked(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		Log.print("Opened link '%s' successfully!" % meta)
	else:
		Log.print("Failed opening the link '%s'!" % meta)

func _on_ConsoleButton_pressed():
	FoxUIManager.showGameConsole()

func _on_OpenMainMenuButton_pressed():
	FoxUIManager.getSceneTree().change_scene("res://UI/MainMenu/MainMenu.tscn")
