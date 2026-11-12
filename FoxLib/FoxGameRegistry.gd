extends Object
#class_name FoxGameRegistry
#public_api

const Globals = preload("res://FoxLib/Globals.gd")
const FLMHDebug = preload("res://FoxLib/ModHelper/FLMHDebug.gd")
const FoxLibCodeGen = preload("res://Modules/FoxLib/Internal/FoxLibCodeGen.gd")
const FoxLibCompat = preload("res://Modules/FoxLib/Internal/FoxLibCompat.gd")
const FoxLibEventUtil = preload("res://Modules/FoxLib/Internal/FoxLibEventUtil.gd")
const DebugMode = true

# Godot 3 doesn't support "static var", this work as a replacement for it.
class FoxGameRegistryData:
	var initialized = false
	var skillPerkTiersOverrides = {}
	var skillPerkTiersInjections = {}
	var skillNameOverrides = {}
	var skillDescOverrides = {}
	var forceNameOverride = false
	var vanillaSpeciesEquivalents = {
		Species.Canine: Species.Canine,
		Species.Demon: Species.Demon,
		Species.Dragon: Species.Dragon,
		Species.Equine: Species.Equine,
		Species.Feline: Species.Feline,
		Species.Human: Species.Human,
		Species.Unknown: Species.Unknown,
		# Internal error species
		"error": Species.Unknown,
		# Vanilla Modules species
		"icejogauni": Species.Canine,
	}

# always return one of theses: [Species.Human, Species.Feline, Species.Dragon, Species.Canine, Species.Equine, Species.Demon, Species.Unknown]
static func getVanillaSpeciesEquivalent(speciesId):
	var vaillaSpeciesId = Globals.of(FoxGameRegistryData).vanillaSpeciesEquivalents.get(speciesId)
	if vaillaSpeciesId == null:
		return Species.Unknown
	return vaillaSpeciesId

static func getPerkTiersOverride(skillId):
	return Globals.of(FoxGameRegistryData).skillPerkTiersOverrides.get(skillId)

static func setPerkTiersOverride(skillId, perkTiers):
	if Globals.isFoxLibInSafeMode():
		Log.error("[FoxLib] setPerkTiersOverride() is unavailable in safe-mode!")
		return
	Log.print("[FoxLib] Calling setPerkTiersOverride() is deprecated, use addPerkTierLevel() instead")
	Globals.of(FoxGameRegistryData).skillPerkTiersOverrides[skillId] = perkTiers

static func setSkillNameOverride(skillId, newName):
	var sData = Globals.of(FoxGameRegistryData)
	sData.skillNameOverrides[skillId] = newName

static func getSkillNameOverride(skillId):
	var sData = Globals.of(FoxGameRegistryData)
	return sData.skillNameOverrides.get(skillId)

# Useful if you want to change all the skill names at runtime
static func forceSkillNameOverrides():
	var sData = Globals.of(FoxGameRegistryData)
	if sData.initialized:
		Log.error("forceSkillNameOverrides() after registry has been initialized")
	sData.forceNameOverride = true

static func setSkillDescOverride(skillId, newName):
	var sData = Globals.of(FoxGameRegistryData)
	sData.skillDescOverrides[skillId] = newName

static func getSkillDescOverride(skillId):
	var sData = Globals.of(FoxGameRegistryData)
	return sData.skillDescOverrides.get(skillId)

static func addPerkTierLevel(skillId, perkTierLevel):
	var sData = Globals.of(FoxGameRegistryData)
	var injections = sData.skillPerkTiersInjections.get(skillId)
	if injections == null:
		injections = []
		sData.skillPerkTiersInjections[skillId] = injections
	if not ([perkTierLevel] in injections):
		if Globals.isFoxLibInSafeMode():
			Log.error("[FoxLib] addPerkTierLevel() is unavailable in safe-mode!")
			return
		injections.append([perkTierLevel])
		if injections.size() > 1:
			injections.sort()
			injections.invert()

static func getPerkTierForLevel(skillID, perkTierLevel):
	var perkTiers = getPerkTiersOverride(skillID)
	if perkTiers == null:
		return 0
	var perkTierIndex = 0
	for perkTier in perkTiers:
		var perkLevel = perkTier[0]
		if perkLevel == perkTierLevel or perkLevel > perkTierLevel:
			return perkTierIndex
		perkTierIndex = perkTierIndex + 1
	perkTierIndex = perkTierIndex - 1
	return perkTierIndex

static func internalPostInitialize():
	var sData = Globals.of(FoxGameRegistryData)
	sData.initialized = true
	FoxLibCompat.loadModuleCompatData()
	FoxLibCompat.loadHypertusCompatData()
	FoxLibCodeGen.init()
	var FoxLibModule = Globals.ofModule("FoxLib")
	if FoxLibModule.hotfixes != null and FoxLibCodeGen.hasCodeGen():
		FoxLibModule.hotfixes.applyCodeGenHotfixes()
	var skillOverrides = {}
	for skillID in sData.skillPerkTiersOverrides.keys():
		skillOverrides[skillID] = true
	for skillID in sData.skillPerkTiersInjections.keys():
		var oldSkill = GlobalRegistry.getSkills().get(skillID)
		if oldSkill == null:
			continue
		var injections = sData.skillPerkTiersInjections.get(skillID)
		var perkTiers = sData.skillPerkTiersOverrides.get(skillID)
		if perkTiers == null:
			perkTiers = oldSkill.new().getPerkTiers()
		# Inject perk tiers in duplicated array
		perkTiers = perkTiers.duplicate()
		for perkTier in injections:
			if not (perkTier in perkTiers):
				perkTiers.append(perkTier)
		if perkTiers.size() > 1:
			perkTiers.sort()
			perkTiers.invert()
		sData.skillPerkTiersOverrides[skillID] = perkTiers
		skillOverrides[skillID] = true
	for skillID in sData.skillNameOverrides.keys():
		skillOverrides[skillID] = true
	for skillID in sData.skillDescOverrides.keys():
		skillOverrides[skillID] = true
	# If sData.forceNameOverride  is true, override all skills
	if sData.forceNameOverride:
		for skillID in GlobalRegistry.getSkills().keys():
			skillOverrides[skillID] = true
	# This will override previously registered skills
	for skillID in skillOverrides.keys():
		var skillCodeGen = FoxLibCodeGen.makeSkillCodeGen(skillID)
		if skillCodeGen == null:
			continue
		if sData.skillPerkTiersOverrides.get(skillID) != null:
			skillCodeGen.perkTierOverride = true
		if sData.skillNameOverrides.get(skillID) != null:
			skillCodeGen.nameOverride = true
		elif sData.forceNameOverride:
			var oldSkill = GlobalRegistry.getSkills().get(skillID)
			sData.skillNameOverrides[skillID] = oldSkill.new().getVisibleName()
			skillCodeGen.nameOverride = true
		if sData.skillDescOverrides.get(skillID) != null:
			skillCodeGen.descOverride = true
		skillCodeGen.apply()
	# Tried an order that make the most sense
	internalPostInitializeCheckSpecies(sData, Species.Canine, null, null, false)
	internalPostInitializeCheckSpecies(sData, Species.Feline, null, null, false)
	internalPostInitializeCheckSpecies(sData, Species.Equine, null, "midnighthead", false)
	internalPostInitializeCheckSpecies(sData, Species.Dragon, null, null, false)
	internalPostInitializeCheckSpecies(sData, Species.Demon, null, null, false)
	internalPostInitializeCheckSpecies(sData, Species.Human, null, null, false)
	# Do it again for more unsure/lax checks
	internalPostInitializeCheckSpecies(sData, Species.Canine, "caninepenis", null, true)
	internalPostInitializeCheckSpecies(sData, Species.Feline, null, null, true)
	internalPostInitializeCheckSpecies(sData, Species.Equine, "equinepenis", "midnighthead", true)
	internalPostInitializeCheckSpecies(sData, Species.Dragon, null, null, true)
	internalPostInitializeCheckSpecies(sData, Species.Demon, null, null, true)
	internalPostInitializeCheckSpecies(sData, Species.Human, null, null, true)

static func internalPostInitializeCheckSpecies(sData, checkSpeciesID, bodypartExtra, exludeBodypart, second):
	var speciesParts = []
	for bodypartSlot in BodypartSlot.getAll():
		for bodypartID in GlobalRegistry.getBodypartsIdsBySlot(bodypartSlot):
			if bodypartID != bodypartExtra and bodypartID != exludeBodypart and [checkSpeciesID] == GlobalRegistry.getBodypartRef(bodypartID).getCompatibleSpecies():
				speciesParts.append(bodypartID)
	if bodypartExtra != null:
		speciesParts.append(bodypartExtra)
	var allSpecies = GlobalRegistry.getAllSpecies()
	for speciesID in allSpecies:
		if sData.vanillaSpeciesEquivalents.get(speciesID) != null:
			continue
		var specie = allSpecies.get(speciesID)
		for slot in BodypartSlot.getAll():
			var slotDefault = specie.getDefaultForSlot(slot, Gender.Androgynous)
			if slotDefault in speciesParts:
				if sData.vanillaSpeciesEquivalents.get(speciesID) == null:
					sData.vanillaSpeciesEquivalents[speciesID] = checkSpeciesID
		for part in speciesParts:
			if second and part in specie.getAllowedBodyparts():
				if sData.vanillaSpeciesEquivalents.get(speciesID) == null:
					sData.vanillaSpeciesEquivalents[speciesID] = checkSpeciesID

static func internalCallModulesHandlers(methodName, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null):
	return FoxLibEventUtil.internalCallModulesHandlers(methodName, arg1, arg2, arg3, arg4, arg5)

static func internalCallPlayerModulesHandlers(methodName, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null):
	return FoxLibEventUtil.internalCallPlayerModulesHandlers(methodName, arg1, arg2, arg3, arg4, arg5)

