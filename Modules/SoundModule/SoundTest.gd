extends SceneBase

const manager = preload("res://Modules/FoxLib/Internal/Audio/FoxLibAudioManager.gd")
const Globals = preload("res://FoxLib/Globals.gd")
var flam = Globals.of(manager.FLAMStatics)
var Smod = GlobalRegistry.getModule("SoundModule")
var testAudio = manager.getFoxAudio("TestAudio")
var variance

func _init():
	sceneID = "soundTest"


func _run():
	
	variance = Smod.pitchVarianceOption/100
	
	if(state == ""):
		saynn("Debug sound test")
		addButton("Cancel", "Go back", "endthescene")
		addButton("Voice sounds","See all sounds from voice packs","voice")
		addButton("VFX sounds","See all sounds effects","effect")
		addButton("BGM sounds","See all BGM sounds","BGM")
		
	if(state == "effect"):
		addButton("Back", "Go back", "")
		var _things = manager.getAllAudioIDs()
		for entry in _things:
			if(entry == "" || entry == null || entry.begins_with("SoundModule:Sound") || entry.begins_with("SoundModule:BGM")):
				continue
			var dummy = entry.substr(entry.find(":")+1,-1)
			var disp = dummy.trim_prefix("Effect")
			addButton(disp, dummy, entry, ["play"])
		
		
	if(state == "voice"):
		addButton("Back", "Go back", "")
		var _things = manager.getAllAudioIDs()
		for entry in _things:
			if(entry == "" || entry == null || entry.begins_with("SoundModule:Effect") || entry.begins_with("SoundModule:BGM")):
				continue
			var dummy = entry.substr(entry.find(":")+1,-1)
			var disp = dummy.trim_prefix("Sound")
			addButton(disp, dummy, entry, ["play"])
			
	if(state == "BGM"):
		addButton("Back", "Go back", "")
		addButton("Stop","Stop","playerstop")
		var _things = manager.getAllAudioIDs()
		for entry in _things:
			if(entry == "" || entry == null || entry.begins_with("SoundModule:Sound") || entry.begins_with("SoundModule:Effect") || entry.begins_with("FoxLib:Test")):
				continue
			var dummy = entry.substr(entry.find(":")+1,-1)
			var disp = dummy.trim_prefix("BGM")
			addButton(disp, dummy, entry, ["playBGM"])
		

func _react(_action: String, _args):

	if(_action=="playerstop"):
		manager.playNamedBGM(null)
		flam.bgmPlayer.stop()
		print("[SoundMod] Stopped all BGM")
		return
	if(_args.empty()):
		setState(_action)
	elif(manager.getAllAudioIDs().has(_action) && _args[0]=="playBGM"):
		var wat = manager.getFoxAudio(_action)
		addMessage("Audio object:  " + wat.getId())
		addMessage("Author:  " + wat.getAuthor())
		manager.playBGM(manager.getFoxAudio(_action))
		return
	elif(manager.getAllAudioIDs().has(_action)):
		var wat = manager.getFoxAudio(_action)
		addMessage("Audio object:  " + wat.getId())
		addMessage("Author:  " + wat.getAuthor())
		manager.playSFX(wat, 0.0, 1.0, "voice")
		return
		
	
	if(_action == "endthescene"):
		endScene()
		return
	

