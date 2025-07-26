extends Node

var held_pet: Node2D = null  # Track if player is holding one
var current_area: Node2D = null  # Optional: track which area is loaded
var pet_registry := {}  # Track all pets and their states

func hold_pet(pet):
	if held_pet:
		return  # Already holding something
	held_pet = pet
	pet.set_held(true)

func drop_pet():
	if held_pet:
		held_pet.set_held(false)
		held_pet = null

func is_holding_pet() -> bool:
	return held_pet != null
