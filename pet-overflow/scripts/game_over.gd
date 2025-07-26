extends Control

# Variables to store game over details
var pet_name = ""
var reason = ""
var final_score = 0

func _ready():
	# Connect button signals using Godot 4 syntax
	$VBoxContainer/ButtonsContainer/RestartButton.pressed.connect(_on_restart_button_pressed)
	$VBoxContainer/ButtonsContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	
	# Update UI with game over information
	update_ui()

func initialize(pet, cause, score):
	"""
	Initialize game over screen with details about what caused game over
	
	Args:
	    pet (String): Name of the pet that caused game over
	    cause (String): Reason for game over (satisfaction or wrath overflow)
	    score (int): Final player score
	"""
	pet_name = pet
	reason = cause
	final_score = score

func update_ui():
	"""Update UI elements with game over information"""
	$VBoxContainer/PetNameLabel.text = pet_name
	$VBoxContainer/ReasonLabel.text = reason
	$VBoxContainer/ScoreLabel.text = "Final Score: " + str(final_score)

func _on_restart_button_pressed():
	"""Restart the game by loading the main scene"""
	# Reset globals
	var globals = get_node("/root/Globals")
	globals.reset_game()
	
	# Reload main scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	"""Exit the game"""
	get_tree().quit()
