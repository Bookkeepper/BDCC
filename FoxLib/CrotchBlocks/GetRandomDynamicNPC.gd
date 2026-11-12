extends "res://FoxLib/FoxCrotchBlock.gd"

const FoxLibPrevGenIDs = "FoxLibPrevGenIDs"

const Unique = "Unique"
const AllowPawns = "AllowPawns"
const AllowFailure = "AllowFailure"
const OnlyUseExisting = "OnlyUseExisting"
const HasVagina = "HasVagina"
const HasPenis = "HasPenis"
const HasReachableVagina = "HasReachableVagina"
const HasReachablePenis = "HasReachablePenis"
const HasReachableAnus = "HasReachableAnus"
const InmateGeneralBlock = "InmateGeneralBlock"
const InmateHighSecBlock = "InmateHighSecBlock"
const InmateSexDeviantBlock = "InmateSexDeviantBlock"

const ImplementedConds = [
	[Unique, "Unique", "Make charters unique for every call, list is reset when non unique call is made",],
	[AllowPawns, "Allow Pawns", "Allow active prison pawns to be selected",],
	[AllowFailure, "Allow Failure", "Will return an empty string instead of throwing an error when unable to get a matching character",],
	[OnlyUseExisting, "Only Use Existing", "Only use existing characters, preventing new character from being generated",],
	[HasVagina, "Has Vagina",],
	[HasPenis, "Has Penis",],
	[HasReachableVagina, "Has Reachable Vagina",],
	[HasReachablePenis, "Has Reachable Penis",],
	[HasReachableAnus, "Has Reachable Anus",],
	[InmateGeneralBlock, "Inmate General Block",],
	[InmateHighSecBlock, "Inmate High Security Block",],
	[InmateSexDeviantBlock, "Inmate Sex Deviant Block",],
]

var poolIdSlot := CrotchSlotVar.new()
var npcCondSlot := FoxCrotchFlagsSlot.new()

func _init():
	poolIdSlot.setRawType(CrotchVarType.STRING)
	poolIdSlot.setRawValue(CharacterPool.Guards)
	npcCondSlot.addImpliedFlag(OnlyUseExisting, AllowFailure)
	npcCondSlot.addExclusiveFlags([HasVagina, HasReachableVagina])
	npcCondSlot.addExclusiveFlags([HasPenis, HasReachablePenis])
	npcCondSlot.addExclusiveFlags([InmateGeneralBlock, InmateHighSecBlock, InmateSexDeviantBlock])

func getCategories():
	return ["FoxLib (NPC)"]

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	var poolId = poolIdSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return
	if(!isString(poolId)):
		throwError(_contex, "Item id must be a string, got "+str(poolId)+" instead")
		return
	
	var foxLibParams = getFoxLibInternalVars(_contex)
	var foxLibAvoidIDs = foxLibParams.get(FoxLibPrevGenIDs)
	if foxLibAvoidIDs == null:
		foxLibAvoidIDs = []
		foxLibParams[FoxLibPrevGenIDs] = foxLibAvoidIDs
	var generatorParams = {}
	var poolNpcCondition = []
	var npcGenerator = null
	
	# Cond Unique + Negative Cond AllowPawns
	if not npcCondSlot.hasFlag(AllowPawns):
		var tmpAvoidIDs = []
		if npcCondSlot.hasFlag(Unique):
			tmpAvoidIDs.append_array(foxLibAvoidIDs)
		else:
			foxLibAvoidIDs.clear()
		for pawnCharId in GM.main.IS.pawns.keys():
			if not tmpAvoidIDs.has(pawnCharId):
				tmpAvoidIDs.append(pawnCharId)
		poolNpcCondition.append([NpcCon.AvoidIDs, tmpAvoidIDs])
	elif npcCondSlot.hasFlag(Unique):
		poolNpcCondition.append([NpcCon.AvoidIDs, foxLibAvoidIDs])
	else:
		foxLibAvoidIDs.clear()
	# Cond HasReachableVagina
	if npcCondSlot.hasFlag(HasVagina):
		generatorParams[NpcGen.HasVagina] = true
		poolNpcCondition.append([NpcCon.HasVagina])
	# Cond HasPenis
	if npcCondSlot.hasFlag(HasPenis):
		generatorParams[NpcGen.HasPenis] = true
		poolNpcCondition.append([NpcCon.HasPenis])
	# Cond HasReachableVagina
	if npcCondSlot.hasFlag(HasReachableVagina):
		generatorParams[NpcGen.HasVagina] = true
		generatorParams[NpcGen.NoChastity] = true
		poolNpcCondition.append([NpcCon.HasReachableVagina])
	# Cond HasReachablePenis
	if npcCondSlot.hasFlag(HasReachablePenis):
		generatorParams[NpcGen.HasPenis] = true
		generatorParams[NpcGen.NoChastity] = true
		poolNpcCondition.append([NpcCon.HasReachablePenis])
	# Cond HasReachableAnus
	if npcCondSlot.hasFlag(HasReachableAnus):
		poolNpcCondition.append([NpcCon.HasReachableAnus])
	# Cond InmateGeneralBlock
	if npcCondSlot.hasFlag(InmateGeneralBlock):
		generatorParams[NpcGen.Flag] = [[CharacterFlag.InmateType, InmateType.General]]
		poolNpcCondition.append([NpcCon.FlagEquals, CharacterFlag.InmateType, InmateType.General])
	# Cond InmateHighSecBlock
	if npcCondSlot.hasFlag(InmateHighSecBlock):
		generatorParams[NpcGen.Flag] = [[CharacterFlag.InmateType, InmateType.HighSec]]
		poolNpcCondition.append([NpcCon.FlagEquals, CharacterFlag.InmateType, InmateType.HighSec])
	# Cond InmateSexDeviantBlock
	if npcCondSlot.hasFlag(InmateSexDeviantBlock):
		generatorParams[NpcGen.Flag] = [[CharacterFlag.InmateType, InmateType.SexDeviant]]
		poolNpcCondition.append([NpcCon.FlagEquals, CharacterFlag.InmateType, InmateType.SexDeviant])
	
	if npcCondSlot.hasFlag(OnlyUseExisting):
		npcGenerator = null
	elif poolId == CharacterPool.Guards:
		npcGenerator = GuardGenerator.new()
	elif poolId == CharacterPool.Nurses:
		npcGenerator = NurseGenerator.new()
	elif poolId == CharacterPool.Inmates:
		npcGenerator = InmateGenerator.new()
	elif poolId == CharacterPool.Engineers:
		npcGenerator = EngineerGenerator.new()
	
	var npcId = null
	if npcGenerator != null:
		npcId = NpcFinder.grabNpcIDFromPoolOrGenerate(poolId, poolNpcCondition, npcGenerator, generatorParams, true)
	else:
		npcId = NpcFinder.grabNpcIDFromPool(poolId, poolNpcCondition)
	
	if npcId == null or npcId == "":
		if not npcCondSlot.hasFlag(AllowFailure):
			throwError(_contex, "Failed to get random NPC from " + str(poolId) + " pool")
		return ""
	foxLibAvoidIDs.append(npcId)
	return npcId

func getTemplate():
	return [
		{
			type = "label",
			text = "Get Random NPC from",
		},
		{
			type = "slot",
			id = "poolId",
			slot = poolIdSlot,
			slotType = CrotchBlocks.VALUE,
		},
		{
			type = "label",
			text = "with",
		},
		{
			type = "slot",
			id = "npcCond",
			slot = npcCondSlot,
			slotType = CrotchBlocks.VALUE,
		},
	]

func getSlot(_id):
	if(_id == "poolId"):
		return poolIdSlot
	if(_id == "npcCond"):
		return npcCondSlot

func updateVisualSlot(_editor, _id, _visSlot):
	if(_id == "poolId"):
		_visSlot.setPossibleValues(CharacterPool.getAllPools())
	if(_id == "npcCond"):
		_visSlot.setPossibleValues(ImplementedConds)
