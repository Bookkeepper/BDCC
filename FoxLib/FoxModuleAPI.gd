#class_name FoxModuleAPI
#public_api

var moduleId
var moduleCache

# For Debug support
const FLMHDebug = preload("res://FoxLib/ModHelper/FLMHDebug.gd")

# APIs
const FoxGameRegistry = preload("res://FoxLib/FoxGameRegistry.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const FoxModule = preload("res://FoxLib/FoxModule.gd")
const FoxOption = preload("res://FoxLib/FoxOption.gd")
const FoxAudio = preload("res://FoxLib/FoxAudio.gd")
const Globals = preload("res://FoxLib/Globals.gd")

# InternalAPIs
const FoxOptionsManager = preload("res://Modules/FoxLib/Internal/FoxOptionsManager.gd")
const FoxGameTestManager = preload("res://Modules/FoxLib/GameTest/FoxGameTestManager.gd")
const FoxLibStatusBarsManager = preload("res://Modules/FoxLib/Internal/FoxLibStatusBarsManager.gd")
const FoxLibAudioManager = preload("res://Modules/FoxLib/Internal/Audio/FoxLibAudioManager.gd")

func getModule():
	if self.moduleCache == null:
		self.moduleCache = weakref(Globals.ofModule(self.moduleId))
	return self.moduleCache.get_ref()

func getName():
	var bdccModule = self.getModule()
	var name = self.moduleId
	if bdccModule != null and "name" in bdccModule and bdccModule.name != null:
		name = bdccModule.name
	return name

# Allow checking BDCC version more easilly.
func isBDCCAtLeast(major=0, minor=0, patch=0, bugfix=0):
	return Globals.isBDCCAtLeast(major, minor, patch, bugfix)

# Allow checking FoxLib version more easilly.
func isFoxLibAtLeast(major=0, minor=0, patch=0):
	return Globals.isFoxLibAtLeast(major, minor, patch)

# Allows datapacks to set your mod as a mod requirement without having to force a file name, also check for duplicates
func swapLoadedModNameOrShowError(modName=null):
	if modName == null:
		modName = self.id
	var modNamePrefix = modName + "_"
	var loadedMods = GlobalRegistry.getLoadedMods()
	var modFileName = null
	var modFileIndex = -1
	var iterationIndex = 0
	for loadedMod in loadedMods:
		if loadedMod.begins_with(modNamePrefix):
			if modFileName == null:
				modFileName = loadedMod
				modFileIndex = iterationIndex
			elif modFileName == loadedMod:
				Log.print("[FoxLib] Duplicated \"" + loadedMod + "\" in mod list, something went wrong, appending mod name to loaded mod list instead...")
				loadedMods.append(modName)
				return
			else:
				FoxUIManager.fatalError("[color=#FF1010]" + modName + " is loaded twice, please delete one of the " + modName + "! " +
										"(Found \"[color=#00FFFF]" + modFileName + "[/color]\" and \"[color=#00FFFF]" + loadedMod + "[/color]\")[/color]")
				return
		iterationIndex = iterationIndex + 1
	if modFileIndex != -1:
		loadedMods[modFileIndex] = modName

# Species API
func getVanillaSpeciesEquivalent(speciesId):
	return FoxGameRegistry.getVanillaSpeciesEquivalent(speciesId)

# Mod Options API 
func addBooleanOption(optionID, title, description=null, defaultValue=false):
	return self.addBooleanOptionInCategory(self.getName(), optionID, title, description, defaultValue)

func addBooleanOptionInCategory(category, optionID, title, description=null, defaultValue=false):
	return self.addOptionInCategoryInternal("checkbox", category, optionID, title, description, defaultValue)

func addNumberOption(optionID, title, description=null, defaultValue=0):
	return self.addNumberOptionInCategory(self.getName(), optionID, title, description, defaultValue)

func addNumberOptionInCategory(category, optionID, title, description=null, defaultValue=0):
	return self.addOptionInCategoryInternal("int", category, optionID, title, description, defaultValue)

func addListOption(optionID, title, values, description=null, defaultValue=null):
	return self.addListOptionInCategory(self.getName(), optionID, title, values, description, defaultValue)

func addListOptionInCategory(category, optionID, title, values, description=null, defaultValue=null):
	return self.addOptionInCategoryInternal("list", category, optionID, title, description, defaultValue, values)

func addSliderOption(optionID, title, description=null, defaultValue=0):
	return self.addSliderOptionInCategory(self.getName(), optionID, title, description, defaultValue)

func addSliderOptionInCategory(category, optionID, title, description=null, defaultValue=0):
	return self.addOptionInCategoryInternal("slider", category, optionID, title, description, defaultValue)

func addButtonOption(optionID, title, description=null, defaultValue=null):
	return self.addButtonOptionInCategory(self.getName(), optionID, title, description, defaultValue).setPlaceholder(title)

func addButtonOptionInCategory(category, optionID, title, description=null, defaultValue=null):
	return self.addOptionInCategoryInternal("button", category, optionID, title, description, defaultValue).setPlaceholder(title)

func addOptionInCategoryInternal(type, category, optionID, title, description=null, defaultValue=false, values=null):
	var bdccModule = self.getModule()
	var newOption = FoxOption.new()
	newOption.moduleID = self.moduleId
	newOption.category = category
	newOption.optionID = optionID
	newOption.title = title
	newOption.description = description
	newOption.type = type
	if defaultValue == null and values != null and not values.empty():
		defaultValue = values[0][0]
	newOption.defaultValue = defaultValue
	newOption.values = values
	newOption.advancedOnly = false
	if bdccModule != null and optionID in bdccModule:
		newOption.bindToField(bdccModule, optionID)
	var registeredOption = newOption.register()
	if registeredOption != null:
		return registeredOption
	return newOption

func registerFoxPriorityOptionCategory(priorityCategory=null):
	if priorityCategory == null:
		priorityCategory = self.getName()
	FoxOptionsManager.registerFoxPriorityCategory(priorityCategory)

# Game Test API
func registerGameTest(path):
	return FoxGameTestManager.registerGameTest(path)

# StatusBar API
func registerFoxStatusBar(statusID, statusName=null, colorGradient=null, maxValue=0):
	var statusBar = FoxLibStatusBarsManager.getOrMakeFromId(statusID)
	if statusName == null:
		statusName = statusID
	if statusBar.name == "Status":
		statusBar.name = statusName
	if statusBar.defaultMaxValue == 100 and maxValue >= 1:
		statusBar.defaultMaxValue = maxValue
	if colorGradient != null:
		statusBar.setGradient(colorGradient)
	return statusBar

func getCorruptionFoxStatusBar():
	return FoxLibStatusBarsManager.getOrMakeFromId("corruption")

func getInfestationFoxStatusBar():
	return FoxLibStatusBarsManager.getOrMakeFromId("infestation")

# Audio API
func newAudio(audioId, track1=null, track2=null, track3=null, track4=null, track5=null):
	var foxAudio = FoxAudio.new()
	foxAudio.id = self.moduleId + ":" + audioId
	var module = self.getModule()
	if module != null and module.author != "no author":
		foxAudio.author = module.author
	FoxLibAudioManager.registerFoxAudio(foxAudio)
	if track1 != null:
		foxAudio.addAudioPath(track1)
	if track2 != null:
		foxAudio.addAudioPath(track2)
	if track3 != null:
		foxAudio.addAudioPath(track3)
	if track4 != null:
		foxAudio.addAudioPath(track4)
	if track5 != null:
		foxAudio.addAudioPath(track5)
	return foxAudio

func stopBGM():
	FoxLibAudioManager.playBGM(null)

func playNamedAsSFX(foxAudioId):
	if not (":" in foxAudioId):
		foxAudioId = self.moduleId + ":" + foxAudioId
	FoxAudio.playNamedAsSFX(foxAudioId)

func playNamedAsBGM(foxAudioId):
	if not (":" in foxAudioId):
		foxAudioId = self.moduleId + ":" + foxAudioId
	FoxAudio.playNamedAsBGM(foxAudioId)
