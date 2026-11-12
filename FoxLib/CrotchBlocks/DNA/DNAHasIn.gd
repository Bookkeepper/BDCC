extends "res://FoxLib/CrotchBlocks/DNA/DNAGetAmount.gd"

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	return .execute(_contex) > 0.0

func getTemplate():
	return [
		{
			type = "slot",
			id = "name",
			slot = nameSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "label",
			text = "has DNA in",
		},
		{
			type = "slot",
			id = "dnaSource",
			slot = dnaSourceSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]
