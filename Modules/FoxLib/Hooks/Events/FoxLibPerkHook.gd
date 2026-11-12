extends PerkBase

const FoxLibEventUtil = preload("res://Modules/FoxLib/Internal/FoxLibEventUtil.gd")

func _init():
	id = "FoxLibPerkHook"
	skillGroup = "FoxLibSkillHook"

func getVisibleName():
	return "FoxLib internal GameHook"

func getVisibleDescription():
	return "This perk is used internally by FoxLib, if you see this text, something probably went wrong..."

func getSkillTier():
	return 0

func hiddenWhenUnlocked() -> bool:
	return true

func toggleable() -> bool:
	return false

func getCost():
	return 0

func setCharacter(newnpc):
	npc = newnpc
	if newnpc != null && newnpc.isPlayer():
		Log.print("[FoxLib] Successfully loaded on save file")

func onFightStart(_contex = {}):
	FoxLibEventUtil.internalCallModulesHandlers("onFightStart", npc, _contex)

func processBattleTurnContex(_contex = {}):
	FoxLibEventUtil.internalCallModulesHandlers("onProcessBattleTurnContex", npc, _contex)

func onFightEnd(_contex = {}):
	FoxLibEventUtil.internalCallModulesHandlers("onFightEnd", npc, _contex)

func onSexStarted(_contex = {}):
	FoxLibEventUtil.internalCallModulesHandlers("onSexStarted", npc, _contex)

func processSexTurnContex(_contex = {}):
	FoxLibEventUtil.internalCallModulesHandlers("onProcessSexTurnContex", npc, _contex)

func onSexEvent(_contex = {}):
	FoxLibEventUtil.internalCallModulesHandlers("onSexEvent", npc, _contex)

func onSexEnded(_contex = {}):
	FoxLibEventUtil.internalCallModulesHandlers("onSexEnded", npc, _contex)

