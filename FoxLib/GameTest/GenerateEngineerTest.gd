extends "res://FoxLib/GameTest/GenerateNPCTest.gd"

func _init():
	name = "Engineer Species Generation"

func makeGenerator():
	return EngineerGenerator.new()

func getCharacterPool():
	return CharacterPool.Engineers
