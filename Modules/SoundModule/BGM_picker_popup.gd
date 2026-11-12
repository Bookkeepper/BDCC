extends WindowDialog

const FoxLibAudioManager = preload("res://Modules/FoxLib/Internal/FoxLibAudioManager.gd")
const Globals = preload("res://FoxLib/Globals.gd")

var BGMDB = load("res://Modules/SoundModule/SoundModBGMDB.gd")

onready var l1 = $VBoxContainer/Label
onready var l2 = $VBoxContainer/Label2
onready var l3 = $VBoxContainer/Label3
onready var l4 = $VBoxContainer/Label4
onready var dropdownFloor = $VBoxContainer/OptionButton
onready var dropdownRoom = $VBoxContainer/OptionButton2
onready var dropdownMusic = $VBoxContainer/OptionButton3
onready var savebutton = $VBoxContainer/HBoxContainer/assignbutton

var allFloors = GlobalRegistry.getMapFloors()
var listEverything = {}
var tracklist = []
var BGMdatabase = {}


func _init():
	listEverything = listAllFloorAndRoom()
	self.popup_exclusive = true

func _ready():
	BGMdatabase = Globals.of(BGMDB).data
#	BGMdatabase = GM.main.getFlag("SoundModule.BGMdatabase", {})
	for each in FoxLibAudioManager.getAllAudioIDs():
		var track = each.trim_prefix("SoundModule:").trim_prefix("FoxLib:")
		if(track.begins_with("BGM")):
			tracklist.append(track.trim_prefix("BGM"))
	dropdownFloor.clear()
	for key in listEverything.keys():
		dropdownFloor.add_item(key)
	dropdownFloor.selected = -1
	dropdownRoom.clear()
	dropdownRoom.visible = false
	l2.visible = false
	dropdownMusic.clear()
	dropdownMusic.add_item("No BGM", 0)
	for track in tracklist:
		dropdownMusic.add_item(track)
	dropdownMusic.selected = -1
	savebutton.disabled = true
	
func _on_EditWindow_visibility_changed():
	if(not self.visible):
		self.queue_free()

func listAllFloorAndRoom() -> Dictionary:
	var everything = {}
	for thing in GlobalRegistry.getMapFloors():
		var scene = GlobalRegistry.getMapFloors().get(thing)
		var node = load(scene).instance()
		var rooms = node.get_children()
		var _temp = []
		for room in rooms:
			_temp.append(room.roomID)
		everything[thing] = _temp
		node.free()
		
	return everything


func _on_closebutton_pressed():
	self.visible = false


func _on_assignbutton_pressed():
	pass # Replace with function body.
	BGMdatabase = Globals.of(BGMDB).data
	var f = dropdownFloor.get_item_text(dropdownFloor.selected)
	var r = dropdownRoom.get_item_text(dropdownRoom.selected)
	var m = dropdownMusic.get_item_text(dropdownMusic.selected)
	var _entry
	if(dropdownMusic.selected == 0):
		m = null
	if(dropdownRoom.selected == -1 || dropdownRoom.selected == 1):
		_entry = BGMdatabase.get_or_add(f,{}).get_or_add("default", {})
		Globals.of(BGMDB).setBGM(f, "default", "BGM"+m)
	elif(dropdownRoom.selected == 0 ):
		_entry = BGMdatabase.get_or_add(f,{}).get_or_add("default", {})

		Globals.of(BGMDB).setBGM(f, "default", "BGM"+m)
	else:
		_entry = BGMdatabase.get_or_add(f,{}).get_or_add(r, {})
		Globals.of(BGMDB).setBGM(f, r, "BGM"+m)
	


func _on_OptionButton_item_selected(_index):
	if(_index != -1):
		dropdownRoom.visible = true
		l2.visible = true
		savebutton.disabled = false
	dropdownRoom.add_item("Floor-wide",0)
	dropdownRoom.selected = 0
	for loc in listEverything[dropdownFloor.get_item_text(_index)]:
		dropdownRoom.add_item(loc)
	var def = BGMdatabase.get_or_add(dropdownFloor.get_item_text(_index), {}).get_or_add("default", null)
	if(def != null && tracklist.has(def.trim_prefix("BGM"))):
		dropdownMusic.selected = tracklist.find(def.trim_prefix("BGM"))+1
	else:
		dropdownMusic.selected = -1


func _on_OptionButton2_item_selected(_index):
	if(_index == -1):
		savebutton.disabled = true
	var def = BGMdatabase.get_or_add(dropdownFloor.get_item_text(dropdownFloor.selected), {}).get_or_add(dropdownRoom.get_item_text(_index), null)
	if(def && tracklist.has(def.trim_prefix("BGM"))):
		dropdownMusic.selected = tracklist.find(def.trim_prefix("BGM"))+1
	else:
		dropdownMusic.selected = -1
