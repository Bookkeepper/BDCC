extends CodeContex
#class_name DelayedCodeContext
#public_api

var originalCodeContex = null
var shouldPassMessageHandling = false
var sentMessage = false

func initDelayedFrom(originalContex: CodeContex):
	self.originalCodeContex = originalContex
	self.curLine = originalContex.curLine
	self.vars = originalContex.vars
	self.varsDefinition = originalContex.varsDefinition
	self.flags = originalContex.flags
	self.flagsDefinition = originalContex.flagsDefinition
	if originalContex is DatapackQuestCodeContext:
		self.shouldPassMessageHandling = true 

func resetDelayedState():
	if self.hadAnError():
		self.resetErrored()
	self.returning = false
	self.sentMessage = false

func delayedSay(text):
	if self.sentMessage:
		text = "\n" + text
	self.sentMessage = true
	if GM.ui != null:
		GM.ui.say(text)

func say(text):
	if self.shouldPassMessageHandling:
		self.originalCodeContex.say(text)
	else:
		return GM.ui.say(processOutputString(text))

func sayn(text):
	if self.shouldPassMessageHandling:
		self.originalCodeContex.sayn(text)
	else:
		self.delayedSay(processOutputString(text) + "\n")

func saynn(text):
	if self.shouldPassMessageHandling:
		self.originalCodeContex.saynn(text)
	else:
		self.delayedSay(processOutputString(text) + "\n\n")

func addMessage(text):
	if self.shouldPassMessageHandling:
		return self.originalCodeContex.addMessage(text)
	else:
		self.delayedSay(text)

func addButton(_nameText, _descText, _state, _codeSlot, _buttonChecks):
	self.originalCodeContex.addButton(_nameText, _descText, _state, _codeSlot, _buttonChecks)

func addDisabledButton(_nameText, _descText):
	self.originalCodeContex.addDisabledButton(_nameText, _descText)

func doPrint(text):
	self.emit_signal("onPrint", text)
	self.originalCodeContex.doPrint(text)

func doDebugPrint(text):
	self.originalCodeContex.doDebugPrint(text)

func markQuestAsVisible():
	self.originalCodeContex.markQuestAsVisible()

func markQuestAsCompleted():
	self.originalCodeContex.markQuestAsCompleted()

# Handles things like {{varName}} and {{"meow" if varName else "mow"}}
var simpleStringInterpolator:SimpleStringInterpolator = SimpleStringInterpolator.new()

func processOutputVars(text:String):
	return simpleStringInterpolator.process(text, self)

func processOutputString(text:String):
	return processOutputVars(text)

