# Put early hook in a separate class so FoxLib can be "late-loaded" properly
const Globals = preload("res://FoxLib/Globals.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const FoxOptionsManager = preload("res://Modules/FoxLib/Internal/FoxOptionsManager.gd")

class OnlyOnceTrigger:
	var triggered = false
	func trigger():
		if triggered:
			return true
		triggered = true
		return false

static func onEarlyInit():
	if Globals.of(OnlyOnceTrigger).trigger():
		return
	if FoxOptionsManager.getOrFillBooleanOption("FoxLib", "showConsoleOnBoot", true):
		FoxUIManager.showGameConsole()
	# Fix Loaded mod list before printing it.
	var loadedMods = GlobalRegistry.getLoadedMods()
	if loadedMods.size() == 0: # Mod list repeat fix expect at least one element, but in editor loadedMods size will be 0
		loadedMods.append("FoxLib_v0.10.7.zip")
	elif not GlobalRegistry.hasModSupport(): # Fix FoxLib special testing mode assuming modding is unsupported
		GlobalRegistry.modsSupport = true
	var firstLoadedMod = loadedMods[0]
	var checkModIndex = 1
	# Mod option menu should never be allowed to duplicate mods, somehow modlist can be duplicated under unkown circumstances
	while checkModIndex < loadedMods.size():
		if firstLoadedMod == loadedMods[checkModIndex]:
			break
		checkModIndex += 1
	if checkModIndex != loadedMods.size():
		if (loadedMods.size() % checkModIndex) == 0:
			var duplicationCount = (loadedMods.size() / checkModIndex) - 1
			var duplicationText = str(duplicationCount) + " times"
			if duplicationCount == 1:
				duplicationText = "1 time"
			Log.print("[FoxLib] Mods list got duplicated " + duplicationText + ", fixing up the mods list!")
			loadedMods.resize(checkModIndex)
		else:
			Log.print("[FoxLib] Mods list is damaged in some way FoxLib wasn't able to properly recover")
	var loadedModList = "[FoxLib] Loaded mod list: "
	for mod in loadedMods:
		loadedModList = loadedModList + mod + ", "
	Log.print(loadedModList.substr(0, loadedModList.length() - 2))
	if FoxOptionsManager.getOrFillBooleanOption("FoxLib", "runInSafeMode", false):
		Log.print("[FoxLib] Running FoxLib in safe-mode!")
	Log.print("[FoxLib] Game initializing, please wait...")
