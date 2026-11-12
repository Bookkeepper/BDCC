extends "res://FoxLib/GameTest/GenerateNPCTest.gd"

func _init():
	name = "Inmate Species Generation"

func makeGenerator():
	return InmateGenerator.new()

func getCharacterPool():
	return CharacterPool.Inmates
