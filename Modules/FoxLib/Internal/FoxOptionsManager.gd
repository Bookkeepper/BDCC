const Globals = preload("res://FoxLib/Globals.gd")
const FoxOptionsPath = "user://foxlib/mod_options.cfg"

class FoxOptionsRegistry:
	var need_saving = false
	var fox_options = null
	var fox_options_buttons = []
	var fox_options_buttons_index = {}
	var fox_options_priority_categories = []

static func getFoxOptionsButtons():
	return Globals.of(FoxOptionsRegistry).fox_options_buttons

static func getFoxOptionsPriorityCategories():
	return Globals.of(FoxOptionsRegistry).fox_options_priority_categories

static func registerFoxOption(instance):
	var data = Globals.of(FoxOptionsRegistry)
	var moduleID = instance.moduleID
	var optionID = instance.optionID
	var module_index_object = null
	if data.fox_options_buttons_index.has(moduleID):
		module_index_object = data.fox_options_buttons_index[moduleID]
	else:
		module_index_object = {}
		data.fox_options_buttons_index[moduleID] = module_index_object
	if module_index_object.has(optionID):
		Log.print("[FoxLib] Duplicate option: [" + moduleID + "]:" + optionID)
		return module_index_object[optionID]
	module_index_object[optionID] = instance
	
	data.fox_options_buttons.append(instance)
	return instance

static func registerFoxPriorityCategory(priorityCategory):
	Globals.of(FoxOptionsRegistry).fox_options_priority_categories.append(priorityCategory)

static func getFoxOptionsRegistryInternal():
	var data = Globals.of(FoxOptionsRegistry)
	if data.fox_options == null:
		data.fox_options = ConfigFile.new()
		data.fox_options.load(FoxOptionsPath)
	return data

static func getOption(mod, key, defaultValue):
	var data = getFoxOptionsRegistryInternal()
	var fox_options = data.fox_options
	if fox_options.has_section_key(mod, key):
		return fox_options.get_value(mod, key)
	return defaultValue

static func getOrFillOption(mod, key, defaultValue):
	var data = getFoxOptionsRegistryInternal()
	var fox_options = data.fox_options
	if fox_options.has_section_key(mod, key):
		return fox_options.get_value(mod, key)
	fox_options.set_value(mod, key, defaultValue)
	data.need_saving = true
	return defaultValue

static func getOrFillBooleanOption(mod, key, defaultValue):
	return getOrFillOption(mod, key, defaultValue) == true

static func setOption(mod, key, newValue):
	var data = getFoxOptionsRegistryInternal()
	var fox_options = data.fox_options
	fox_options.set_value(mod, key, newValue)
	data.need_saving = true

static func clearOption(mod, key):
	var data = getFoxOptionsRegistryInternal()
	var fox_options = data.fox_options
	if fox_options.has_section_key(mod, key):
		fox_options.erase_section_key(mod, key)
	data.need_saving = true

static func getOptionInternal(mod, key):
	var data = Globals.of(FoxOptionsRegistry)
	var module_index_object = data.fox_options_buttons_index[mod]
	if module_index_object == null:
		Log.print("[FoxLib] Missing module \"" + mod + "\" for option \"" + key + "\"")
		return null
	var optionButton = module_index_object[key]
	if optionButton == null:
		Log.print("[FoxLib] Missing option \"" + key + "\" in module \"" + mod + "\"")
		return null
	return optionButton

static func applyOptionInternal(mod, key, newValue):
	var data = Globals.of(FoxOptionsRegistry)
	var optionButton = getOptionInternal(mod, key)
	if optionButton == null:
		return
	optionButton.setOptionValue(newValue)
	data.need_saving = true

static func resetToDefaults():
	var data = Globals.of(FoxOptionsRegistry)
	for option in data.fox_options_buttons:
		option.resetOptionValue()
	data.need_saving = true

static func optionalySave():
	var data = getFoxOptionsRegistryInternal()
	if not data.need_saving:
		return
	data.need_saving = false
	data.fox_options.save(FoxOptionsPath)

