extends EventBase

const manager = preload("res://Modules/FoxLib/Internal/Audio/FoxLibAudioManager.gd")
const Globals = preload("res://FoxLib/Globals.gd")
const fui = preload("res://FoxLib/FoxUIManager.gd")

var BGMDB = load("res://Modules/SoundModule/SoundModBGMDB.gd")
var Smod = GlobalRegistry.getModule("SoundModule")
var flam = Globals.of(manager.FLAMStatics)
var database = Globals.of(BGMDB)

var oldBGM = null

var fadeIn:Tween = Tween.new()
var fadeOut:Tween = Tween.new()
export var transition_duration = 0.5
export var transition_type = 1 # TRANS_SINE


func _init():
	id = "BGM"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom)
	
func _ready():
	oldBGM = manager.getCurrentBGM()

func run(_triggerID, _args):
	if(not Smod.BGMOption):
		flam.bgmPlayer.stop()
		flam.bgm = null
		return
	
	var location = GM.pc.getLocation()
	var ref = GM.world.getRoomByID(location)
	var currentScene = fui.getCurrentScene() #get the current Godot scene
	
	var name = database.getBGM(ref)
	
	if(name==""):
		fade_out(flam.bgmPlayer)
		flam.bgmPlayer.stop()
		print("[SoundMod]: BGM stopped - "+ "" if(typeof(oldBGM) == TYPE_NIL) else oldBGM.id)
		oldBGM = null
	if(name == null):
		return
	var newBGM = manager.getFoxAudio("SoundModule:"+name)
	if(newBGM == null):
		return
	if(("" if(typeof(oldBGM) == TYPE_NIL) else oldBGM.id) == newBGM.id):
		return
	else:
		currentScene.add_child(fadeIn)
		currentScene.add_child(fadeOut)
	if(typeof(oldBGM) == TYPE_NIL):
		pass
#		addMessage("Nothing to fade out")
	else:
#		print("[SoundMod]: Fade out "+oldBGM.id)
		fade_out(flam.bgmPlayer)
		yield(fadeOut,"tween_completed")
	var sound = manager.getFoxAudio("SoundModule:"+name)
	if(sound == null):
		return
	manager.setVolume(0)
	manager.playBGM(manager.getFoxAudio("SoundModule:"+name))
	fade_in(flam.bgmPlayer)
	yield(fadeIn,"tween_completed")
	manager.setVolume(Smod.BGMVolume)
	print("[SoundMod]: Play new BGM: "+newBGM.id)
	oldBGM = manager.getCurrentBGM()
#	fade_in(ready)


func on_player_stopped():
	pass

func fade_out(stream_player):
	# tween music volume down to 0
	fadeOut.interpolate_property(stream_player, "volume_db", null, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	fadeOut.start()
	# when the tween ends, the music will be stopped

func fade_in(stream_player):
	fadeIn.interpolate_property(stream_player, "volume_db", -80, get_volume(Smod.BGMVolume), transition_duration, transition_type, Tween.EASE_IN, 0)
	fadeIn.start()

func getPriority():
	return 0
	
func get_volume(_vol):
	var v = 0.0
	if _vol <= 0.001:
		v = -80.0
	else:
		v = log(_vol / 100.0) * 8.6858896380650365530225783783321
	return v


