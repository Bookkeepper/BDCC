extends HBoxContainer

signal value_changed(categoryID, id, newvalue)

var id
var categoryID
var description
var placeholder

func setOptionName(newname):
	$Label.text = newname

func getOptionName():
	return $Label.text

func setOptionValue(_newvalue):
	pass

func setDescription(newdesc):
	description = newdesc

func getDescription():
	return description

func setPlaceholderValue(_placeholder):
	$Button.text = _placeholder

func _on_Button_pressed():
	emit_signal("value_changed", categoryID, id, null)
