extends GameExtender

const manager = preload("res://Modules/FoxLib/Internal/Audio/FoxLibAudioManager.gd")
const Globals = preload("res://FoxLib/Globals.gd")
const fui = preload("res://FoxLib/FoxUIManager.gd")
const FoxAudio = preload("res://FoxLib/FoxAudio.gd")

var Smod = GlobalRegistry.getModule("SoundModule")
var wasScene:SceneBase
var inSexEngine:bool
var pack
var playedThisUpdate = false
var played2ThisUpdate = false
var played3ThisUpdate = false
var variance = Smod.pitchVarianceOption
var flam = Globals.of(manager.FLAMStatics)

var soundOption = [Smod.Osoundoption, Smod.Psoundoption, Smod.Tsoundoption, Smod.Ssoundoption]
var theType = ["orgasm", "pleasure", "tease", "struggle"]

# this dictionary determines what sound applies to which sexActivity ID
# the sound name is determined by the name of the subfolder the .mp3 was imported from
# the sexActivity ID is found in its script file, if you are reading this I assume you know how to find that
var acts = {
	"DomPutBreastPumpOnSub":"sextoy",
	"DomPutPenisPumpOnSub":"sextoy",
	"DomRidingSubAnal":"plaps",
	"DomRidingSubVaginal":"plaps",
	"SexVaginalOnAllFours":"plaps",
	"SexAnalOnAllFours":"plaps",
	"ThreeDDS_DP":"plaps2",
	"ThreeDDS_SpitroastAnal":"plaps2",
	"ThreeDDS_SpitroastVag":"plaps2",
	"ThreeDDS_Train":"plaps",
	"ThreeDSS_Buttstack":"plaps",
	"SixtyNine":"oral",
	"SexOral":"oral",
	"DomOralSexOnSub":"oral",
	"SexPawjobMutual":"handjob",
	"SexPawjob":"handjob",
	"DomRimSub":"oral",
	"HK_Hypnotize":"hum",
	"Tribadism":"grind",
	"SexFleshlight":"plaps",
	"SexRimming":"oral",

	"DomBondage":"chain",
	"DomLeashesSub":"chain",
	"Spanking":"spank",
	"BeatingUpWhenAngry":"slap",
	"DomUndressActions":"clothes",
	"DomUndressesSub":"clothes",
	"SubUndressActions":"clothes",
	
}

#var _eep = GlobalRegistry.getSexActivityReferences() # if you want a handy list of all sexActivity IDs

var output:String = ""
var lastOutput:String = ""

func _init():
	id = "SoundPlayer"
	# triggers sounds in response to player stats
		
func register(_GES:GameExtenderSystem):
	_GES.register(self, ExtendGame.pcUpdateNonBattleEffects) # this will run SoundPlayer every time the player's status effects are checked

func pcUpdateNonBattleEffects(_pc:Player):
	if(flam.sfxPlayer1.sfxChannel == null):
		flam.sfxPlayer1.sfxChannel = "voice"
		flam.sfxPlayer2.sfxChannel = "effect"
		flam.sfxPlayer3.sfxChannel = "background"
	
	playedThisUpdate = false # sound plays only once, no infinite looping
	played2ThisUpdate = false
	played3ThisUpdate = false
	var _currentScene = fui.getCurrentScene() #get the current Godot scene

	if(GM.main.sceneStack.size() > 0): #wait until the game is loaded
		wasScene = GM.main.getCurrentScene() #get the current BDCC scene
	if not is_instance_valid(wasScene):
		return #check if scene was already deleted (can happen when save/load occurs)
	var _floop = Smod.voicepackoption #should retrieve the selected voicepack from options menu (set by FoxLib)
	pack = _floop.substr(_floop.find("_")+1,-1)
	variance = Smod.pitchVarianceOption/100

	#are we in a dynamic sex scene?
	if(wasScene.sceneID == "GenericSexScene"):
		if(wasScene.sexEngine.isInvolved("pc")): #if pc is not involved, we do nothing (because we can only trigger via pcUpdateNonBattleEffects)
			inSexEngine = true 
			var engine:SexEngine = wasScene.sexEngine #get the current sexengine
			output = engine.getFinalOutput() #get the text passage shown on screen
			if(output == lastOutput): #if text passage did not change, do nothing
				return #this means we are in a sub-menu and we didn't actually do a turn
			handleSexEngine(engine,engine.activities)
			if(engine.activities.empty()): #quit if no activities started
				return
			if(engine.hasSexEnded()): 
				inSexEngine = false #check if sex ended, i.e. we are on the results screen
			var meInfo:SexInfoBase = wasScene.sexEngine.getCharInfo("pc")
			if(meInfo.didJustCame()):
				play_voice("orgasm")
			if(meInfo.hadStim ):
				play_voice("pleasure")

			lastOutput = output
		else:
			return
			
	#are we struggling?
	if(wasScene.sceneID == "StrugglingScene"):
		if(wasScene.state == "startStruggleAgainst"):
			play_voice("struggle")
			
	#did the Lust stat change?
	if(!GM.pc.is_connected("lust_changed",self,"lustSound")):
		GM.pc.connect("lust_changed",self,"lustSound")
#	if(!GM.pc.is_connected("stamina_changed",self,"on_stamina")): # haven't come up with any use for this
#		GM.pc.connect("stamina_changed",self,"on_stamina")
#	if(!GM.pc.is_connected("pain_changed",self,"ishurted")): # Hypnokink module connects to this signal and they will start fighting over it
#		GM.pc.connect("pain_changed",self,"ishurted")

	#detect stuff from hypnokink module
	if(GM.pc.hasEffect(StatusEffect.UnderHypnosis) or GM.pc.hasEffect(StatusEffect.HypnoVisorActive)):
		var sound = manager.getFoxAudio("SoundModule:Effecthum")
		manager.playSFX(sound, variance, 2.0, "background")

#sounds in response to player lust stat
func lustSound(lust, initialLust):
	if(initialLust-lust == GM.pc.lustThreshold()):
		play_voice("orgasm")
	elif(GM.pc.getArousal() != 0 || inSexEngine):
		play_voice("pleasure")
	elif(lust > initialLust):
		play_voice("tease")

#sounds that happen during dynamic sex
func handleSexEngine(_engine:SexEngine, _activities):
	var peeps = _engine.getCharIDList()
	var tagsByChar:Dictionary = {}
	var tags = []
	#check for certain activities that have a sound to go with
	for _activity in _activities:
		if(_activity.id == "DomUndressActions" or _activity.id == "SubUndressActions" or _activity.id == "DomUndressesSub"):
			if(Smod.clothOption): #note: if sub resists and succeeds, the activity is removed and no sound is triggered
				var _to_play = acts[_activity.id]
				play_effect(_engine, _to_play)
		elif(_activity.id == "DomLeashesSub" && Smod.chainOption):
			if(_activity.state == ""): #check if this is the start of leashing to avoid playing every turn leash is active
				var _to_play = acts[_activity.id]
				play_effect(_engine, _to_play)
		elif(_activity.id == "DomBondage" && Smod.chainOption):
			var _to_play = acts[_activity.id] #same as undress, resisting can cause no sound
			play_effect(_engine, _to_play)
		elif(_activity.id == "Spanking" && Smod.spankOption):
			if(not _activity.has_method("getAssDescriptionAfterImpact")):
				printerr("[SoundMod] Error parsing dynamic sex event:"+_activity.id)
			if(_activity.didSpankThisTime or _activity.didBigSpankThisTime):#only play sound when spank happens
				var _to_play = acts[_activity.id]
				play_effect(_engine, _to_play)
		elif(_activity.id == "BeatingUpWhenAngry" && Smod.punchOption):
			var _to_play = acts[_activity.id]
			play_effect(_engine, _to_play)
	#check activity tags to see if associated background sound should play
	if(not Smod.plapOption):
		return #quit if these sounds are turned off in options
	else:
		for _activity in _activities:
			tags = []
			var back = acts.get(_activity.id)
			for chID in peeps:
				var intag = []
				for ii in range(SexActivityTag.getAllStrings().size()):
					if(_engine.hasTag(chID, ii)): #get tags for participant
						tags.append(ii)
						intag.append(ii)
				tagsByChar.get_or_add(chID,intag)
			if(skipPlapping(_engine, tagsByChar)):
				break #quit if there's a cumshot
			if(back == "plaps" and tags.has(4) and (tags.has(11) or tags.has(12)) and (_activity.state != "aftercumminginside") and _activity.state != "knotting"):
				play_background(_engine,"plaps")
				continue
			if(back == "oral" and tags.has(5)):
				play_background(_engine,"oral") #some sexActivities seem to not respect 'Mouthused' causing sounds to play early
				# tonguefucking state in DomOralOnSub lacks MouthUsed
				continue
			if(back == "grind" and tags.has(1)):
				play_background(_engine,"grind")
				continue
				
			if(not back in ["plaps","sextoy","oral","grind","chain","spank","slap","clothes","hum","cum","squirt"]): # catch any custom sound effects not in the list of sounds that are provided by default
				if(acts.has(_activity.id) && manager.getAllAudioIDs().has("SoundModule:Effect"+acts[_activity.id])): # first make sure there is a sound to play, then play it
					var _to_play = acts[_activity.id]
					play_effect(_engine, _to_play)
				
			if(back == null && _engine.activities.size() > 1): #fallback if none of the previous conditions were caught
				var activity = _engine.currentLastActivityID #get the current activity
				var test:SexActivityBase 
				if _engine.activities.size() >= 1:
					test = _engine.getActivityWithUniqueID(activity-2) #check activity before current one
				else:
					test = _engine.activities[0]
				if(test != null && (checkTag(_engine, tagsByChar, 4) or checkTag(_engine, tagsByChar, 5) )):
					play_background(_engine,acts[test.id]) #check if the previous activity is ongoing and play that sound if yes
					continue
	
	if(Smod.cumEffect):
		for pers in peeps: #search all participants 
			var theInfo = _engine.getCharInfo(pers)
			if(theInfo.didJustCame()): #check if anyone orgasmed
				cum(GM.main.getCharacter(pers))
				yield(wasScene.get_tree().create_timer(rand_range(0.5,1.0)),"timeout")
				cum(GM.main.getCharacter(pers))
				yield(wasScene.get_tree().create_timer(1.5),"timeout")
				cum(GM.main.getCharacter(pers))
		
		
# check activity tags list for a specific one
func checkTag(_engine, _tagDict, tag:int):
	for item in _tagDict:
		if _tagDict.get(item).has(tag):
			return true
	return false

# workaround to skip plapping noises when the person penetrating cums
func skipPlapping(_engine, _tagDict):
	for item in _tagDict:
		if _engine.getCharInfo(item).didJustCame() && _tagDict.get(item).has(4):
			return true
	return false

func play_voice(type:String):
	var sound
	if(soundOption[theType.find(type)] && !playedThisUpdate):
		if(GM.pc.hasEffect(StatusEffect.Gagged) && Smod.gagsoundoption):
			sound = manager.getFoxAudio("SoundModule:Sound"+type+"_gagged"+pack) #note that this name was determined at import; see the Module.gd
		else:
			sound = manager.getFoxAudio("SoundModule:Sound" +type+pack)
		if sound == null:
			Log.printerr("[SoundMod] Failed to locate FoxAudio SoundModule: " + pack)
		else:
			manager.playSFX(sound, variance, 1.0, "voice")
			Log.print("[SoundMod] Playing Audio Object: " + sound.getId())
			playedThisUpdate = true
	
#play background sounds on audioplayer3
func play_background(_engine:SexEngine, _tag):
	var sound
	sound = manager.getFoxAudio("SoundModule:Effect"+_tag)
	if sound == null: 
		Log.printerr("[SoundMod] Failed to locate FoxAudio SoundModule: " + pack)
	if(not _tag in ["plaps", "grind", "oral"]):
		Log.printerr("[SoundMod] tried to play "+ sound +" on wrong channel, why????")
		return
	elif(not played3ThisUpdate):
		manager.playSFX(sound, variance, 1.0, "background")
		for x in [1,2,3,4]:
			yield(fui.getCurrentScene().get_tree().create_timer(0.5), "timeout")
			manager.playSFX(sound, variance, 1.0, "background")
			played3ThisUpdate = true
		Log.print("[SoundMod] Playing Audio Object: " + sound.getId())

#play sound effects on audioplayer2
func play_effect(_engine:SexEngine, _activity):
	var sound
	sound = manager.getFoxAudio("SoundModule:Effect"+_activity)
	if sound == null: 
		Log.printerr("[SoundMod] Failed to locate FoxAudio SoundModule: " + pack)
	elif(not played2ThisUpdate):
		manager.playSFX(sound, variance, 1.0, "effect")
		played2ThisUpdate = true
		Log.print("[SoundMod] Playing Audio Object: " + sound.getId())
			

#handle npc cumming and what sound is for which genitals
func cum(_ch):
	var sound = manager.getFoxAudio("SoundModule:Effectcum")
	if(_ch.hasBodypart(BodypartSlot.Vagina) and not _ch.hasBodypart(BodypartSlot.Penis)):
		if(Smod.squirtEffect):
			sound = manager.getFoxAudio("SoundModule:Effectsquirt")
	if sound == null:
		Log.printerr("[SoundMod] Failed to locate FoxAudio SoundModule: " + pack)
	else:
		manager.playSFX(sound, variance, 1.0, "effect")
		Log.print("[SoundMod] Playing Audio Object: " + sound.getId())
		played2ThisUpdate = true
