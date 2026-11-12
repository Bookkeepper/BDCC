extends GameExtender

const Globals = preload("res://FoxLib/Globals.gd")
const FoxStatusBar = preload("res://FoxLib/FoxStatusBar.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const LabeledProgressBarScene = preload("res://UI/LabeledProgressBar.tscn")

class StatusBarsRegistry:
	var statusBars = {}

var statusBarData = null

func _init():
	id = "FoxLibStatusBarsManager"

func register(_GES:GameExtenderSystem):
	_GES.register(self, ExtendGame.saveLoadData)

func saveData():
	var data = {}
	FoxUIManager.callOrQueueConsumerOnMainThread(self, "saveDataMT", data)
	return data

func saveDataMT(data):
	Log.print("[FoxLib] Saving status bar data...")
	var registry = Globals.of(StatusBarsRegistry)
	for statusBarID in registry.statusBars:
		var statusBarInsance = registry.statusBars[statusBarID]
		data[statusBarID] = statusBarInsance.saveData()

func loadData(_data):
	self.call_deferred("restoreDataDelayed")
	statusBarData = _data

func restoreDataDelayed():
	if GM.main == null:
		return
	var data = statusBarData
	statusBarData = null
	if statusBarData == null or statusBarData.size() == 0:
		return
	var registry = Globals.of(StatusBarsRegistry)
	Log.print("[FoxLib] Loading status bar data...")
	for statusBarID in data:
		var statusBarInsance = registry.statusBars.get(statusBarID)
		if statusBarInsance == null:
			continue
		if data.has(statusBarID):
			statusBarInsance.loadData(data[statusBarID])
		else:
			statusBarInsance.resetBar()
	Log.print("[FoxLib] Status bar Data loaded!")

static func getFromId(statusBarId):
	return Globals.of(StatusBarsRegistry).statusBars.get(statusBarId)

static func getOrMakeFromId(statusBarId):
	var registry = Globals.of(StatusBarsRegistry)
	var statusBar = registry.statusBars.get(statusBarId)
	if statusBar != null:
		return statusBar
	FoxUIManager.new()
	statusBar = FoxStatusBar.new()
	statusBar.id = statusBarId
	registry.statusBars[statusBarId] = statusBar
	return statusBar

static func getAllStatusBars():
	return Globals.of(StatusBarsRegistry).statusBars

static func resetStatusBarData():
	var registry = Globals.of(StatusBarsRegistry)
	for statusBar in registry.statusBars.values():
		statusBar.internalProgressNode = null
		statusBar.resetBar()

# https://github.com/Alexofp/BDCC/blob/main/UI/LabeledProgressBar.gd
static func injectInGameStatusBars():
	var registry = Globals.of(StatusBarsRegistry)
	Log.print("injectInGameStatusBars: " + str(registry.statusBars.size()) + " " + str(registry.statusBars))
	var gameUI = null
	var playerPanel = null
	if Globals.isBDCCAtLeast(0, 1, 11):
		gameUI = FoxUIManager.getCurrentScene().gameUI
		playerPanel = gameUI.playerPanel
	else:
		gameUI = FoxUIManager.getCurrentScene().get_node("GameUI")
		playerPanel = gameUI.get_node("HBoxContainer/Panel/MarginContainer/PlayerPanel")
	var staminaBar = playerPanel.get_node("StaminaBar")
	for statusBarId in registry.statusBars:
		var statusBar = registry.statusBars[statusBarId]
		statusBar.internalProgressNode = null
		statusBar.resetBar()
		var progressBarNode = LabeledProgressBarScene.instance()
		progressBarNode.visible = true
		progressBarNode.propertyName = statusBar.name
		var progressGradient = statusBar.colorGradient
		if progressGradient == null:
			progressGradient = Gradient.new()
			var fallbackGradient = {0.0: Color.black, 1.0: Color.black}
			progressGradient.offsets = fallbackGradient.keys()
			progressGradient.colors = fallbackGradient.values()
		progressBarNode.colorGradient = progressGradient
		statusBar.internalProgressNode = progressBarNode
		playerPanel.add_child_below_node(staminaBar, progressBarNode)
		statusBar.updateDisplay(true)

static func updateStatusBars():
	var statusBars = getAllStatusBars()
	for statusBarId in statusBars:
		var statusBar = statusBars.get(statusBarId)
		if statusBar != null:
			statusBar.updateDisplay()

