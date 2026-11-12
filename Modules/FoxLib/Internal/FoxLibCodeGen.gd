const Globals = preload("res://FoxLib/Globals.gd")
const FoxLibCompat = preload("res://Modules/FoxLib/Internal/FoxLibCompat.gd")

const CodeGenRootPath = "user://foxlib/codegen"
const CodeGenTestPath = CodeGenRootPath + "/test.gd"

class FoxLibCodeGenData:
	var hasCodeGen = false

# Init make the codegen folder and ensure codegen capabilities
static func init():
	if Globals.isFoxLibInSafeMode():
		Log.error("[FoxLib] CodeGen unavailable (safe-mode)")
		return
	var dir = Directory.new()
	dir.make_dir_recursive(CodeGenRootPath)
	if dir.open(CodeGenRootPath) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(CodeGenRootPath + "/" + file_name)
			file_name = dir.get_next()
	var file = File.new()
	if file.open(CodeGenTestPath, File.WRITE) != 0:
		Log.error("[FoxLib] CodeGen unavailable (no write)")
		return
	file.store_line("extends Object")
	file.store_line("")
	file.store_line("static func test():")
	file.store_line("	return true")
	file.store_line("")
	file.close()
	var codegen_test = load(CodeGenTestPath)
	if codegen_test == null:
		Log.error("[FoxLib] CodeGen unavailable (no load)")
		return
	if codegen_test.test() != true:
		Log.error("[FoxLib] CodeGen unavailable (ret fail)")
		return
	var codegen_test_insn = codegen_test.new()
	if codegen_test_insn == null:
		Log.error("[FoxLib] CodeGen unavailable (no insn)")
		return
	Log.print("[FoxLib] CodeGen available")
	Globals.of(FoxLibCodeGenData).hasCodeGen = true

static func hasCodeGen():
	return Globals.of(FoxLibCodeGenData).hasCodeGen

# Skill code gen code
class SkillCodeGen:
	var id = null
	var sourceFile = null
	var targetFile = null
	var nameOverride = false
	var descOverride = false
	var perkTierOverride = false
	# Apply func
	func apply():
		var file = File.new()
		if file.open(self.targetFile, File.WRITE) != 0:
			Log.error("[FoxLib] CodeGen failed on " + str(self.targetFile) + " (no write)")
			return
		file.store_line("extends \"" + str(self.sourceFile) + "\"")
		file.store_line("")
		file.store_line("const FoxGameRegistry = preload(\"res://FoxLib/FoxGameRegistry.gd\")")
		file.store_line("")
		if self.nameOverride:
			file.store_line("func getVisibleName():")
			file.store_line("	return FoxGameRegistry.getSkillNameOverride(self.id)")
			file.store_line("")
		if self.descOverride:
			file.store_line("func getVisibleDescription():")
			file.store_line("	return FoxGameRegistry.getSkillDescOverride(self.id)")
			file.store_line("")
		if self.perkTierOverride:
			file.store_line("func getPerkTiers():")
			file.store_line("	return FoxGameRegistry.getPerkTiersOverride(self.id)")
			file.store_line("")
		file.close()
		# Load file into registry
		GlobalRegistry.getSkills()[self.id] = load(self.targetFile)

static func makeSkillCodeGen(skillId):
	if not Globals.of(FoxLibCodeGenData).hasCodeGen:
		return null
	var sourceFile = FoxLibCompat.getSourceSkillFile(skillId)
	if sourceFile == null:
		Log.error("[FoxLib] CodeGen failed for skill " + skillId + " (no source file found)")
		return null
	var skillCodeGen = SkillCodeGen.new()
	skillCodeGen.id = skillId
	skillCodeGen.sourceFile = sourceFile
	skillCodeGen.targetFile = CodeGenRootPath + "/skill_" + skillId + ".gd"
	return skillCodeGen


