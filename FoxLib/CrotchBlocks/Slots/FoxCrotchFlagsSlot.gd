extends CrotchSlotVar
#class_name FoxCrotchFlagsSlot

const FLAGS_DELIMITER = ", "
const FoxCrotchBlockManager = preload("res://Modules/FoxLib/Internal/FoxCrotchBlockManager.gd")

var flags = null
var impliedFlags = {}
var exclusiveFlags = []
var forceAtLeastOneFlag = false

func _init():
	self.setRawType(CrotchVarType.STRING)

func setRawValue(newValue):
	.setRawValue(newValue)
	flags = rawValue.split(FLAGS_DELIMITER)

func getRawValue():
	FoxCrotchBlockManager.checkFoxCrotchFlagSlot(self)
	return self.rawValue

func loadData(_data):
	.loadData(_data)
	flags = rawValue.split(FLAGS_DELIMITER)

func hasFlag(flag):
	return flag != "" and flags != null and flags.has(flag)

func addExclusiveFlags(_flags):
	if (not (_flags is Array)) or _flags.size() < 2:
		return
	exclusiveFlags.append(_flags)

func addImpliedFlag(fromFlag, impliesFlag):
	impliedFlags[fromFlag] = impliesFlag

func getFlags():
	if rawValue == null or rawValue == "":
		return []
	if flags == null:
		flags = rawValue.split(FLAGS_DELIMITER)
		for flag in flags:
			while flag != null and impliedFlags.has(flag):
				flag = impliedFlags.get(flag)
				if flags.has(flag):
					flag = null
				else:
					flags.add(flag)
	return flags
