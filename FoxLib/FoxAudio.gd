#class_name FoxAudio
#public_api

const FoxLibAudioManager = preload("res://Modules/FoxLib/Internal/Audio/FoxLibAudioManager.gd")

var id = ""
var author = "Unknown"
var audioPaths = []
var loadedAudio = null
var pitchVariance = 0.0
var defaultChannel = "default"

func getId():
	return self.id

func getAuthor():
	return self.author

func setAuthor(_author):
	self.author = _author
	return self

func addAudioPath(audioPath):
	if not FoxLibAudioManager.isValidAudioPath(audioPath):
		return self
	audioPaths.append(audioPath)
	if loadedAudio != null:
		var audio = FoxLibAudioManager.loadAsAudioStream(audioPath)
		if audio != null and (audio is AudioStream):
			loadedAudio.append(audio)
	return self

func setPitchVariance(_pitchVariance):
	self.pitchVariance = _pitchVariance
	return self

func setDefaultChannel(_defaultChannel):
	self.defaultChannel = _defaultChannel
	return self

func getLoadedAudio():
	var loadedAudioTmp = self.getLoadedAudios()
	if loadedAudioTmp.empty():
		return null
	return loadedAudioTmp.pick_random()

func getLoadedAudios():
	if self.loadedAudio != null:
		return self.loadedAudio
	var loadedAudioTmp = []
	for audioPath in audioPaths:
		var audio = FoxLibAudioManager.loadAsAudioStream(audioPath)
		if audio != null and (audio is AudioStream):
			loadedAudioTmp.append(audio)
	self.loadedAudio = loadedAudioTmp
	return loadedAudioTmp

func playAsSFX(pitchDiff=null, volume=null, channel=null):
	FoxLibAudioManager.playSFX(self, pitchDiff, volume, channel)

func playAsBGM():
	FoxLibAudioManager.playBGM(self)

static func stopBGM():
	FoxLibAudioManager.playBGM(null)

static func getCurrentBGM():
	return FoxLibAudioManager.getCurrentBGM()

static func getFoxAudio(foxAudioId):
	if foxAudioId == null or foxAudioId == "":
		return null
	return FoxLibAudioManager.getFoxAudio(foxAudioId)

static func playNamedAsSFX(foxAudioId):
	var foxAudio = getFoxAudio(foxAudioId)
	if foxAudio != null:
		foxAudio.playAsSFX()

static func playNamedAsBGM(foxAudioId):
	var foxAudio = getFoxAudio(foxAudioId)
	if foxAudio != null:
		foxAudio.playAsBGM()
	else:
		FoxLibAudioManager.playBGM(null)

static func playAudioSampleAsSFX(audioSample, pitchDiff=0.0):
	FoxLibAudioManager.playAudioSampleAsSFX(audioSample, pitchDiff)

static func getAllAudioIDs():
	return FoxLibAudioManager.getAllAudioIDs()

static func setChannelVolumeMultiplier(channel, multiplier=1.0):
	return FoxLibAudioManager.setChannelVolumeMultiplier(channel, multiplier)
