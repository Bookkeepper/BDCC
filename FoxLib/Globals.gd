extends Object
#class_name Globals
#public_api
#nodebug

# Abusing Godot 3 behaviour to make globals as it doesn't support "static var"
# This will not work on Godot 4, unless "const" is replaced by "static var" 
const globals = {}

static func of(cls):
	var instance = globals.get(cls)
	if instance != null:
		if instance == cls:
			return null
		return instance
	instance = cls.new()
	globals[cls] = instance
	return instance

static func clear(cls):
	globals[cls] = null

static func ofModule(moduleId):
	return GlobalRegistry.getModules().get(moduleId)

static func isBDCCAtLeast(major=0, minor=0, patch=0, bugfix=0):
	if major < GlobalRegistry.game_version_major:
		return true
	if major > GlobalRegistry.game_version_major:
		return false
	if minor < GlobalRegistry.game_version_minor:
		return true
	if minor > GlobalRegistry.game_version_minor:
		return false
	if patch < GlobalRegistry.game_version_revision:
		return true
	if patch > GlobalRegistry.game_version_revision:
		return false
	if bugfix <= 0:
		return true
	var suffix = GlobalRegistry.game_version_suffix.trim_prefix("fix").trim_prefix("bugfix")
	if suffix == null or suffix.length() == 0 or not suffix.is_valid_integer():
		return false
	return bugfix <= suffix.to_int()

# This method heavilly uses FLMH_mod_version_* macros a lot.
# Check out FoxLib ModHelper documentation for more details.
static func isFoxLibAtLeast(major=0, minor=0, patch=0):
	if major < 0:
		return true
	if major > 0:
		return false
	if minor < 10:
		return true
	if minor > 10:
		return false
	return patch <= 7

# For checking if FoxLib is in safe mode
static func isFoxLibInSafeMode():
	var foxLibModule = ofModule("FoxLib")
	if foxLibModule != null:
		return foxLibModule.safeMode
	var FoxOptionsManager = load("res://Modules/FoxLib/Internal/FoxOptionsManager.gd")
	if FoxOptionsManager == null:
		return false
	return FoxOptionsManager.getOrFillBooleanOption("FoxLib", "runInSafeMode", false)
