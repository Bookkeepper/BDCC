extends "res://FoxLib/CrotchBlocks/StatusBar/StatusBarCrotchBlock.gd"

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	var statusBar = getFoxStatusBar(_contex)
	if statusBar == null:
		return 0
	return statusBar.getValue()

func getTemplate():
	return [
		{
			type = "label",
			text = "Get status bar",
		},
		{
			type = "slot",
			id = "statusBarId",
			slot = statusBarIdSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "label",
			text = "value",
		},
	]

