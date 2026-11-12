extends "res://FoxLib/FoxModule.gd"

const FoxLibAudioManager = preload("res://Modules/FoxLib/Internal/FoxLibAudioManager.gd")
const FoxLibModInitHelper = preload("res://Modules/FoxLib/Internal/FoxLibModInitHelper.gd")
const popupwindow = preload("res://Modules/SoundModule/BGM_picker_popup.tscn")
const version = "1.3.5"
const foxlibversion = "0.10.7"

var BGMDB = load("res://Modules/SoundModule/SoundModBGMDB.gd")

var sound
var EffectSound
var AmSound
var soundDir

var Psoundoption:bool = true
var Osoundoption:bool = true
var Tsoundoption:bool = true
var Ssoundoption:bool = true
var gagsoundoption:bool = true
var pitchVarianceOption:float
var HypnoOption:bool = false
var cumEffect:bool = false
var squirtEffect:bool = false
var spankOption:bool = false
var punchOption:bool = false
var clothOption:bool = false
var chainOption:bool = false
var plapOption:bool = false
var audiotest:bool = true
var showHelpPopup = true
var BGMOption:bool = true
var BGMVolume:int = 30
var voicepackoption = ""
var packReq = [
	"sounds_orgasm",
	"sounds_orgasm_gagged",
	"sounds_pleasure",
	"sounds_pleasure_gagged",
	"sounds_struggle",
	"sounds_struggle_gagged",
	"sounds_tease",
	"sounds_tease_gagged",
]
var effectReq = [
	"effects_chain",
	"effects_clothes",
	"effects_cum",
	"effects_grind",
	"effects_handjob",
	"effects_hum",
	"effects_oral",
	"effects_plaps",
#	"effects_plaps2",
	"effects_sextoy",
	"effects_slap",
	"effects_spank",
	"effects_squirt",
]
var folders = []

var helpString:String = ""
var validNames = ["SoundMod_Effects", "SoundMod_pack_", "SoundMod_BGM", "SoundMod_"]

var smDialog = AcceptDialog.new() # message window that will show info to the user

func folderCheck(_names:Array):
	var result = []
	for each in _names:
		if(each.begins_with("SoundMod_")):
			result.append(true)
		else:
			result.append(false)
	return result
	

func _init():
	id = "SoundModule"
	author = "bringlebangul"	
	scenes = ["res://Modules/SoundModule/SoundTest.gd"]
	gameExtenders = [
		"res://Modules/SoundModule/PlaySounds.gd",
	]
	events = [
		"res://Modules/SoundModule/DebugEvent.gd",
		"res://Modules/SoundModule/BGMsystem.gd",
	]
	perks = [
#		"res://Modules/SoundModule/AudioTrigger.gd",
	]
	
	soundDir =  GlobalRegistry.getModsFolder()+"/"
	var dir = Directory.new()
	#search for folders in this order: user://mods, user://soundmod
	var _err = dir.open(GlobalRegistry.getModsFolder())
	folders = sub_dir(GlobalRegistry.getModsFolder())
	var _ok = folderCheck(folders)
	print("[SoundMod] Looking for audio files in "+ProjectSettings.globalize_path(soundDir)+"...")
	helpString += "Looking for audio files in "+ProjectSettings.globalize_path(soundDir)+"...\n"
	if(folders.empty() || not _ok.has(true)):
		soundDir = GlobalRegistry.getModsFolder().rstrip("mods").rstrip("BDCCMods").plus_file("soundmod")+"/"
		print("[SoundMod] Looking for audio files in "+ProjectSettings.globalize_path(soundDir)+"...")
		helpString += "Looking for audio files in "+ProjectSettings.globalize_path(soundDir)+"...\n"
		dir.open(soundDir)
		folders = sub_dir(soundDir)
		_ok = folderCheck(folders)
	if(folders.empty()): # if nothing was found at either location, let the user know
		printerr("[SoundMod] No audio files located. Check you have sounds downloaded and in the right location. Folder names have changed as of SoundMod v1.3.0, rename them so they all start with \"SoundMod_\".")
		helpString += "No audio files located. Check you have sounds downloaded and placed in\n\n" + (ProjectSettings.globalize_path(GlobalRegistry.getModsFolder()))+"\n\n or in \n\n"+ ProjectSettings.globalize_path(GlobalRegistry.getModsFolder().rstrip("mods").rstrip("BDCCMods").plus_file("soundmod")) + "/\n\nFolder names have changed as of SoundMod v1.3.0, if you previously downloaded them rename them so they all start with \"SoundMod_\".\n"
	else:
		print("[SoundMod] Located what looks like audio files in "+soundDir+", trying to import...")
		helpString += "Located what looks like audio files in "+soundDir+", trying to import...\n\n"
	for thing in folders:
		var _todo = soundDir+thing
		if(thing in sub_dir(_todo)):
			Log.printerr("[SoundMod] Nested folder was found, plz bonk whoever wrote your unzip utility")
			if(fix_nested_folder(_todo, soundDir+thing+"/"+thing)==0):
				helpString = "\nFound an extra nested folder, but was able to copy files to the correct location. Fixed!\n\n"
			else:
				helpString = """\nALERT! Your unzipping program added an extra nested folder\nPlease move the contents of:
\"""" +ProjectSettings.globalize_path(soundDir+thing+"/"+thing+"\"")+"""
to
\"""" +ProjectSettings.globalize_path(soundDir+thing+"\"")+"""
(Cut and paste the duplicate folder, and merge when prompted.)\n\n"""+ helpString
				break
	var actualFolders = []
	var checks = 0 #keep track of number of FoxLib audio objects created
	for packfolder in folders:
		if(packfolder.begins_with("SoundMod_Effects")): #this is the folder for sound effects
			var effectDir = soundDir + "SoundMod_Effects/"
			var EffectTypes = sub_dir(effectDir)
#			_numEff = EffectTypes.size()
			for type in EffectTypes:
				var name1 = type+"/"
				var dispName = name1.trim_prefix("effects_") #create the display name by editing the path as a string
				dispName = dispName.trim_suffix("/")
				if(dir.dir_exists(effectDir+name1)):
					dir.open(effectDir+name1)
					dir.list_dir_begin()
					var file = dir.get_next()
					EffectSound = self.newAudio("Effect"+dispName, dir.get_current_dir()+file)
					var files = dir_contents_minus_first(effectDir+name1)
					for entry in files:
						if entry.ends_with(".import"): #ignore .import files, they are only for use in the Godot editor
							continue
						var _temp = effectDir + name1 + entry
						EffectSound.addAudioPath(_temp) #FoxLib API to add audio
					dir.list_dir_end()
			print("[SoundMod] Added "+String(EffectTypes.size())+ " sound effects")
#			helpString += "Added "+String(EffectTypes.size())+ " sound effects\n"
			checks += effectReq.size()
			continue
		if(packfolder.begins_with("SoundMod_BGM")): #this is the BGM folder
			var BGMDir = soundDir + "SoundMod_BGM/"
			dir.open(BGMDir)
			dir.list_dir_begin()
			var files = dir_contents(BGMDir)
			for file in files:
				if(is_this_audio(file)):
					continue
				else:
					files.pop_front()
			for file in files:
				var dispName = file
				dispName.erase(dispName.length()-4,4)
				AmSound = self.newAudio("BGM"+dispName, dir.get_current_dir()+file)
			dir.list_dir_end()
			print("[SoundMod] Added "+String(files.size())+ " BGM tracks")
#			helpString += "Added "+String(files.size())+ " BGM tracks\n"
			checks += files.size()
			continue
		if(!is_valid_pack(soundDir+packfolder)):
			printerr("[SoundMod] Error: Tried to read '"+soundDir+packfolder+"/' and did not find the correct directory structure.")
			helpString += "Error: Tried to read '"+soundDir+packfolder+"/' and did not find the correct directory structure.\n\n"
			continue
		else:
			actualFolders.append(packfolder)
		if(packfolder.begins_with("SoundMod_pack")): #this is one of possibly many voice pack folders
			var pack = packfolder.get_slice("_",2)
#			substr(packfolder.find("_")+1,-1)
			var Voicetypes = sub_dir(soundDir + packfolder)
			var list = (dir_contents(soundDir + packfolder))
			var s:String = "" #credits to voice actors and such
			for item in list:
				if item == "credits.txt":
					var f = File.new()
					f.open(soundDir + packfolder + "credits.txt", File.READ)
					s = f.get_as_text()
					f.close()
			for type in Voicetypes:
				var name1 = type + "/"
				var dispName = name1.trim_prefix("sounds_")
				dispName.erase(dispName.length()-1,1)
				name1 = packfolder + "/" + name1
				if(dir.dir_exists(soundDir+name1)):
					dir.open(soundDir+name1)
					dir.list_dir_begin()
					var file = dir.get_next()
					sound = self.newAudio("Sound"+dispName + pack, dir.get_current_dir()+file)
					var files = dir_contents_minus_first(soundDir+name1)
					for entry in files:
						if entry.ends_with(".import"):
							continue
						var _temp = soundDir + name1 + entry
						sound.addAudioPath(_temp)
					sound.setAuthor(s)
					dir.list_dir_end()
			print("[SoundMod] Added voice "+packfolder.trim_prefix("SoundMod_")+" with "+String(Voicetypes.size())+ " sounds")
#			helpString += "Added voice "+packfolder.trim_prefix("SoundMod_")+" with "+String(Voicetypes.size())+ " sounds\n"
			checks += packReq.size()
	folders = actualFolders
	if FoxLibAudioManager.getAllAudioIDs().size() > 2:
		helpString += "FoxLib has created "+String(FoxLibAudioManager.getAllAudioIDs().size()-2)+" out of "+String(checks)+" expected audio streams.\n\n" # minus two because the list given by FoxLib includes null and the FoxLib test audio
		if(FoxLibAudioManager.getAllAudioIDs().size()-2 == checks):
			helpString += "The audio files seem to be in the right spot with the right names. Use the sound test menu to try it in-game.\n"
		elif(FoxLibAudioManager.getAllAudioIDs().size()-2 >= checks):
			helpString += "The audio files seem to be in the right spot with the right names. You might have a duplicate audio clip but SoundMod will still work. Use the sound test menu to try it in-game.\n"
		else:
			helpString += "Some files seem to have been renamed or moved. Please check for nested folders.\n"
	var _debugg = FoxLibAudioManager.getAllAudioIDs()
	FoxLibModInitHelper.callOnFoxLibModInit()

# copy all files and folders from a nested folder to the folder above it. Assumes it won't be nested more than one layer deep.
func fix_nested_folder(_path_it_should_use, _path_to_nested_folder):
	var dir = Directory.new()
	dir.open(_path_to_nested_folder)
	var all = get_files_from_nested_directory(_path_to_nested_folder)
	dir.list_dir_begin(true, false)
	var fErr = OK
	for file_name in all:
		if(not fErr == OK):
			Log.printerr("[SoundMod] Could not move folder "+ _path_to_nested_folder+ " error "+String(fErr))
			return fErr
		var new_path = file_name # erase method operates in place, so we need a copy of the string
		new_path.erase(file_name.find(_path_to_nested_folder.get_file()), _path_to_nested_folder.get_file().length())
		var _who = new_path
		_who.erase(new_path.find(new_path.get_file()), new_path.get_file().length())
		dir.make_dir_recursive(_who) # make sure the destination exists
		fErr = dir.copy(file_name, new_path) # copy the file, any errors will be saved in fErr and caught on the next loop
	fErr = OS.move_to_trash(ProjectSettings.globalize_path(_path_to_nested_folder)) # safer to let OS handle deleting of old files
	if(fErr == OK):
		Log.print("[SoundMod] Moved "+_path_to_nested_folder +" to "+_path_it_should_use)
	return fErr

# attempt automatic unzipping of the audio files
func do_it_for_me(_args):
	var Dialog = ConfirmationDialog.new() #creating the dialog box
	var viewport = FoxUIManager.getCurrentScene().get_viewport()
	viewport.add_child(Dialog)
	var dir = Directory.new()
	dir.open(GlobalRegistry.getModsFolder())
	var soundFiles = []
	for entry in dir_contents(GlobalRegistry.getModsFolder()):
		if(entry.begins_with("SoundMod_") && entry.ends_with(".zip")):
			soundFiles.append(entry) # find any files in mods directory that match the pattern "SoundMod_*.zip"
	var text = "The game will now attempt to extract the following:\n"
	for name in soundFiles:
		text += name+"\n"
	text += "\nThis will take several minutes and the game will freeze up during it.\nThere is no progress bar, you will have to wait."
	Dialog.dialog_text = text
	Dialog.popup_exclusive = true # lock the rest of the UI while dialog box is active
	Dialog.popup_centered_clamped() # show the dialog box
	Dialog.get_ok().connect("pressed", self, "do_Unzip", [soundFiles, Dialog]) #do the unzipping operation if confirm, nothing if cancel
	
func do_Unzip(_sf, dia):
	var problems = zipper(_sf) #the actual extraction
	var c = AcceptDialog.new() #creating the dialogue box
	dia.visible = false
	dia.queue_free() #allow the previous dialog box to be deleted, we're done with it
	var viewport = FoxUIManager.getCurrentScene().get_viewport()
	viewport.add_child(c)
	var text = "Completed!\n"
	if(problems.size()>=1): # list any files that failed
		text += "Errors occurred for the following files:\n"
	else:
		text += "No errors occurred. Yay!"
	if(problems.size()>=30):
		text += String(problems.size())+ " of them. That's a lot. Good luck."
	else:
		for line in problems:
			text += line+"\n"
	text += "Please restart the game and hopefully it will work."
	c.dialog_text = text
	c.popup_centered_clamped() #show the dialog box
	
func zipper(soundFiles):
	var problems = []
	for thezip in soundFiles:
		var unzip = GDUnzip.new() # GDunzip is an open-source module that is already part of the base game files
		unzip.load(GlobalRegistry.getModsFolder()+"/"+thezip) # must first load the .zip file
		var list = unzip.files # provides a list of all files and folders in the .zip
		var T = File.new() # initialize objects for file operations
		var dir = Directory.new()
		for relPath in list: # loop through the list
			var _dummy = unzip.uncompress(relPath) # try to extract this path from inside the .zip
			var _x = GlobalRegistry.getModsFolder()+"/"+relPath # get the full path for debugging purposes
			if(typeof(_dummy) != TYPE_RAW_ARRAY): # GDunzip will return a byte array if successful, and will return false if it failed
				problems.append(_x) #keep track of files that had errors
				Log.printerr("GDunzip error for "+_x)
				continue
			if(_dummy.empty()): # empty array means the path was a folder, we can skip it
				continue
			var fff = relPath.get_base_dir() # get the base of the relative path
			dir.make_dir_recursive(GlobalRegistry.getModsFolder()+"/"+fff) # if the relative path doesn't exist in the mods folder, make the folders
			
			var _err11 = T.open(_x,File.WRITE) # create a new file at the new path 
			T.store_buffer(_dummy) # write the raw bytes, the header and file extension should take care of the file type
			Log.print("Unpacked "+_x)
			T.close()
	print(problems)
	return problems
	
func open_mods_folder(_args):
		Util.fixed_shell_open(ProjectSettings.globalize_path(soundDir))
		Log.print("Tried to open "+ProjectSettings.globalize_path(soundDir))

# function to check if folder names and paths are correct
func validate(_args):
	Util.fixed_shell_open(ProjectSettings.globalize_path("res://Modules/SoundModule/README_soundmod.txt")) # in some OS this will open the README in the default text editor
	var dir = Directory.new()
	var checkMistake = GlobalRegistry.getModsFolder()+"/SoundMod.zip"
	var unzip = GDUnzip.new()
	unzip.load(checkMistake)
	var list = unzip.files
	for path in list:
		if("SoundMod_" in path):
			printerr("[SoundMod] Found audio folders inside"+ProjectSettings.globalize_path(checkMistake)+". Please move audio folders.")
			helpString += "Error! Found audio folders inside"+ProjectSettings.globalize_path(checkMistake)+". Please move audio folders to:\n"+ProjectSettings.globalize_path(GlobalRegistry.getModsFolder()+"\n\n")
			break
	dir.open(GlobalRegistry.getModsFolder())
	var _files = dir_contents(GlobalRegistry.getModsFolder())
	if(_files.has("Modules") || _files.has("SoundMod") || _files.has("SoundMod.json")): #check if the mod was extracted when it shouldn't be
		printerr("[SoundMod] It appears the mod itself was unzipped. Do not extract SoundMod.zip")
		helpString += "Error! It appears the mod itself was unzipped. Do not extract SoundMod.zip\n\n"
	#the helpstring was generated during loading, start with that
	var _zip = "\nChecking for .zip files: \n"
	_zip += "(Ignore this if the unzipped folder was located above)\n\n"
	if(dir_contents(soundDir).empty()):
		soundDir = GlobalRegistry.getModsFolder()+"/"
	for bit in dir_contents(soundDir):
		if(bit.begins_with("SoundMod_") && not bit == "SoundMod_legacy.zip"):
			if(not sub_dir(soundDir).has(bit)):
				_zip += bit+" is still zipped! \n"
			else:
				continue
	helpString += _zip
	helpString += """\nCheck that your unzipping program didn't add an extra folder when unzipping!"""
	getMenuButtons()
	
# hack alert - this function is meant for adding menu buttons, but I needed a way to render the setup window AFTER the main menu loads (postInit does not work for this)
func getMenuButtons():
	var hack:Array = [] # there's no buttons to add, so just leave it as default
	if(showHelpPopup):
		var viewport = FoxUIManager.getCurrentScene().get_viewport()
		var _eeee = viewport.get_node("/root/MainMenu")
		viewport.add_child(smDialog)
		smDialog.rect_size = Vector2(600,350)
		smDialog.dialog_text = helpString
		smDialog.dialog_autowrap = true
		smDialog.window_title = "SoundMod Setup Help"
		smDialog.theme = load("res://GlobalTheme.tres")
		smDialog.popup_centered_ratio(0.6) #show the dialog box, but not too big
	return hack

# runs after the game loads but before reaching the main menu
func postInit():
	if(GlobalRegistry.getModule("FoxLib") == null):
		print("[SoundMod] Error: "+id+" requires FoxLib")
		OS.alert("Error! SoundMod requires FoxLib! Please install Foxlib v"+foxlibversion+" or newer.", OS.get_executable_path())
	if(GlobalRegistry.getModule("SoundModule_legacy") != null):
		Log.print("[SoundMod] Error: "+id+" is not compatible with SoundMod Legacy version. Only install one, not both.")
#	var _temp = FoxLibAudioManager.getAllAudioIDs()
	if(sub_dir(soundDir).empty()): #one last check if things went wrong
		OS.alert("""The expected folders for storing audio were not found. They may not exist or were renamed. Check you have sounds downloaded and placed in\n""" + (ProjectSettings.globalize_path(GlobalRegistry.getModsFolder()))+"\n OR in \n"+ ProjectSettings.globalize_path(GlobalRegistry.getModsFolder().rstrip("mods").rstrip("BDCCMods").plus_file("soundmod")) + """/
		
		Folder names have changed as of SoundMod v1.3.0, if you downloaded them before this rename them so they all start with \"SoundMod_\".
		""", OS.get_executable_path())
	
	var jsonResult
	var f = File.new()
	var _err = f.open(soundDir+"SoundMod_BGM/settings.json",File.READ) #attempt to read any settings for the BGM system
	if(not _err == OK):printerr("[SoundMod] Didn't find BGM settings file, if you previously tried to use BGM then it's broken :(")
	jsonResult = JSON.parse(f.get_as_text())
	assert(typeof(jsonResult.result) == TYPE_DICTIONARY, "[SoundMod] Could not read saved data file. Ignore this if you're not using BGM.")
	Globals.of(BGMDB).data = jsonResult.result
	f.close()
	
	if(f.file_exists("user://mods/.soundmodExists")): #check for hidden file, if it exists then SoundMod has been loaded before
		pass
	else:
		helpString = "\nSoundMod first-time setup! You can disable this window in Mod Options.\n\nMake sure you installed FoxLib v0.10.7 or later! Then do this:\n 1. Download the audio files from the Mod Browser, then click the Mods Folder button\n 2. Unzip the audio files in the mods folder\n 3. Select a voice pack in the Mod Options menu or else you won't hear anything.\n\n" + helpString
#		if(not showHelpPopup):
#			f.open("user://mods/.soundmodExists", File.WRITE) #empty file created to indicate that this module has been loaded before
#			f.close()
		#make sure we validate since this is the first time
	
# hook for FoxLib mod options integration
func onFoxLibModInit(foxModuleAPI):
	foxModuleAPI.addButtonOptionInCategory("SoundMod Settings", "openfiles", "Open audio folder", "Open the folder where sounds are saved").connect("option_changed", self, "open_mods_folder")
	foxModuleAPI.addButtonOptionInCategory("SoundMod Settings", "fixit", "Do it for me", "Try to unzip the audio files").connect("option_changed", self, "do_it_for_me")
	foxModuleAPI.addButtonOptionInCategory("SoundMod Settings", "diditwork","Help! There's no sound!","Checks to see if you put audio in the right place and shows the setup window").connect("option_changed", self, "validate")
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Settings","showHelpPopup", "Show the setup window", "Show the setup window every time the game starts",true)
#	foxModuleAPI.addButtonOptionInCategory("SoundMod Settings", "installzip", "Select a .zip to add sounds", "Extracts a zip file to "+OS.get_user_data_dir()+"/soundmod/  \nWill overwrite existing!").connect("option_changed", self, "unzip_sounds")
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Settings","audiotest", "Show sound test in Me menu", "Show the sound test menu in the 'Me' menu",true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds","Psoundoption", "Pleasure sounds", "Sound plays on arousal stat change",true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds","Osoundoption", "Orgasm sounds", "Sound plays at orgasm",true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds","Tsoundoption", "Tease sounds", "Sound plays on lust stat change",true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds","Ssoundoption", "Struggle sounds", "Sound plays on struggle attempt",true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds","gagsoundoption", "Gagged sounds", "Play variant sounds when gagged",true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds","HypnoOption", "Hypno Hum", "Subtle hum when being hypnotized",true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds", "spankOption", "Spanking", "Play spanking sound effect when spanked", true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds", "punchOption", "Spanking", "Play (mild) punching sound effect when beating up", true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds", "clothOption", "Clothes rustle", "Play fabric noise when trying to remove clothing (will play even if removal gets resisted)", false)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds", "chainOption", "Chain noise", "Play metal clink when trying to leash or apply bondage (will play even if it gets resisted)", false)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds", "plapOption", "Plaps & glucks", "Play a short loop of plaps while fucking (timing will not sync)", true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds", "cumEffect", "Cum effects", "Should ejaculation sounds play along with orgasm voice clips?", true)
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Sounds", "squirtEffect", "Squirting", "Should characters with a vagina and no penis replace ejaculating with squirting?", true)
	foxModuleAPI.addSliderOptionInCategory("SoundMod Settings","pitchVarianceOption","Pitch variance","Slightly change pitch so sounds aren't repetitive", float(10))
	var select = []
	var dir = Directory.new()
	if !Util.folderExists(soundDir):
		dir.make_dir_recursive(soundDir)
	dir.open(soundDir)
	folders = sub_dir(soundDir)
	var actualFolders = []
	for packfolder in folders:
		if(!is_valid_pack(soundDir+packfolder)):
			continue
		else:
			actualFolders.append(packfolder.trim_prefix("SoundMod_"))
	for entry in actualFolders:
		select.append([entry, entry])
	select.append(["debug blank", "debug none"])
	foxModuleAPI.addListOptionInCategory("SoundMod Settings", "voicepackoption", "Voice Pack", select, "Select a voice pack. Packs are added by making a folder in the audio folder", "error")
	foxModuleAPI.addBooleanOptionInCategory("SoundMod Settings", "BGMOption", "Background Music (EXPERIMENTAL)", "Play BGM sounds based on location", false)
	foxModuleAPI.addSliderOptionInCategory("SoundMod Settings", "BGMVolume", "BGM volume (EXPERIMENTAL)","Volume for BGM sound", 50)
	foxModuleAPI.addButtonOptionInCategory("SoundMod Settings", "BGMassign", "Assign BGM (EXPERIMENTAL)", "Assign music to locations").connect("option_changed", self, "BGM_popup")

#returns all the directories within the given directory (ignores files)
func sub_dir(path):
	var dir = Directory.new()
	var _folds:Array
	if dir.open(path) == OK:
		dir.list_dir_begin(true, false)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				_folds.append(file_name)
			file_name = dir.get_next()
	else:
		printerr("[SoundMod] An error occurred when trying to access the folder " +path)
	dir.list_dir_end()
	return _folds
	
# is this an audio file?
func is_this_audio(_filepath):
	if(_filepath.ends_with(".mp3") || _filepath.ends_with(".ogg") || _filepath.ends_with(".wav")):
		return true
	else:
		return false
	
# checks if the given directory has the expected directory structure for voice packs
func is_valid_pack(folder):
	var dir = Directory.new()
	var valid = false
	if dir.open(folder + "/") == OK:
		dir.list_dir_begin(true, false)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if packReq.has(file_name):
					valid = true
				else:
					valid = false
			file_name = dir.get_next()
	else:
		printerr("[SoundMod] An error occurred when trying to access the folder " +folder)
	dir.list_dir_end()
	return valid	

# lists all the files in the given directory except the first one (assuming the first file was imported as a test)
func dir_contents_minus_first(path):
	var dir = Directory.new()
	var _file_names:Array
	if dir.open(path) == OK:
		dir.list_dir_begin(true, false)
		dir.get_next()
		var file_name = dir.get_next()
		while(file_name != ""):
			_file_names.append(file_name)
			file_name = dir.get_next()
	else:
		printerr("[SoundMod] An error occurred when trying to get the contents of " +path)
	dir.list_dir_end()
	return _file_names
	
# lists all the files in the given directory
func dir_contents(path):
	var dir = Directory.new()
	var _file_names:Array
	if dir.open(path) == OK:
		dir.list_dir_begin(true, false)
		var file_name = dir.get_next()
		while(file_name != ""):
			_file_names.append(file_name)
			file_name = dir.get_next()
	else:
		printerr("[SoundMod] An error occurred when trying to get the contents of " +path)
	dir.list_dir_end()
	return _file_names

# return a list of paths to all files and folders within a given folder
func get_files_from_nested_directory(dir_path: String, incl_files_from_given_dir: bool = true):
	var files = []
	var item
	var item_path
	var dir = Directory.new()
	dir.open(dir_path)	
	dir.list_dir_begin(true, false)
	item = dir.get_next()
	while item != "":
		item_path = dir_path + "/" + item
		if dir.dir_exists(item_path):
			files.append_array(get_files_from_nested_directory(item_path,true))
		if dir.file_exists(item_path) and incl_files_from_given_dir:
			files.append(item_path)
		item = dir.get_next()
	dir.list_dir_end()
	return files

# code for UI dialog box used for editing BGM track settings
func BGM_popup(_args):
	var jsonResult
	var f = File.new()
	var _err = f.open(soundDir+"SoundMod_BGM/settings.json",File.READ) #read from file
	assert(_err == OK,"[SoundMod] Didn't find BGM settings file. Ignore this if not using BGM.")
	jsonResult = JSON.parse(f.get_as_text())
	assert(typeof(jsonResult.result) == TYPE_DICTIONARY, "[SoundMod] Could not read saved data file for BGM. Ignore this if not using BGM.")
	Globals.of(BGMDB).data = jsonResult.result #place the data in FoxLib's global variables
	
	var Dialog = popupwindow.instance()
	var viewport = FoxUIManager.getCurrentScene().get_viewport()
	viewport.add_child(Dialog)
	Dialog.popup_centered_clamped() #show the dialog box
	Dialog.connect("tree_exiting", self, "saveBGMsettings") #when the dialog is closed, run the save function

# save the BGM system settings to file
func saveBGMsettings():
	var f = File.new()
	var _temp:Dictionary = Globals.of(BGMDB).data
	f.open(soundDir+"SoundMod_BGM/settings.json",File.WRITE_READ)
	f.store_line(JSON.print(_temp, "\t", true)) # data is saved as human-readable json
	f.close()
