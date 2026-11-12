const Globals = preload("res://FoxLib/Globals.gd")
const FoxLibTranslatorHook = preload("res://Modules/FoxLib/Hooks/Events/FoxLibTranslatorHook.gd")

static func checkAutoTranslateHook():
	if AutoTranslation.translators.size() == 0:
		return
	var translatorHook = Globals.of(FoxLibTranslatorHook)
	if not AutoTranslation.translators.has(translatorHook):
		AutoTranslation.translators.insert(0, translatorHook)

