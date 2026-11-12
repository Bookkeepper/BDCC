extends "res://FoxLib/CrotchBlocks/StatusBar/StatusBarCrotchBlock.gd"

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	return getFoxStatusBar(_contex) != null

func getTemplate():
	return [
		{
			type = "label",
			text = "Does status bar",
		},
		{
			type = "slot",
			id = "statusBarId",
			slot = statusBarIdSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "label",
			text = "exists",
		},
	]

