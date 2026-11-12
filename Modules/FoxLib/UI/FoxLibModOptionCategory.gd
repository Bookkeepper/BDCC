extends VBoxContainer

onready var labelExpand = $OptionsCategory/LabelExpand
onready var label = $OptionsCategory/Label
onready var container = $OptionContainer

func setCategoryName(newname):
	label.text = "   " + newname

func addModOptionNode(optionNode):
	container.add_child(optionNode)

func toggleRegion():
	container.visible = not container.visible
	if container.visible:
		labelExpand.text = "v"
	else:
		labelExpand.text = ">"

