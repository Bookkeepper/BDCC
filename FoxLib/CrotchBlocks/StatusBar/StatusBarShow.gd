extends "res://FoxLib/CrotchBlocks/StatusBar/StatusBarCrotchBlock.gd"

func execute(_contex:CodeContex):
	var statusBar = getFoxStatusBar(_contex)
	if statusBar == null:
		return
	statusBar.setVisible(true)

func getTemplate():
	return [
		{
			type = "label",
			text = "Show status bar",
		},
		{
			type = "slot",
			id = "statusBarId",
			slot = statusBarIdSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

