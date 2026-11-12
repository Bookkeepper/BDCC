extends Object
#class_name FoxUIManager
#public_api

const Globals = preload("res://FoxLib/Globals.gd")
const FoxLibEventUtil = preload("res://Modules/FoxLib/Internal/FoxLibEventUtil.gd")
const FoxLibUIEventUtil = preload("res://Modules/FoxLib/Internal/FoxLibUIEventUtil.gd")
const SadFace = "[right][wave amp=40 freq=1]:([/wave][/right]"

class FoxUIManagerData:
	var hideConsoleAfterLoading = true
	var finishedLoading = false
	var hasFatalError = false
	var allowOpenMainMenu = true
	var errorMessage = "The following fatal errors happened durring mod loading:" + SadFace + "\n"
	var sceneTree = null

static func asColor(maybeColor):
	if maybeColor == null:
		return null
	if maybeColor is Color:
		return maybeColor
	return Color(maybeColor)

static func asGradient(maybeGradient, maybeGradient2=null):
	if maybeGradient == null:
		return null
	if maybeGradient is Gradient:
		return maybeGradient
	if not (maybeGradient is Dictionary):
		var gradientDataColor = asColor(maybeGradient)
		var gradientDataColor2 = asColor(maybeGradient2)
		if gradientDataColor2 == null:
			maybeGradient = {0.0: gradientDataColor, 1.0: gradientDataColor}
		else:
			maybeGradient = {0.0: gradientDataColor, 1.0: gradientDataColor2}
	var newGradient = Gradient.new()
	newGradient.offsets = maybeGradient.keys()
	newGradient.colors = maybeGradient.values()
	return newGradient

static func showGameConsole():
	Console.control.visible = true

static func hideGameConsole():
	Console.control.visible = false

static func setHideConsoleAfterLoading(hideConsoleAfterLoading):
	Globals.of(FoxUIManagerData).hideConsoleAfterLoading = hideConsoleAfterLoading

static func deParent(node):
	if node != null and is_instance_valid(node):
		var parent = node.get_parent()
		if parent != null:
			parent.remove_child(node)

static func getSceneTree():
	var data = Globals.of(FoxUIManagerData)
	if data.sceneTree != null:
		return data.sceneTree
	var sceneTree = null
	# Try to aquire scene tree from early initialization
	var signals = GlobalRegistry.get_signal_connection_list("loadingFinished")
	for cur_signal in signals:
		var target = cur_signal.target
		if target is Control:
			sceneTree = target.get_tree()
			if sceneTree != null:
				break
	# Assert we got something
	assert(sceneTree != null, "SceneTree is null")
	data.sceneTree = sceneTree
	# Install into FoxLibUIEventUtil to listen to scene changes
	FoxLibUIEventUtil.install(sceneTree)
	return sceneTree

static func getCurrentScene():
	# Godot is jank, FoxLib workaround that jank
	var currentScene = getSceneTree().get_current_scene()
	if currentScene != null:
		return currentScene
	return FoxLibUIEventUtil.getCurrentEventScene()

static func addEndTheSceneButtonIfSoftlock(text: String = "End The Scene", tooltip: String = "Mistakes were made", method: String = "endthescene", args = []):
	var gameUI = GM.ui
	if gameUI == null or gameUI.options == null:
		return
	for optionKey in gameUI.options.keys():
		if gameUI.options[optionKey][0]:
			return
	gameUI.addButton(text, tooltip, method, args)

static func hasSelectableButton():
	var gameUI = GM.ui
	if gameUI == null or gameUI.options == null:
		return false
	for optionKey in gameUI.options.keys():
		if gameUI.options[optionKey][0]:
			return true
	return false

static func isTouchFriendlyUI():
	if Globals.isBDCCAtLeast(0, 1, 11):
		return OPTIONS.isTouchFriendlyUI()
	else:
		return false

# Tooltip compat code
static func getGlobalTooltip():
	return GlobalTooltip

static func hideTooltip(theNodeRef):
	if Globals.isBDCCAtLeast(0, 1, 11):
		getGlobalTooltip().hideTooltip(theNodeRef)
	else:
		getGlobalTooltip().hideTooltip()

static func showTooltip(theControl, title: String, text: String, showBelow: bool = false, delayShow: bool = false, wideTooltip: bool = false):
	if Globals.isBDCCAtLeast(0, 1, 11):
		getGlobalTooltip().showTooltip(theControl, title, text, showBelow, delayShow, wideTooltip)
	else:
		getGlobalTooltip().showTooltip(title, text, showBelow, delayShow, wideTooltip)

# Reload artwork code
static func reloadArtworkImages():
	var gameUI = GM.ui
	if gameUI == null:
		return
	var panel = gameUI.getCharacterPanel()
	if panel == null:
		return
	if Globals.isBDCCAtLeast(0, 1, 12):
		panel.reloadArtworkImages()
	else:
		for charID in panel.characters:
			panel.artworkPanel.addCharacter(charID, panel.characters[charID])

# Error screen code
static func fatalError(error, allowOpenMainMenu=false):
	var data = Globals.of(FoxUIManagerData)
	var errorStr = str(error)
	Log.error("FATAL ERROR: " + errorStr)
	if data.finishedLoading:
		data.errorMessage = "The following fatal error just happened:" + SadFace + "\n\n" + errorStr
		showFatalErrorScreenInternal()
		return
	data.errorMessage = data.errorMessage + "\n" + errorStr
	data.hasFatalError = true
	if not allowOpenMainMenu:
		data.allowOpenMainMenu = false

static func hasFatalError():
	return Globals.of(FoxUIManagerData).hasFatalError

static func allowOpenMainMenu():
	return Globals.of(FoxUIManagerData).allowOpenMainMenu


class FoxLibFuncRunner:
	var semaphore
	var mutex
	var node
	var method
	var arg
	var ret
	
	func mutexExecute():
		mutex.lock()
		ret = node.call(method, arg)
		if ret == null:
			ret = false
		mutex.unlock()
		semaphore.post()


static func callFuncOnMainThread(node, method, arg=null):
	if node == null or not is_instance_valid(node):
		return
	if OS.get_thread_caller_id() == OS.get_main_thread_id():
		return node.call(method, arg)
	var runner = FoxLibFuncRunner.new()
	runner.semaphore = Semaphore.new()
	runner.mutex = Mutex.new()
	runner.node = node
	runner.method = method
	runner.arg = arg
	runner.call_deferred("mutexExecute")
	runner.semaphore.wait()
	runner.mutex.lock()
	var ret = runner.ret
	runner.mutex.unlock()
	return ret

static func callOrQueueConsumerOnMainThread(node, method, arg=null):
	if OS.get_thread_caller_id() == OS.get_main_thread_id():
		node.call(method, arg)
	else:
		node.call_deferred(method, arg)
	return null

# Please use fatalError instead, it will always end up in this method being called.
static func showFatalErrorScreenInternal():
	hideGameConsole()
	Log.print("[FoxLib] Showing fatal error screen")
	load("res://Modules/FoxLib/UI/FoxLibFatalError.gd")
	getSceneTree().change_scene("res://Modules/FoxLib/UI/FoxLibFatalError.tres")

static func internalEarlyFatalError():
	var data = Globals.of(FoxUIManagerData)
	if data.hasFatalError:
		showFatalErrorScreenInternal()
		return true
	return false

static func onFinishedLoading():
	var data = Globals.of(FoxUIManagerData)
	data.finishedLoading = true
	if data.hasFatalError:
		showFatalErrorScreenInternal()
	elif data.hideConsoleAfterLoading:
		hideGameConsole()

static func internalGetErrorMessage():
	return Globals.of(FoxUIManagerData).errorMessage
