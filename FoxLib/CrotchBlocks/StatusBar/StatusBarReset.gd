extends "res://FoxLib/CrotchBlocks/StatusBar/StatusBarCrotchBlock.gd"

func execute(_contex:CodeContex):
	var statusBar = getFoxStatusBar(_contex)
	if statusBar == null:
		return
	statusBar.resetBar()

func getTemplate():
	return [
		{
			type = "label",
			text = "Reset status bar",
		},
		{
			type = "slot",
			id = "statusBarId",
			slot = statusBarIdSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

