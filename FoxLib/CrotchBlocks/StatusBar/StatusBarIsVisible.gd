extends "res://FoxLib/CrotchBlocks/StatusBar/StatusBarCrotchBlock.gd"

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	var statusBar = getFoxStatusBar(_contex)
	if statusBar == null:
		return false
	return statusBar.getVisible()

func getTemplate():
	return [
		{
			type = "label",
			text = "Is status bar visible",
		},
		{
			type = "slot",
			id = "statusBarId",
			slot = statusBarIdSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

