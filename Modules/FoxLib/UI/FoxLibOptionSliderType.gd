extends HBoxContainer

signal value_changed(categoryID, id, newvalue)

var id
var title
var categoryID
var description

func setOptionName(newname):
	self.title = newname
	updateLabelText()

func getOptionName():
	return self.title

func setOptionValue(_newvalue):
	updateLabelText()
	$Slider.value = _newvalue

func setDescription(newdesc):
	description = newdesc

func getDescription():
	return description

func _on_Slider_value_changed(value):
	updateLabelText()
	emit_signal("value_changed", categoryID, id, value)

func updateLabelText():
	if self.title != null:
		$Label.text = self.title + ": " + str($Slider.value) + "%"
