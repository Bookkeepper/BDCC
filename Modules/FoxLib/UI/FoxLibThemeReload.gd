extends Control

func _on_RichTextLabel_meta_clicked(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		Log.print("Opened link '%s' successfully!" % meta)
	else:
		Log.print("Failed opening the link '%s'!" % meta)

