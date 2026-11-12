var id
var visibleName
var description
var canCombine
var tags
var itemTexture

func getVisibleName(_itemImpl):
	return visibleName.getStr(_itemImpl)

func getDescription(_itemImpl):
	return description.getStr(_itemImpl)

func canUseInCombat(_itemImpl):
	return false

func useInCombat(_itemImpl, _attacker, _receiver):
	# Need to make combat usage handler later
	return "Missing combat usage message"

func getPossibleActions(_itemImpl):
	return []

func getPrice(_itemImpl):
	return 0

func canSell(_itemImpl):
	return false

func getTags(_itemImpl):
	return tags

func getItemCategory(_itemImpl):
	return ItemCategory.Generic

func getInventoryImage(_itemImpl):
	return itemTexture

# Dynamic String API
class StaticStr:
	var value
	func getStr(_itemImpl):
		return value

class SimpleDynamicStr:
	var value
	func getStr(_itemImpl):
		return value.replace("${datapackItemID}", _itemImpl.datapackItemID)

static func makeDynStr(source):
	var datapackStr = null
	if "${datapackItemID}" in source:
		datapackStr = SimpleDynamicStr.new()
	else:
		datapackStr = StaticStr.new()
	datapackStr.value = source
	return datapackStr

