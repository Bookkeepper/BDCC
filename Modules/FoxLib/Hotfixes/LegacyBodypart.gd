extends Bodypart

# Used by hotfixer to fix some problematic bodyparts
const needSensitiveZone = {
	BodypartSlot.Breasts: "res://Player/SensitiveZone/SensitiveBreasts.gd",
	BodypartSlot.Penis: "res://Player/SensitiveZone/SensitivePenis.gd",
	BodypartSlot.Vagina: "res://Player/SensitiveZone/SensitiveVagina.gd",
	BodypartSlot.Anus: "res://Player/SensitiveZone/SensitiveAnus.gd",
}

func _init():
	setupSensitiveZone()

func setupSensitiveZone():
	var wantSlot = self.getSlot()
	var sensitiveZoneSource = needSensitiveZone[wantSlot]
	if sensitiveZoneSource != null:
		sensitiveZone = load(sensitiveZoneSource).new()
		sensitiveZone.setBodypart(self)
