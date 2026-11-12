extends EventBase

var Smod = GlobalRegistry.getModule("SoundModule")

func _init():
	id = "AudioButton"

func registerTriggers(es):
	es.addTrigger(self, Trigger.SceneAndStateHook, ["MeScene", ""])

func run(_triggerID, _args):
	if(Smod.audiotest):
		addButton("Audio Test", "Debug", "sounds")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "sounds"):
		runScene("soundTest")
