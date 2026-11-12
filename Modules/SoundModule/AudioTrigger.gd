extends PerkBase

func _init():
	id = "AudioTrigger"
	npc = null
	skillGroup = Skill.Inherent
	dungeonWeight = 0.0

func getVisibleName():
	return "You shouldn't see this"

func getVisibleDescription():
	return "You shouldn't see this"

func runOnceWhenLearned():
	pass

func getSkillTier():
	return 0
	
func hiddenWhenLocked() -> bool:
	return true
	
func hiddenWhenUnlocked() -> bool:
	return true

func toggleable() -> bool:
	return true
	
func unlockable() -> bool:
	return true

func getPicture():
	return "res://Images/Perks/upgrade.png"

func processBattleTurn():
	pass
	
func onFightStart(_contex = {}):
	pass

func processBattleTurnContex(_contex = {}):
	pass

func onFightEnd(_contex = {}):
	pass

func onSexStarted(_contex = {}):
	pass

func processSexTurnContex(_contex = {}):
	pass

func onSexEvent(_event:SexEvent):
	pass

func onSexEnded(_contex = {}):
	pass

	
func onPerkToggled(_isEnabledNow):
	pass
	

func saveData():
	return {
		
	}

func loadData(_data):
	#level = SAVE.loadVar(data, "level", 0)
	pass

