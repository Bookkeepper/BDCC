extends TranslatorBase

const Globals = preload("res://FoxLib/Globals.gd")

var foxLibModule = null

func setup():
	id = "FoxLibTranslatorHook"
	foxLibModule = Globals.ofModule("FoxLib")

func translate(_targetLanguage, _inputText):
	if foxLibModule.debugTranslationRequests:
		Log.print("TRANSLATE: " + _inputText)
	if foxLibModule.preventTranslationRequests:
		return _inputText
	return null

