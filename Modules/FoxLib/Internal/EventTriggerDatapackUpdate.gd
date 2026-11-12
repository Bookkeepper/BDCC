extends EventTrigger

const DatapackItemRegistry = preload("res://Modules/FoxLib/DynContent/DatapackItemRegistry.gd")

# We use this class as a hook to detect when datapack register custom triggers
var events = []
var waitTrigger = false
var oldEventCount = 0

static func sortPriority(a, b):
	if a.getPriority() > b.getPriority():
		return true
	return false

func addEvent(event, _args):
	events.push_back(event)

func onAllEventsAdded():
	events.sort_custom(self, "sortPriority")
	if oldEventCount > 0 or oldEventCount != events.size():
		self.triggerRunDeferred([])
		oldEventCount = events.size()

func triggerRunDeferred(args):
	Log.print("Test Datapack FoxLib Trigger Later")
	if not waitTrigger:
		waitTrigger = true
		call_deferred("triggerRun", args)

func triggerReact(args):
	for event in events:
		if(event.react(id, args)):
			return true
	return false

func triggerRun(args):
	waitTrigger = false
	Log.print("[FoxLib] Updating datapack items...")
	DatapackItemRegistry.resetDatapackItemRegistry()
	for event in events:
		event.run(id, args)
	DatapackItemRegistry.finalizeDatapackItemRegistry()
	Log.print("[FoxLib] Datapack items updated!")

