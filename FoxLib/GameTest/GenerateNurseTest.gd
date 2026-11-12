extends "res://FoxLib/GameTest/GenerateNPCTest.gd"

func _init():
	name = "Nurse Species Generation"

func makeGenerator():
	return NurseGenerator.new()

func getCharacterPool():
	return CharacterPool.Nurses
