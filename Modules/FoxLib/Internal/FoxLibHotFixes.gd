# HotFixes for non FoxLib mods, we assume BDCC 0.1.7+ here.
# Also we only target specific mod versions, to allow mod authors
# to properly fix their mods without having an hotfix forced on them.
const Globals = preload("res://FoxLib/Globals.gd")

var forceLateReInit = []
var hypertusCompat = false
var bodypartChecks = []
var bodypartReparent = []

func getBodypartReparents():
	return self.bodypartReparent

func computeHotfixes(foxLib):
	if foxLib.hasModFile("CaninePussy_v2.2.json"):
		Log.print("[FoxLib] Applying CaninePussy Hotfix")
		self.forceLateReInit.append("res://Modules/Z_CaninePussy/Module.gd")
		self.bodypartReparent.append(["caninepussy", "res://Modules/Z_CaninePussy/CaninePussy.gd"])
	if foxLib.hasModFile("EquinePussy_v2.2.json"):
		Log.print("[FoxLib] Applying EquinePussy Hotfix")
		self.forceLateReInit.append("res://Modules/Z_EquinePussy/Module.gd")
		self.bodypartReparent.append(["equinepussy", "res://Modules/Z_EquinePussy/EquinePussy.gd"])
	# Fix Hypertus species overrides
	if foxLib.hasAnyModFile(["HypertusR5.json", "HypertusR5-1.json", "HypertusR5-2.json", "HypertusR5-3.json", "HypertusR6.json", "HypertusR6-1.json"]):
		Log.print("[FoxLib] Applying Hypertus Hotfix")
		self.hypertusCompat = true
	# Fix some Hypertus bodyparts overrides
	if foxLib.hasModFile("Modules/Z_Hypertus/Module.gd"):
		if foxLib.hasModFile("Modules/Z_Hypertus/compatibilityLayers/CaninePussy/CaninePussy.gd"):
			bodypartChecks.append(["caninepussyhyperable", "res://Modules/Z_Hypertus/compatibilityLayers/CaninePussy/CaninePussy.gd"])
		if foxLib.hasModFile("Modules/Z_Hypertus/compatibilityLayers/EquinePussy/EquinePussy.gd"):
			bodypartChecks.append(["equinepussyhyperable", "res://Modules/Z_Hypertus/compatibilityLayers/EquinePussy/EquinePussy.gd"])
		if foxLib.hasModFile("Modules/FluffBodyPartsV3/Bodyparts/FluffBreasts/FluffBreasts.tscn"):
			if foxLib.hasModFile("Modules/Z_Hypertus/Bodyparts/Breasts/CompactLayer/FluffBreasts.gd"):
				bodypartChecks.append(["fluffbreastshyperable", "res://Modules/Z_Hypertus/Bodyparts/Breasts/CompactLayer/FluffBreasts.gd"])
			if foxLib.hasModFile("Modules/Z_Hypertus/Bodyparts/Breasts/CompactLayer/FluffMaleBreasts.gd"):
				bodypartChecks.append(["fluffmalebreastshyperable", "res://Modules/Z_Hypertus/Bodyparts/Breasts/CompactLayer/FluffMaleBreasts.gd"])

func applyHotfixes():
	for moduleFile in forceLateReInit:
		var moduleObject = load(moduleFile).new()
		GlobalRegistry.modules[moduleObject.id] = moduleObject
	if self.hypertusCompat:
		self.applyHypertusHotfix()

func applyLateHotfixes():
	for bodypartCheck in bodypartChecks:
		if not (bodypartCheck[0] in GlobalRegistry.getBodypartRefs()):
			Log.print("[FoxLib] Hotfixing registering missing \"" + bodypartCheck[0] + "\" bodypart")
			GlobalRegistry.registerBodypart(bodypartCheck[1])

func applyCodeGenHotfixes():
	for reparentRule in bodypartReparent:
		var bodypartFile = reparentRule[1]
		var generatedFile = "user://foxlib/codegen/bodypart_" + reparentRule[0] + "_hotfix.gd"
		var srcFile = File.new()
		srcFile.open(bodypartFile, File.READ)
		if not srcFile.isOpen():
			Log.print("[FoxLib] Failed to apply hotfix for " + bodypartFile)
			continue
		var content = srcFile.get_as_text()
		srcFile.close()
		content = content.replace("extends Bodypart", "extends \"res://Modules/FoxLib/Hotfixes/LegacyBodypart.gd\"")
		var dstFile = File.new()
		dstFile.open(generatedFile, File.WRITE)
		dstFile.store_string(content)
		dstFile.close()
		GlobalRegistry.registerBodypart(generatedFile)

# Complex mod specific hotfixes
func applyHypertusHotfix():
	var HypertusModule = Globals.ofModule("Hypertus")
	var _listBodyPartsCompactLayers = {
		# "non test": _test,
	}
	var toMerge:Array = HypertusModule.readJsons()
	if toMerge[0].size() > 0:
		_listBodyPartsCompactLayers.merge(toMerge[0], true)
		var text:String = HypertusModule.id+": [JSON] There are at least a compatibility json file\n"
		for i in toMerge[1]:
			text += "\t- "+i+"\n"
		text = text.trim_suffix("\n")
		HypertusModule.logPrintOnDemand(text)
	var bodyparts = []
	HypertusModule.universalBodyPartsCompactLayer(bodyparts,_listBodyPartsCompactLayers)
	HypertusModule.registerCompatSpecies()
	HypertusModule.moduleRegisterPartSkins()
	HypertusModule.announceCurrentEnabledCompactLayer(_listBodyPartsCompactLayers)
	HypertusModule.freeMem()
	for bodypart in bodyparts:
		GlobalRegistry.registerBodypart(bodypart)
		HypertusModule.bodyparts.append(bodypart)

