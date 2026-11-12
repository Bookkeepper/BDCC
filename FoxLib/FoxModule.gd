extends Module
#class_name FoxModule
#public_api

# use extends "res://FoxLib/FoxModule.gd" to use FoxModule,
# FoxModule allows you to access FoxLib features more easily inside your mod

# For Debug support
const FLMHDebug = preload("res://FoxLib/ModHelper/FLMHDebug.gd")

# APIs
const FoxCrotchBlockManager = preload("res://Modules/FoxLib/Internal/FoxCrotchBlockManager.gd")
const FoxGameRegistry = preload("res://FoxLib/FoxGameRegistry.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const FoxOption = preload("res://FoxLib/FoxOption.gd")
const FoxFonts = preload("res://FoxLib/FoxFonts.gd")
const FoxAudio = preload("res://FoxLib/FoxAudio.gd")
const Globals = preload("res://FoxLib/Globals.gd")

# Computed at compile time
const FoxLibVersion = "0.10.7"

# Use "getFoxModuleAPI" instead.
var internalFoxModuleAPI = null

# "formBanks", "fillers", and "adders" are from "Game/ModularDialogue/ModularDialogue.gd"
var formBanks = []
var fillers = []
var adders =  []
var crotchBlocks = []
var gameTests = []

# Name will fallback to id if not defined
var name = null

func register():
	.register()
	
	for formBank in formBanks:
		var theBank = load(formBank).new()
		if(theBank is DialogueFormBank):
			ModularDialogue.registerFormBank(theBank)
	for filler in fillers:
		var theFiller = load(filler).new()
		if(theFiller is DialogueFiller):
			ModularDialogue.registerFiller(theFiller)
	for adder in adders:
		var theFiller = load(adder).new()
		if(theFiller is DialogueFillerAdder):
			ModularDialogue.registerAdder(theFiller)
	for crotchBlock in crotchBlocks:
		FoxCrotchBlockManager.registerCrotchBlockFile(crotchBlock)
	for gameTest in gameTests:
		self.registerGameTest(gameTest)

func getName() -> String:
	if self.name != null:
		return self.name
	return self.id

# Use custom module name in display list
func getRegisterName() -> String:
	var authorStr = str(self.author)
	if(authorStr != "Rahi"):
		return self.getName() + " module by " + authorStr
	return self.getName() + " module"

func registerDatapackTrigger(triggerID):
	FoxCrotchBlockManager.registerCustomTrigger(triggerID)

# FoxModule API
func getFoxModuleAPI():
	if self.internalFoxModuleAPI == null:
		self.internalFoxModuleAPI = load("res://FoxLib/FoxModuleAPI.gd").new()
		self.internalFoxModuleAPI.moduleId = self.id
		self.internalFoxModuleAPI.moduleCache = weakref(self)
	return self.internalFoxModuleAPI

# Allow checking BDCC version more easilly.
func isBDCCAtLeast(major=0, minor=0, patch=0, bugfix=0):
	return Globals.isBDCCAtLeast(major, minor, patch, bugfix)

# Allow checking FoxLib version more easilly.
func isFoxLibAtLeast(major=0, minor=0, patch=0):
	return Globals.isFoxLibAtLeast(major, minor, patch)

# Allows datapacks to set your mod as a mod requirement without having to force a file name, also check for duplicates
func swapLoadedModNameOrShowError(modName=null):
	self.getFoxModuleAPI().swapLoadedModNameOrShowError(modName)

# Species API
func getVanillaSpeciesEquivalent(speciesId):
	return FoxGameRegistry.getVanillaSpeciesEquivalent(speciesId)

# Mod Options API
func addBooleanOption(optionID, title, description=null, defaultValue=false):
	return self.getFoxModuleAPI().addBooleanOption(optionID, title, description, defaultValue)

func addBooleanOptionInCategory(category, optionID, title, description=null, defaultValue=false):
	return self.getFoxModuleAPI().addBooleanOptionInCategory(category, optionID, title, description, defaultValue)

func addNumberOption(optionID, title, description=null, defaultValue=0):
	return self.getFoxModuleAPI().addNumberOption(optionID, title, description, defaultValue)

func addNumberOptionInCategory(category, optionID, title, description=null, defaultValue=0):
	return self.getFoxModuleAPI().addNumberOptionInCategory(category, optionID, title, description, defaultValue)

func addListOption(optionID, title, values, description=null, defaultValue=null):
	return self.getFoxModuleAPI().addListOption(optionID, title, values, description, defaultValue)

func addListOptionInCategory(category, optionID, title, values, description=null, defaultValue=null):
	return self.getFoxModuleAPI().addListOptionInCategory(category, optionID, title, values, description, defaultValue)

func addSliderOption(optionID, title, description=null, defaultValue=0):
	return self.getFoxModuleAPI().addSliderOption(optionID, title, description, defaultValue)

func addSliderOptionInCategory(category, optionID, title, description=null, defaultValue=0):
	return self.getFoxModuleAPI().addSliderOptionInCategory(category, optionID, title, description, defaultValue)

func addButtonOption(optionID, title, description=null, defaultValue=null):
	return self.getFoxModuleAPI().addButtonOption(optionID, title, description, defaultValue)

func addButtonOptionInCategory(category, optionID, title, description=null, defaultValue=null):
	return self.getFoxModuleAPI().addButtonOptionInCategory(category, optionID, title, description, defaultValue)

func registerFoxPriorityOptionCategory(priorityCategory=null):
	self.getFoxModuleAPI().registerFoxPriorityOptionCategory(priorityCategory)

# Game Test API
func registerGameTest(path):
	return self.getFoxModuleAPI().registerGameTest(path)

# StatusBar API
func registerFoxStatusBar(statusID, statusName=null, colorGradient=null, maxValue=0):
	return self.getFoxModuleAPI().registerFoxStatusBar(statusID, statusName, colorGradient, maxValue)

func getCorruptionFoxStatusBar():
	return self.getFoxModuleAPI().getCorruptionFoxStatusBar()

func getInfestationFoxStatusBar():
	return self.getFoxModuleAPI().getInfestationFoxStatusBar()

# Audio API
func newAudio(audioId, track1=null, track2=null, track3=null, track4=null, track5=null):
	return self.getFoxModuleAPI().newAudio(audioId, track1, track2, track3, track4, track5)

func stopBGM():
	self.getFoxModuleAPI().stopBGM()

func playNamedAsSFX(foxAudioId):
	self.getFoxModuleAPI().playNamedAsSFX(foxAudioId)

func playNamedAsBGM(foxAudioId):
	self.getFoxModuleAPI().playNamedAsBGM(foxAudioId)
