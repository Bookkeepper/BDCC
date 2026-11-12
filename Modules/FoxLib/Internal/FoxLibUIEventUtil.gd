# This specific file seems to trigger an engine bug, please do not modify.
const Globals = preload("res://FoxLib/Globals.gd")
const FoxLibEventUtil = preload("res://Modules/FoxLib/Internal/FoxLibEventUtil.gd")
#nodebug

class FoxUIEventHandler:
	var sceneTree
	var sceneNode
	signal on_scene_changed
	func _on_idle_frame():
		var currentScene = self.sceneTree.get_current_scene()
		if currentScene != self.sceneNode and currentScene != null:
			self.sceneNode = currentScene
			self.emit_signal("on_scene_changed")
		return

static func install(_sceneTree):
	var handler = Globals.of(FoxUIEventHandler)
	handler.sceneTree = _sceneTree
	_sceneTree.connect("idle_frame", handler, "_on_idle_frame")
	Log.print("Install complete")

static func registerInternal(instance, method_name):
	var handler = Globals.of(FoxUIEventHandler)
	handler.connect("on_scene_changed", instance, method_name)

static func getCurrentEventScene():
	return Globals.of(FoxUIEventHandler).sceneNode

