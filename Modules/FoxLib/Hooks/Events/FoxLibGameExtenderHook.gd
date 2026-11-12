extends GameExtender

func _init():
	id = "FoxLibGameExtenderHook"

func register(_GES:GameExtenderSystem):
	_GES.register(self, ExtendGame.pcBeforeFightStarted)
	_GES.register(self, ExtendGame.pcProcessTime)
	_GES.register(self, ExtendGame.pcHoursPassed)

func pcBeforeFightStarted(_pc:Player):
	_pc.getSkillsHolder().addPerk("FoxLibPerkHook")

func pcProcessTime(_pc:Player, _seconds):
	_pc.getSkillsHolder().addPerk("FoxLibPerkHook")

func pcHoursPassed(_pc:Player, _hours):
	_pc.getSkillsHolder().addPerk("FoxLibPerkHook")

