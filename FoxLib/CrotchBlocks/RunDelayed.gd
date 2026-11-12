extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const DelayedCodeContext = preload("res://FoxLib//CrotchBlocks/Contexts/DelayedCodeContext.gd")

var codeSlot := CrotchSlotCalls.new()

func getCategories():
	return ["FoxLib"]

func getType():
	return CrotchBlocks.CALL

func execute(_contex:CodeContex):
	executeDelayed(_contex)
	return null

func executeDelayed(_contex:CodeContex):
	var newContex = _contex
	if not (newContex is DelayedCodeContext):
		newContex = DelayedCodeContext.new()
		newContex.initDelayedFrom(_contex)
	yield(FoxUIManager.getSceneTree(), "idle_frame")
	if newContex == _contex:
		newContex.resetDelayedState()
	codeSlot.execute(newContex)

func shouldExpandTemplate():
	return true

func getTemplate():
	return [
		{
			type = "label",
			text = "Run Delayed",
		},
		{
			type = "slot_list",
			id = "codeSlot",
			slot = codeSlot,
		},
	]

func getSlot(_id):
	if(_id == "codeSlot"):
		return codeSlot

