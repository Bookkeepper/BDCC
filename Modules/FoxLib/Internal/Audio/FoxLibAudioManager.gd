extends GameExtender
#class_name FoxLibAudioManager

const Globals = preload("res://FoxLib/Globals.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const GDScriptAudioImport = preload("res://Modules/FoxLib/External/GDScriptAudioImport.gd")

class FLAMSfxPlayer:
	var sfxPlayer = null
	var sfxVolumeMult = 1.0
	var sfxChannel = null
	
	func clearSfxPlayer():
		FoxUIManager.deParent(sfxPlayer)
		sfxPlayer = null
		sfxChannel = null
		sfxVolumeMult = 1.0
	
	func injectSfxPlayer(flam, currentScene):
		clearSfxPlayer()
		sfxPlayer = AudioStreamPlayer.new()
		sfxPlayer.volume_db = flam.volume_db
		currentScene.add_child(sfxPlayer)
		sfxPlayer.connect("finished", self, "onSfxFinished")
	
	func updateSfxPlayer(flam):
		if sfxPlayer != null:
			sfxPlayer.volume_db = sfxVolumeMult * flam.volume_db
	
	func playSample(flam, audioSample, pitchDiff, _sfxVolumeMult):
		if sfxPlayer == null:
			return
		sfxVolumeMult = _sfxVolumeMult
		if sfxPlayer.is_playing():
			sfxPlayer.stop()
		if audioSample != null:
			updateSfxPlayer(flam)
			sfxPlayer.pitch_scale = 1.0 + pitchDiff
			sfxPlayer.set_stream(audioSample)
			sfxPlayer.play()
		else:
			sfxPlayer.pitch_scale = 1.0
	
	func onSfxFinished():
		sfxChannel = null

class FLAMStatics:
	var foxAudios = {}
	var sfxChVolumeMult = {}
	var possible_values = [""]
	var volume_db = 0.0
	var sfxPlayer1 = FLAMSfxPlayer.new()
	var sfxPlayer2 = FLAMSfxPlayer.new()
	var sfxPlayer3 = FLAMSfxPlayer.new()
	var bgmPlayer = null
	var bgm = null
	
	func onBgmFinished():
		if self.bgm == null or self.bgmPlayer == null:
			return
		var nextAudioSample = self.bgm.getLoadedAudio()
		if nextAudioSample != null:
			self.bgmPlayer.set_stream(nextAudioSample)
			self.bgmPlayer.play()

func _init():
	id = "FoxLibAudioManager"

func register(_GES:GameExtenderSystem):
	_GES.register(self, ExtendGame.saveLoadData)

func saveData():
	var data = {}
	FoxUIManager.callOrQueueConsumerOnMainThread(self, "saveDataMT", data)
	return data

func saveDataMT(data):
	var flam = Globals.of(FLAMStatics)
	if flam.bgm != null:
		data["bgm"] = flam.bgm.id
	else:
		data["bgm"] = ""

func loadData(_data):
	if _data == null:
		playBGM(null)
	else:
		playBGM(getFoxAudio(SAVE.loadVar(_data, "bgm", "")))

static func isValidAudioPath(path):
	if not (path.begins_with("res://") or path.begins_with("user://")):
		return false
	if path.ends_with(".wav"):
		return true
	if path.ends_with(".ogg"):
		return true
	if path.ends_with(".mp3"):
		return true
	return false

static func loadAsAudioStream(path):
	if not isValidAudioPath(path):
		return null
	# Read imported audio data if available to load with proper settings
	if path.begins_with("res://") and ResourceLoader.exists(path):
		var audio = ResourceLoader.load(path)
		if path.ends_with(".ogg") or path.ends_with(".mp3"):
			audio.loop = false
		if audio != null and audio.get_length() > 0.0:
			return audio
	var stream = GDScriptAudioImport.loadfile(path)
	if stream != null and stream.get_length() > 0.0:
		if path.ends_with(".wav"):
			stream.set_loop_mode(0)
			stream.set_loop_begin(0)
		else:
			stream.loop = false
			stream.loop_offset = 0.0
		return stream
	Log.error("[FoxLib] Invalid audio data: " + path)
	return null

static func registerFoxAudio(foxAudio):
	if foxAudio == null:
		return
	var id = foxAudio.getId()
	if id == null or id == "":
		return
	var flam = Globals.of(FLAMStatics)
	flam.foxAudios[id] = foxAudio
	flam.possible_values.append(id)

static func installOnScene():
	var flam = Globals.of(FLAMStatics)
	# De-initialize
	flam.sfxPlayer1.clearSfxPlayer()
	flam.sfxPlayer2.clearSfxPlayer()
	flam.sfxPlayer3.clearSfxPlayer()
	FoxUIManager.deParent(flam.bgmPlayer)
	flam.bgmPlayer = null
	flam.bgm = null
	# Initialize
	var currentScene = FoxUIManager.getCurrentScene()
	flam.sfxPlayer1.injectSfxPlayer(flam, currentScene)
	flam.sfxPlayer2.injectSfxPlayer(flam, currentScene)
	flam.sfxPlayer3.injectSfxPlayer(flam, currentScene)
	var bgmPlayer = AudioStreamPlayer.new()
	bgmPlayer.volume_db = flam.volume_db
	currentScene.add_child(bgmPlayer)
	flam.bgmPlayer = bgmPlayer
	bgmPlayer.connect("finished", flam, "onBgmFinished")

static func grabSfxPlayer(channel):
	var flam = Globals.of(FLAMStatics)
	# First check if we already have a sound using that channel.
	if flam.sfxPlayer1.sfxChannel == channel:
		return flam.sfxPlayer1
	if flam.sfxPlayer2.sfxChannel == channel:
		return flam.sfxPlayer2
	if flam.sfxPlayer3.sfxChannel == channel:
		return flam.sfxPlayer3
	# Next check if any free channel is available
	if flam.sfxPlayer1.sfxChannel == null:
		return flam.sfxPlayer1
	if flam.sfxPlayer2.sfxChannel == null:
		return flam.sfxPlayer2
	if flam.sfxPlayer3.sfxChannel == null:
		return flam.sfxPlayer3
	# If everything fails, no free channel is available
	return null

static func playSFX(foxAudio, pitchDiff=null, volumeMult=null, channel=null):
	if pitchDiff == null:
		pitchDiff = 0.0
		var pitchVariance = foxAudio.pitchVariance
		if pitchVariance > 0.5:
			pitchDiff = rand_range(-0.5, 0.5)
		elif pitchVariance > 0.0:
			pitchDiff = rand_range(-pitchVariance, pitchVariance)
	if channel == null:
		channel = foxAudio.defaultChannel
	if channel == null:
		channel = "default"
	if volumeMult == null:
		volumeMult = Globals.of(FLAMStatics).sfxChVolumeMult.get(channel)
	if volumeMult == null:
		volumeMult = 1.0
	playAudioSampleAsSFX(foxAudio.getLoadedAudio(), pitchDiff, volumeMult, channel)

static func playAudioSampleAsSFX(audioSample, pitchDiff=0.0, volumeMult=1.0, channel="default"):
	if volumeMult <= 0.0:
		audioSample = null
	if audioSample != null and ((audioSample is AudioStreamOGGVorbis) or (audioSample is AudioStreamMP3)) and audioSample.loop:
		# Disable looping for incomming audio samples as we do not support looping audio properly.
		audioSample.loop = false
	if pitchDiff < -0.5:
		pitchDiff = -0.5
	elif pitchDiff > 0.5:
		pitchDiff = 0.5
	var sfxPlayer = grabSfxPlayer(channel)
	if sfxPlayer == null:
		return
	var flam = Globals.of(FLAMStatics)
	sfxPlayer.playSample(flam, audioSample, pitchDiff, volumeMult)

static func playNamedSFX(foxSoundId):
	if foxSoundId == null or foxSoundId == "":
		return
	var flam = Globals.of(FLAMStatics)
	var foxAudio = flam.foxAudios.get(foxSoundId)
	if foxAudio != null:
		playSFX(foxAudio)

static func playBGM(foxSound):
	var flam = Globals.of(FLAMStatics)
	if flam.bgmPlayer == null or not is_instance_valid(flam.bgmPlayer):
		return
	if flam.bgm == foxSound and flam.bgmPlayer.is_playing():
		# Skip switching or resetting track if the same audio is being used
		return
	flam.bgm = foxSound
	# Stop call will call the looping code which will play the current sample
	if flam.bgmPlayer.is_playing():
		flam.bgmPlayer.stop()
	elif foxSound != null:
		var nextAudioSample = foxSound.getLoadedAudio()
		if nextAudioSample != null:
			flam.bgmPlayer.set_stream(nextAudioSample)
			flam.bgmPlayer.play()

static func playNamedBGM(foxSoundId):
	if foxSoundId == null or foxSoundId == "":
		playBGM(null)
		return
	var flam = Globals.of(FLAMStatics)
	var foxAudio = flam.foxAudios.get(foxSoundId)
	if foxAudio != null:
		playBGM(foxAudio)

static func getBGMId():
	var flam = Globals.of(FLAMStatics)
	if flam.bgm == null:
		return ""
	return flam.bgm.getId()

static func setVolume(audioVolume):
	var volume_db = 0.0
	if audioVolume <= 0.001:
		volume_db = -80.0
	else:
		volume_db = log(audioVolume / 100.0) * 8.6858896380650365530225783783321
	var flam = Globals.of(FLAMStatics)
	flam.volume_db = volume_db
	flam.sfxPlayer1.updateSfxPlayer(flam)
	flam.sfxPlayer2.updateSfxPlayer(flam)
	flam.sfxPlayer3.updateSfxPlayer(flam)
	if flam.bgmPlayer != null:
		flam.bgmPlayer.volume_db = volume_db

static func getAllAudioIDs():
	return Globals.of(FLAMStatics).possible_values

static func getCurrentBGM():
	return Globals.of(FLAMStatics).bgm

static func getFoxAudio(foxAudioId):
	if foxAudioId == null or foxAudioId == "":
		return null
	return Globals.of(FLAMStatics).foxAudios.get(foxAudioId)

static func setChannelVolumeMultiplier(channel, multiplier=1.0):
	Globals.of(FLAMStatics).sfxChVolumeMult[channel] = multiplier
