extends Reference
class_name SoundModBGMDB

const name = "SoundMod_BGM_database"
var version = GlobalRegistry.getModule("SoundModule").version

var data = {}

# Note for audio files: the text must be "BGM"+ the full filename without the extension
# Example: file -> prison_ambience.ogg
#		   text to put in here -> BGMprison_ambience

func getBGM(_room:GameRoom) -> String:
	var bgm = "" # will play nothing. stops current BGM.
	var rooms = data.get_or_add(_room.getFloorID(), {})
	if(rooms && not rooms.empty()):
		if(_room.roomID in rooms.keys()):
			bgm = data[_room.getFloorID()][_room.roomID]
		else:
			bgm = data[_room.getFloorID()]["default"]
	else:
		bgm = ""
	return bgm
	
func setBGM(_floor, _room, _music):
	if(not _floor in GlobalRegistry.getMapFloors().keys()):
		return
	if(_room == "default"):
		data.get_or_add(_floor, {}).get_or_add("default", null)
		data[_floor]["default"] = _music
	else:
#		var theroom = GM.world.getRoomByID(_room)
		data.get_or_add(_floor, {}).get_or_add(_room, null)
		data[_floor][_room] = _music
	if(_music == null):
		data[_floor].erase(_room)


# List of room properties:
#roomID
#roomName
#roomDescription
#blindRoomDescription
#canWest
#canNorth
#canEast
#canSouth
#roomSprite
#roomColor
#gridColor
#loctag_Greenhouses
#loctag_MentalWard
#loctag_GuardsEncounter
#loctag_EngineersEncounter
#loctag_Offlimits
#loctag_OldGuardsEncounter
#loctag_NoWallsNear
#floorID
#highlighted
