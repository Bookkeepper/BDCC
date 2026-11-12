extends "res://FoxLib/FoxCrotchBlock.gd"

func getCategories():
	return ["FoxLib"]

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	var hasPCCastityCage = _contex.getFlagRaw("MedicalModule.PC_ReceivedPermanentCage", false)
	if not hasPCCastityCage:
		return false
	var isCagePermanent = _contex.getFlagRaw("MedicalModule.Chastity_Event5LockedForever", false)
	var receivedRing = _contex.getFlagRaw("MedicalModule.Chastity_ReceivedRing", false)
	if isCagePermanent and not receivedRing:
		return true
	var eventNumber = _contex.getFlagRaw("MedicalModule.Chastity_EventNumber", 0)
	return eventNumber < 7

func getTemplate():
	return [
		{
			type = "label",
			text = "Player has chastity events",
		},
	]

