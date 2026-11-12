const Globals = preload("res://FoxLib/Globals.gd")
const HypertusCompatibilityDir = "res://Modules/Z_Hypertus/compatibilityLayers"

class FoxLibCompatData:
	var moduleSkills = {
		Skill.Combat: "res://Skills/Skill/Combat.gd",
		Skill.CumLover: "res://Skills/Skill/CumLover.gd",
		Skill.Breeder: "res://Skills/Skill/Breeder.gd",
		Skill.SexSlave: "res://Skills/Skill/SexSlave.gd",
		Skill.BDSM: "res://Skills/Skill/BDSM.gd",
		Skill.Milking: "res://Skills/Skill/Milking.gd",
		Skill.Fertility: "res://Skills/Skill/Fertility.gd",
	}
	var moduleSpecies = {
		Species.Canine: "res://Species/Canine.gd",
		Species.Demon: "res://Species/Demon.gd",
		Species.Dragon: "res://Species/Dragon.gd",
		Species.Equine: "res://Species/Equine.gd",
		Species.Feline: "res://Species/Feline.gd",
		Species.Human: "res://Species/Human.gd",
		Species.Unknown: "res://Species/Unknown.gd",
	}
	var hyperSpecies = {}

static func getSourceSkillFile(skillId):
	return Globals.of(FoxLibCompatData).moduleSkills.get(skillId)

static func getSourceSpeciesFile(speciesId):
	var compatData = Globals.of(FoxLibCompatData)
	# Hypertus has priority
	var hyperSpecies = compatData.hyperSpecies.get(speciesId)
	if hyperSpecies != null:
		return hyperSpecies
	return compatData.moduleSpecies.get(speciesId)

# Generic compat data
static func loadModuleCompatData():
	var compatData = Globals.of(FoxLibCompatData)
	var modules = GlobalRegistry.getModules()
	for idM in modules:
		var module = modules[idM]
		var skills = module.skills
		var species = module.species
		for skillFile in skills:
			var skillId = load(skillFile).new().id
			compatData.moduleSkills[skillId] = skillFile
		for speciesFile in species:
			var speciesId = load(speciesFile).new().id
			compatData.moduleSpecies[speciesId] = speciesFile

# Hypertus specific code
static func loadHypertusCompatData():
	if not ("Hypertus" in GlobalRegistry.getModules()):
		return
	Log.print("[FoxLib] Registering Hypertus Compatibility Data")
	var forceBreedEdition = GlobalRegistry.getModules()["Hypertus"].forceBreedEdition
	var dirClass = Directory.new()
	var fileClass = File.new()
	var compatData = Globals.of(FoxLibCompatData)
	if dirClass.open(HypertusCompatibilityDir) == OK:
		dirClass.list_dir_begin()
		var fileName = dirClass.get_next()
		while fileName != "":
			if !dirClass.current_is_dir():
				if fileName.get_extension() == "json":
					if fileClass.open(fileName,File.READ) != OK:
						fileName = dirClass.get_next()
						continue
					var _jsonResult = JSON.parse(fileClass.get_as_text())
					if _jsonResult.error != OK:
						fileName = dirClass.get_next()
						continue
					appendHypertusCompatData(compatData, _jsonResult.result, forceBreedEdition)
			fileName = dirClass.get_next()

static func appendHypertusCompatData(compatData, theDict, forceBreedEdition):
	for modindex in theDict.keys():
		var curIndex = theDict[modindex]
		if curIndex.has("moduleid"):
			if curIndex["moduleid"] in GlobalRegistry.getModules() or curIndex["moduleid"] == "*":
				if curIndex.has("species"):
					appendHypertusSpiciesData(compatData, curIndex.get("species"), forceBreedEdition)
				if curIndex.has("speciesDir"):
					var _dirClass = Directory.new()
					var _dictOfSpeciesPath = {}
					for path in curIndex.get("speciesDir"):
						var _ok1 = _dirClass.open(path)
						if _ok1 == OK:
							_dirClass.list_dir_begin(true)
							var file_name = _dirClass.get_next()
							while file_name != "":
								if !_dirClass.current_is_dir():
									if file_name.get_extension() == "gd":
										var tempSpe = load(path.plus_file(file_name))
										var speciesObject = tempSpe.new()
										var speciesID = speciesObject.id
										_dictOfSpeciesPath[speciesID] = path.plus_file(file_name)
								file_name = _dirClass.get_next()
					if _dictOfSpeciesPath.size() > 0:
						appendHypertusSpiciesData(compatData, _dictOfSpeciesPath, forceBreedEdition)

static func appendHypertusSpiciesData(compatData, theDict, _forceBreedEdition):
	var fileClass = File.new()
	if theDict is Dictionary:
		for idS in theDict:
			if idS in GlobalRegistry.allSpecies:
				var fileSource = theDict[idS]
				if fileClass.file_exists(fileSource):
					compatData.hyperSpecies[idS] = fileSource
	elif theDict is Array:
		for fileSource in theDict:
			var idS = load(fileSource).id
			if idS in GlobalRegistry.allSpecies:
				if fileClass.file_exists(fileSource):
					compatData.hyperSpecies[idS] = fileSource

