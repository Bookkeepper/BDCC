extends ItemBase

const DatapackItemRegistry = preload("res://Modules/FoxLib/DynContent/DatapackItemRegistry.gd")

var datapackItemID = "null"
var datapackItemData = ""
var datapackItemCache = null

func _init():
	id = "FoxLibDatapackItem"

func getVisibleName():
	return getDatapackItem(true, "getVisibleName").getVisibleName(self)

func getDescription():
	return getDatapackItem(true, "getDescription").getDescription(self)

func canUseInCombat():
	return getDatapackItem(true, "canUseInCombat").canUseInCombat()

func useInCombat(_attacker, _receiver):
	return getDatapackItem(true, "useInCombat").useInCombat(self, _attacker, _receiver)

func getPossibleActions():
	return getDatapackItem(true, "getPossibleActions").getPossibleActions(self)

func getPrice():
	return getDatapackItem(true, "getPrice").getPrice(self)

func canSell():
	return getDatapackItem(true, "canSell").canSell(self)

func canCombine():
	return getDatapackItem(false, "canCombine").canCombine

func tryCombine(_otherItem):
	if(not canCombine()):
		return false
	if(datapackItemID != _otherItem.datapackItemID):
		return false
	if(datapackItemData != _otherItem.datapackItemData):
		return false
	return .tryCombine(_otherItem)

func getTags():
	return getDatapackItem(true, "getTags").getTags(self)

func getItemCategory():
	return getDatapackItem(true, "getItemCategory").getItemCategory(self)

func saveData():
	var data = .saveData()
	
	data["datapackItemID"] = datapackItemID
	data["datapackItemData"] = datapackItemData
	
	return data

func loadData(data):
	.loadData(data)
	
	datapackItemID = SAVE.loadVar(data, "datapackItemID", "null")
	datapackItemData = SAVE.loadVar(data, "datapackItemData", "")
	datapackItemCache = null

func getInventoryImage():
	return getDatapackItem(true, "getInventoryImage").getInventoryImage(self)

func getDatapackItemID():
	return datapackItemID

func setDatapackItemID(_datapackItemID):
	datapackItemID = _datapackItemID
	datapackItemCache = null

func getDatapackItem(_fillCache=true, _source=null):
	if datapackItemCache != null:
		return datapackItemCache
	var datapackItem = DatapackItemRegistry.getDatapackItem(datapackItemID)
	if datapackItemID == "null":
		datapackItemCache = datapackItem
		return datapackItem
	# if _source != null:
	# 	Log.print("[FoxLib] Source: " + _source)
	if _fillCache:
		datapackItemCache = datapackItem
	return datapackItem 
