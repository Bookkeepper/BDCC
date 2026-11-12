#hidden_api
const FoxLibAudioManager = preload("res://Modules/FoxLib/Internal/Audio/FoxLibAudioManager.gd")

static func playSFX(foxAudio):
	FoxLibAudioManager.playSFX(foxAudio)

static func playAudioSampleAsSFX(audioSample, pitchDiff=0.0):
	FoxLibAudioManager.playAudioSampleAsSFX(audioSample, pitchDiff)

static func playNamedSFX(foxSoundId):
	FoxLibAudioManager.playNamedSFX(foxSoundId)

static func playBGM(foxSound):
	FoxLibAudioManager.playNamedSFX(foxSound)

static func playNamedBGM(foxSoundId):
	FoxLibAudioManager.playNamedBGM(foxSoundId)

static func getBGMId():
	return FoxLibAudioManager.getBGMId()

static func setVolume(audioVolume):
	FoxLibAudioManager.setVolume(audioVolume)

static func getAllAudioIDs():
	return FoxLibAudioManager.getAllAudioIDs()

static func getCurrentBGM():
	return FoxLibAudioManager.getCurrentBGM()

static func getFoxAudio(foxAudioId):
	return FoxLibAudioManager.getFoxAudio(foxAudioId)
