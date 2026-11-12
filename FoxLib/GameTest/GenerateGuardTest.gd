extends "res://FoxLib/GameTest/GenerateNPCTest.gd"

func _init():
	name = "Guard Species Generation"

func makeGenerator():
	return GuardGenerator.new()

func getCharacterPool():
	return CharacterPool.Guards
