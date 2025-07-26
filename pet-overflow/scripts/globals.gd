extends Node

# References
# No physical player, only cursor interaction as per v2 additions
var held_pet: Node2D = null  # Track if player is holding one
var current_room: Node2D = null  # Track which room is loaded
var pet_registry := {}  # Track all pets and their states
var object_registry := {}  # Track all objects and their states
var cursor_manager

# Game settings
var game_fps = 12  # Frame rate setting
var game_width = 800
var game_height = 600
var border_size = 45
var room_width = 700
var room_height = 500
var sprite_size = 100
var animation_size = Vector2(400, 200)

# Game state
var current_score = 0
var game_over = false
var pet_spawn_rate = 1.0  # Base spawn rate multiplier
var pet_spawn_count = 0
var satisfaction_rate_multiplier = 1.0
var wrath_rate_multiplier = 1.0
var max_meter_value = 100

func _ready():
	# Configure game settings
	Engine.max_fps = game_fps
	
	# Initialize cursor manager
	cursor_manager = load("res://scripts/cursor_manager.gd").new()
	add_child(cursor_manager)

# Pet management
func register_pet(pet):
	pet_registry[pet.name] = pet
	
func remove_pet(pet):
	if pet_registry.has(pet.name):
		pet_registry.erase(pet.name)


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

# Object management
func register_object(object):
	object_registry[object.name] = object

func remove_object(object):
	if object_registry.has(object.name):
		object_registry.erase(object.name)

# Game state management
func add_score(points):
	current_score += points

# Set game over state
func end_game(pet):
	game_over = true
	
	# Create a simple game over UI
	var game_over_label = Label.new()
	game_over_label.text = "Game Over!"
	game_over_label.position = Vector2(400, 250)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 48)
	
	var reason = ""
	if pet.satisfaction_level >= 100:
		reason = pet.pet_name + " was too satisfied and exploded with joy!"
	elif pet.wrath_level >= 100:
		reason = pet.pet_name + " got too angry and destroyed everything!"
		
	var reason_label = Label.new()
	reason_label.text = reason
	reason_label.position = Vector2(400, 320)
	reason_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reason_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	reason_label.add_theme_font_size_override("font_size", 24)
	
	var score_label = Label.new()
	score_label.text = "Final Score: " + str(current_score)
	score_label.position = Vector2(400, 380)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 100 # Make sure it's on top
	ui_layer.add_child(game_over_label)
	ui_layer.add_child(reason_label)
	ui_layer.add_child(score_label)
	
	# Add the UI to the root
	add_child(ui_layer)
	
	# Stop game logic
	get_tree().paused = true
