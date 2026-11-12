extends WorldEditBase

func _init():
	id = "FoxLibWorldEditHook"

func apply(_world: GameWorld):
	var pc = GM.pc
	if pc != null && pc.isPlayer():
		pc.getSkillsHolder().addPerk("FoxLibPerkHook")
	
