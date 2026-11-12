const Globals = preload("res://FoxLib/Globals.gd")
const DatapackItem = preload("res://Modules/FoxLib/DynContent/DatapackItem.gd")

# Godot 4 require "static var" instead.
const cachedStrings = {}
const noTags = []

class FoxDatapackItemRegistry:
	var datapackItems = {}
	var datapackItemsKeys = ["null"]
	var nullDatapackItem = null
	var allowRegisteringItems = false

static func makeDynStr(_string, _addToCache):
	var dynStr = cachedStrings.get(_string)
	if dynStr != null:
		return dynStr
	dynStr = DatapackItem.makeDynStr(_string)
	if _addToCache:
		cachedStrings[_string] = dynStr
	return dynStr

static func internalNewDatapackItem(id):
	var datapackItem = DatapackItem.new()
	datapackItem.id = id
	datapackItem.visibleName = makeDynStr(id, false)
	datapackItem.description = makeDynStr("Missing Description", true)
	datapackItem.canCombine = true
	datapackItem.tags = noTags
	datapackItem.itemTexture = "res://Images/Items/generic/chip.png"
	return datapackItem

static func getFoxDatapackItemRegistryInternal():
	var registry = Globals.of(FoxDatapackItemRegistry)
	if registry.nullDatapackItem == null:
		# Cache "" and "null" strings
		makeDynStr("", true)
		makeDynStr("null", true)
		# Make fallback datapack item
		var nullDatapackItem = internalNewDatapackItem("null")
		nullDatapackItem.canCombine = false
		nullDatapackItem.visibleName = makeDynStr("Missing datapack item", true)
		nullDatapackItem.description = makeDynStr("It look like the datapack linked to this item isn't enabled! (Datapack Item ID: \"${datapackItemID}\")", true)
		registry.nullDatapackItem = nullDatapackItem
	return registry

static func resetDatapackItemRegistry():
	var registry = getFoxDatapackItemRegistryInternal()
	registry.datapackItems.clear()
	registry.datapackItems["null"] = registry.nullDatapackItem
	registry.allowRegisteringItems = true

static func finalizeDatapackItemRegistry():
	var registry = getFoxDatapackItemRegistryInternal()
	registry.datapackItemsKeys = registry.datapackItems.keys()
	registry.allowRegisteringItems = false
	# Reset cache for player items
	var pc = GM.pc
	if pc != null:
		for item in pc.inventory.items:
			if item.id == "FoxLibDatapackItem":
				item.datapackItemCache = null

static func getDatapackItem(id):
	var registry = getFoxDatapackItemRegistryInternal()
	if id == null or id == "":
		return registry.nullDatapackItem
	var datapackItem = registry.datapackItems.get(id)
	if datapackItem == null:
		return registry.nullDatapackItem
	return datapackItem

static func isInvalidNewItemId(id):
	return id == null or id == "" or id == "null" or " " in id

static func genNewDatapackItem(id):
	if isInvalidNewItemId(id):
		return null
	var registry = Globals.of(FoxDatapackItemRegistry)
	if registry.datapackItems.get(id) != null or not registry.allowRegisteringItems:
		return null
	var newDatapackItem = internalNewDatapackItem(id)
	registry.datapackItems[id] = newDatapackItem
	return newDatapackItem

