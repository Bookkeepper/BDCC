extends DynamicCharacter
#class_name FoxCharacter
#public_api

var allowForget = false # We except the char cannot be forgotten...
var dynamicPersonality = false # If false, force saved data to be used as personality value.
var internalDynamicGroups = []
var internalDynamicGroupsNeedUpdate = false
var internalLoadingDynData = false
var npcInmateType = InmateType.Unknown

func onSavingData(_data):
	pass

func onLoadingData(_data):
	pass

func onDataLoaded(_data):
	pass

# If this is set to false, NPC level will be forcibly set to the one definied by "npcLevel"
func canLevelUp() -> bool:
	return true

func canAutoLevelUpFromFights() -> bool:
	return self.canLevelUp()

# Only called when bodyparts are differents, currentId may be an empty string if we currently don't have a bodypart in that slot.
func shouldLoadBodypartData(_slot, currentId, _savedId):
	return currentId != ""

# Dynamic groups may be used by datapacks. (Ex: CharacterPool.Inmates)
func setDynamicGroups(dynamicGroup):
	if dynamicGroup == null:
		dynamicGroup = []
	elif (dynamicGroup is String):
		dynamicGroup = [dynamicGroup]
	if internalDynamicGroups.size() == 0 and dynamicGroup.size() == 0:
		return
	self.internalDynamicGroups = dynamicGroup
	var main = GM.main
	if main == null:
		self.internalDynamicGroupsNeedUpdate = true
		return
	main.removeDynamicCharacterFromAllPools(self.id)
	for poolId in dynamicGroup:
		main.addDynamicCharacterToPool(self.id, poolId)

# Possible slot values: Head, Hair, Ears, Horns, Body, Arms, Breasts, Penis, Vagina, Anus, Tail, Legs
# See: https://github.com/Alexofp/BDCC/blob/main/Player/Bodyparts/BodypartSlot.gd
# Make a bodypart using the first bodypart id available in the provided array, and return it.
# If no bodyparts can be made or retreived, null is returned.
const SkinDataRGB = ["r", "g", "b"] 
func giveBodypartModular(slot, bodypartIds, skinData=null, retOnlyIfNew=false):
	if slot == null or not slot is String:
		return null
	if skinData != null and skinData is Dictionary:
		for rgb in SkinDataRGB:
			if typeof(skinData.get(rgb)) == TYPE_STRING:
				skinData[rgb] = Color(skinData[rgb])
		npcSkinData[slot] = skinData
	if bodyparts == null:
		bodypartIds = []
	elif (bodypartIds is String):
		bodypartIds = [bodypartIds]
	elif not (bodypartIds is Array):
		return null
	var selectedBodypartId = null
	for bodypartId in bodypartIds:
		if bodypartId in GlobalRegistry.getBodypartRefs():
			selectedBodypartId = bodypartId
			break
	if selectedBodypartId == null:
		# This is a method made to avoid failing, so let's avoid failing...
		var lastBodypartId = bodypartIds.get(bodypartIds.size() - 1)
		selectedBodypartId = BodypartSlot.findReplacement(slot, lastBodypartId)
	if selectedBodypartId == null:
		Log.print("[FoxLib] For " + getName() + "'s " + str(slot) + " found no valid part using " + str(bodypartIds))
		return null
	# Now that we have a valid bodypart id to add, let's check it against the bodypart present in that slot...
	var oldBodyPartData = null
	if self.hasBodypart(slot):
		var existingBodypart = self.getBodypart(slot)
		if existingBodypart.id == selectedBodypartId:
			if skinData != null and skinData is Dictionary:
				internalApplySkinDataToBodypart(existingBodypart, skinData)
			if retOnlyIfNew:
				return null
			return existingBodypart
		if shouldLoadBodypartData(slot, selectedBodypartId, existingBodypart.id):
			oldBodyPartData = existingBodypart.saveData()
	# Make new body part since we have a possible missmatch
	var initBodypart = GlobalRegistry.createBodypart(selectedBodypartId)
	if initBodypart.getSlot() != slot:
		Log.print("[FoxLib] For " + getName() + "'s " + str(slot) + " found bodypart " + selectedBodypartId + " but it is not belonging to this slot")
		return null
	giveBodypart(initBodypart)
	if oldBodyPartData != null:
		initBodypart.loadData(oldBodyPartData)
	if skinData != null and skinData is Dictionary:
		internalApplySkinDataToBodypart(initBodypart, skinData)
	if retOnlyIfNew and oldBodyPartData != null:
		return null
	return initBodypart

# Hooks & Non-API stuff.
func _ready():
	self.internalUpdateSpecialData()

func personalityChangesAfterSex():
	return self.dynamicPersonality

func updateNonBattleEffects():
	.updateNonBattleEffects()
	self.internalUpdateSpecialData()

func paintBodyparts():
	for bodypartSlot in npcSkinData:
		if(!hasBodypart(bodypartSlot)):
			continue
		var bodypart = getBodypart(bodypartSlot)
		var bodypartSkinData = npcSkinData[bodypartSlot]
		internalApplySkinDataToBodypart(bodypart, bodypartSkinData)

func internalApplySkinDataToBodypart(bodypart, skinData):
	bodypart.pickedSkin = null
	bodypart.pickedRColor = null
	bodypart.pickedGColor = null
	bodypart.pickedBColor = null
	if(skinData.has("skin")):
		bodypart.pickedSkin = skinData["skin"]
	if(skinData.has("r")):
		bodypart.pickedRColor = skinData["r"]
	if(skinData.has("g")):
		bodypart.pickedGColor = skinData["g"]
	if(skinData.has("b")):
		bodypart.pickedBColor = skinData["b"]

func resetSlots():
	if self.internalLoadingDynData:
		return
	.resetSlots()
	return

func loadData(data):
	self.onLoadingData(data)
	# Backup important fields
	var staticPickedSkin = self.pickedSkin
	var staticPickedSkinRColor = self.pickedSkinRColor
	var staticPickedSkinGColor = self.pickedSkinGColor
	var staticPickedSkinBColor = self.pickedSkinBColor
	var staticNpcLevel = self.npcLevel
	var staticNpcBasePain = self.npcBasePain
	var staticNpcBaseLust = self.npcBaseLust
	var staticNpcBaseStamina = self.npcBaseStamina
	var staticNpcDefaultEquipment = self.npcDefaultEquipment
	# Handle bodypart data loading ourselves to get the best of both worlds.
	self.resetSlots()
	self.createBodyparts()
	var loadedBodyparts = SAVE.loadVar(data, "bodyparts", {})
	data["bodyparts"] = {}
	for slot in loadedBodyparts:
		if(loadedBodyparts[slot] == null):
			continue
		var bodypartStuff = SAVE.loadVar(loadedBodyparts, slot, {})
		var bodypartId = SAVE.loadVar(bodypartStuff, "id", "")
		var bodypartData = SAVE.loadVar(bodypartStuff, "data", {})
		if not self.hasBodypart(slot):
			if self.shouldLoadBodypartData(slot, "", bodypartId):
				var bodypart = GlobalRegistry.createBodypart(bodypartId)
				if bodypart == null:
					continue
				bodypart.loadData(bodypartData)
				self.giveBodypart(bodypart, false)
			continue
		var bodypart = getBodypart(slot)
		if bodypartId != bodypart.id and (bodypartId == "" or not self.shouldLoadBodypartData(slot, bodypart.id, bodypartId)):
			Log.printerr("[FoxLib] Bodypart changed for "+getName()+"'s "+str(slot)+", ignoring data (was "+bodypartId+", became "+bodypart.id+")")
			continue
		bodypart.loadData(bodypartData)
	# Load actual data
	self.internalLoadingDynData = true
	.loadData(data)
	self.internalLoadingDynData = false
	# Restore save data
	data["bodyparts"] = loadedBodyparts
	# Fixup skin
	self.pickedSkin = staticPickedSkin
	self.pickedSkinRColor = staticPickedSkinRColor
	self.pickedSkinGColor = staticPickedSkinGColor
	self.pickedSkinBColor = staticPickedSkinBColor
	self.paintBodyparts()
	# Fixup stats
	self.npcLevel = staticNpcLevel
	self.npcBasePain = staticNpcBasePain
	self.npcBaseLust = staticNpcBaseLust
	self.npcBaseStamina = staticNpcBaseStamina
	var charSkillHolder = self.getSkillsHolder()
	if self.canLevelUp():
		if charSkillHolder.getLevel() < staticNpcLevel:
			charSkillHolder.setLevel(staticNpcLevel)
		for statID in npcStats:
			if skillsHolder.getStat(statID) < npcStats[statID]:
				skillsHolder.setStat(statID, npcStats[statID])
	else:
		charSkillHolder.setLevel(staticNpcLevel)
		for statID in npcStats:
			skillsHolder.setStat(statID, npcStats[statID])
	# Restore equipment data
	self.npcDefaultEquipment = staticNpcDefaultEquipment
	if "inmatecollar" in staticNpcDefaultEquipment:
		equipDefaultEquipmentEntrySafely("inmatecollar")
	self.onDataLoaded(data)
	return

func saveData():
	var data = .saveData()
	self.onSavingData(data)
	return data

func internalUpdateSpecialData():
	if not self.allowForget:
		if self.extraSettings == null:
			self.extraSettings = DynCharExtraSettings.new()
		self.extraSettings.disableForget = true
	if self.internalDynamicGroupsNeedUpdate:
		self.internalDynamicGroupsNeedUpdate = false
		self.setDynamicGroups(self.internalDynamicGroups)
	if self.npcInmateType != null and self.npcInmateType != InmateType.Unknown:
		setFlag(CharacterFlag.InmateType, self.npcInmateType)

