extends Node2D

# Room properties
var room_width = 2000
var room_height = 500

# Pet spawn settings
var pet_spawn_delay = 10.0  # Seconds between pet spawns
var pet_spawn_chance = 0.8  # Probability of spawning a pet when timer triggers
var max_pets = 5  # Maximum number of pets in the room

# Object spawn settings
var object_spawn_delay = 15.0  # Seconds between object spawns
var object_spawn_chance = 0.7  # Probability of spawning an object when timer triggers

# Game state
var active_pets = []
var active_objects = []

# Pet references
var pet_scenes = {
	"Pupols": preload("res://scenes/pets/pupols.tscn"),
	"Julija": preload("res://scenes/pets/julija.tscn"),
	"Time": preload("res://scenes/pets/time.tscn"),
	"Toaster": preload("res://scenes/pets/toaster.tscn"),
	"WetOwl": preload("res://scenes/pets/wet_owl.tscn")
}

# Object scenes to spawn
var object_scenes = {}

# Object spawn rates (higher number = more likely to spawn)
var object_spawn_rates = {
	"Bath": 0.5,  # Less common since it's a special zone
	"WaterGlass": 0.5,
	"CardDeck": 0.5,
	"Gameboy": 0.5,
	"HourGlass": 0.5,
	"JamJar": 0.5,
	"OutsideDoor": 0.5,
	"Puddle": 0.5,
	"Toast": 0.5,
	"WoodenSpoon": 0.5
}

# Spawn points
var pet_spawn_points = []
var object_spawn_points = []

# Spawn timers
var pet_spawn_timer: Timer
var object_spawn_timer: Timer

# Spawn rates for pets (higher number = more likely to spawn)
var pet_spawn_rates = {
	"Pupols": 1.0,
	"Julija": 0.7,
	"Time": 0.5,
	"Toaster": 0.3,
	"WetOwl": 0.2  # Rare special pet
}

func _ready():
	# Load all object scenes
	load_object_scenes()
	
	# Setup spawn timers
	setup_timers()
	
	# Register with globals
	Globals.current_room = self
	
	# Get all spawn points
	pet_spawn_points = $PetSpawnPoints.get_children()
	object_spawn_points = $ObjectSpawnPoints.get_children()

func setup_timers():
	# Pet spawn timer
	pet_spawn_timer = Timer.new()
	pet_spawn_timer.wait_time = pet_spawn_delay
	pet_spawn_timer.one_shot = false
	pet_spawn_timer.autostart = true
	add_child(pet_spawn_timer)
	pet_spawn_timer.connect("timeout", spawn_random_pet)
	
	# Object spawn timer
	object_spawn_timer = Timer.new()
	object_spawn_timer.wait_time = 15.0
	object_spawn_timer.one_shot = false
	object_spawn_timer.autostart = true
	add_child(object_spawn_timer)
	object_spawn_timer.connect("timeout", spawn_random_object)

func spawn_random_pet():
	# Random chance to spawn pet
	if randf() > pet_spawn_chance:
		return
	
	# Don't spawn if we're at max pets
	if active_pets.size() >= max_pets:
		return
	
	# Choose a random pet based on spawn rates
	var total_rate = 0
	var available_pets = pet_spawn_rates.keys()
	for pet in available_pets:
		total_rate += pet_spawn_rates[pet]
	
	var roll = randf() * total_rate
	var current_sum = 0
	var chosen_pet = available_pets[0]  # Default
	
	for pet in available_pets:
		current_sum += pet_spawn_rates[pet]
		if roll < current_sum:
			chosen_pet = pet
			break
	
	# Create the pet instance
	var pet_instance = pet_scenes[chosen_pet].instantiate()
	
	# Place at a random spawn point
	if pet_spawn_points.size() > 0:
		var spawn_point = pet_spawn_points[randi() % pet_spawn_points.size()]
		pet_instance.position = spawn_point.position
		
		# Add to the room
		add_child(pet_instance)
		active_pets.append(pet_instance)
		
		# Register the pet with globals
		Globals.register_pet(pet_instance)
		
		# Adjust timer for next spawn
		pet_spawn_timer.wait_time = max(pet_spawn_delay * 0.8, 5.0)  # Gradually decrease spawn time (but not too short)
		
		# Spawn more objects when pets appear
		spawn_random_object()

func load_object_scenes():
	# Load scenes manually to avoid preload errors
	object_scenes["Bath"] = load("res://scenes/objects/bath.tscn")
	object_scenes["WaterGlass"] = load("res://scenes/objects/water_glass.tscn")
	object_scenes["CardDeck"] = load("res://scenes/objects/card_deck.tscn")
	object_scenes["Gameboy"] = load("res://scenes/objects/gameboy.tscn")
	object_scenes["HourGlass"] = load("res://scenes/objects/hour_glass.tscn")
	object_scenes["JamJar"] = load("res://scenes/objects/jam_jar.tscn")
	object_scenes["OutsideDoor"] = load("res://scenes/objects/outside_door.tscn")
	object_scenes["Puddle"] = load("res://scenes/objects/puddle.tscn")
	object_scenes["Toast"] = load("res://scenes/objects/toast.tscn")
	object_scenes["WoodenSpoon"] = load("res://scenes/objects/wooden_spoon.tscn")



func spawn_random_object():
	# Random chance to spawn object
	if randf() > object_spawn_chance:
		return
		
	# Choose a random object based on spawn rates
	var total_rate = 0
	var available_objects = object_spawn_rates.keys()
	for obj_type in available_objects:
		total_rate += object_spawn_rates[obj_type]
	
	var roll = randf() * total_rate
	var current_sum = 0
	var chosen_object = available_objects[0]  # Default
	
	for obj_type in available_objects:
		current_sum += object_spawn_rates[obj_type]
		if roll < current_sum:
			chosen_object = obj_type
			break
	
	# Create the object instance
	var object_instance = object_scenes[chosen_object].instantiate()
	
	# Place at a random spawn point
	if object_spawn_points.size() > 0:
		var spawn_point = object_spawn_points[randi() % object_spawn_points.size()]
		object_instance.position = spawn_point.position
		
		# Add to the room
		add_child(object_instance)
		active_objects.append(object_instance)
		
		# Register the object with globals
		Globals.register_object(object_instance)
	
func _process(_delta):
	# Check game over conditions
	for pet in active_pets:
		if pet.satisfaction_level >= 100 or pet.wrath_level >= 100:
			game_over(pet)
			break

func game_over(pet):
	# Simple game over implementation
	var game_over_label = Label.new()
	game_over_label.text = "Game Over!"
	game_over_label.set_anchors_preset(Control.PRESET_CENTER)
	
	var reason = ""
	if pet.satisfaction_level >= 100:
		reason = pet.pet_name + " was too satisfied and exploded with joy!"
	elif pet.wrath_level >= 100:
		reason = pet.pet_name + " got too angry and destroyed everything!"
		
	var reason_label = Label.new()
	reason_label.text = reason
	reason_label.position.y += 50
	reason_label.set_anchors_preset(Control.PRESET_CENTER)
	
	var ui = CanvasLayer.new()
	add_child(ui)
	ui.add_child(game_over_label)
	ui.add_child(reason_label)
	
	# Stop game logic
	get_tree().paused = true
