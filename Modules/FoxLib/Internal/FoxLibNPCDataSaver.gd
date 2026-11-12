extends GameExtender

# https://github.com/Alexofp/BDCC/blob/main/Characters/Character.gd
# https://github.com/Alexofp/BDCC/blob/main/Characters/Dynamic/DynamicCharacter.gd

const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")

func _init():
	id = "FoxLibNPCData"

func register(_GES:GameExtenderSystem):
	_GES.register(self, ExtendGame.saveLoadData)

func saveData():
	var data = {}
	FoxUIManager.callOrQueueConsumerOnMainThread(self, "saveDataMT", data)
	return data

func saveDataMT(data):
	#Log.print("[FoxLib] Saving extra NPC Data...")
	var npcDataTmp = {}
	for npcId in GM.main.getCharacters():
		if npcId == "pc" or data.has(npcId):
			continue
		saveForNPC(npcId, npcDataTmp)
		if npcDataTmp.size() > 0:
			data[npcId] = npcDataTmp
			npcDataTmp = {}
	for npcId in GM.main.getDynamicCharacters():
		if npcId == "pc" or data.has(npcId):
			continue
		saveForNPC(npcId, npcDataTmp)
		if npcDataTmp.size() > 0:
			data[npcId] = npcDataTmp
			npcDataTmp = {}
	#Log.print("[FoxLib] Extra NPC Data saved!")

func loadData(_data):
	self.call_deferred("restoreDataDelayed", _data)

func restoreDataDelayed(_npcData):
	if GM.main == null:
		return
	var data = _npcData
	if data == null or data.size() == 0:
		return
	#Log.print("[FoxLib] Loading extra NPC Data...")
	for npcID in data:
		if npcID == "pc":
			continue
		loadForNPC(npcID, data.get(npcID))
	#Log.print("[FoxLib] Extra NPC Data loaded!")

func loadForNPC(_npcID, _npcData):
	if _npcData == null:
		return
	var npc = GM.main.getCharacter(_npcID)
	if npc == null:
		Log.print("[FoxLib] Missing charter " + _npcID + " ignoring extra npc data...")
		return
	if _npcData.has("skills"):
		npc.getSkillsHolder().loadData(SAVE.loadVar(_npcData, "skills", {}))

func saveForNPC(_npcID, _npcData):
	if _npcData == null:
		return
	var npc = GM.main.getCharacter(_npcID)
	if npc == null or not is_instance_valid(npc):
		# assert(false, "saveForNPC called on non-existent NPC!!!")
		return
	if npc.disableSerialization:
		return
	if shouldSaveSkills(_npcID, npc):
		_npcData["skills"] = npc.getSkillsHolder().saveData()

func shouldSaveSkills(_npcID, _npc):
	# Dynamic characters already save their skills/perks in the base game
	if _npc.isDynamicCharacter():
		return false
	# Check if SkillHolder has useful data to save
	var skillHolder = _npc.getSkillsHolder()
	if skillHolder.getSkills().size() > 0:
		return true
	if skillHolder.getPerks().size() > 0:
		return true
	return false

