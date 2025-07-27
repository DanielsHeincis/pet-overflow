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
	"pupols": preload("res://scenes/pets/pupols.tscn"),
	# "julija": preload("res://scenes/pets/julija.tscn"),
	# "time": preload("res://scenes/pets/time.tscn"),
	"toaster": preload("res://scenes/pets/toaster.tscn"),
	"wet_owl": preload("res://scenes/pets/wet_owl.tscn")
}

# Object scenes to spawn
var object_scenes = {}

# Object spawn rates (higher number = more likely to spawn)
var object_spawn_rates = {
	"sink": 0.5,
	"card_deck": 0.5,
	"hourglass": 0.5,
	"jar": 0.5,
	"door": 0.5,
}

# Spawn points
var pet_spawn_points = []
var object_spawn_points = []

# Spawn timers
var pet_spawn_timer: Timer
var object_spawn_timer: Timer

# Spawn rates for pets (higher number = more likely to spawn)
var pet_spawn_rates = {
	"pupols": 1.0,
	# "julija": 0.7,
	# "time": 0.5,
	"toaster": 0.3,
	"wet_owl": 0.2  # Rare special pet
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
	
	# Get list of pet types that are already in the room
	var existing_pet_types = []
	for pet in active_pets:
		# Debug print to check what's in the active pets list
		print("Active pet: ", pet.name, " - Pet type: ", pet.pet_name)
		
		# Use a more reliable method to track pet types
		# Store the actual scene name or a unique identifier
		var pet_type = pet.get_meta("pet_type") if pet.has_meta("pet_type") else pet.name.split("@")[0].to_lower()
		existing_pet_types.append(pet_type)
	
	# Print for debugging
	print("Existing pet types: ", existing_pet_types)
	
	# Filter available pets to exclude ones that already exist
	var available_pets = []
	for pet_type in pet_spawn_rates.keys():
		if not pet_type in existing_pet_types:
			available_pets.append(pet_type)
	
	# Print for debugging
	print("Available pet types for spawning: ", available_pets)
	
	# If no available pets (all types already spawned), return
	if available_pets.size() == 0:
		print("No unique pets available to spawn")
		return
	
	# Choose a random pet based on spawn rates
	var total_rate = 0
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
	
	print("Spawning pet: ", chosen_pet)

	# Create the pet instance
	var pet_instance = pet_scenes[chosen_pet].instantiate()
	
	# Set a meta to track the pet type
	pet_instance.set_meta("pet_type", chosen_pet)
	
	# Make sure the pet name is properly set
	pet_instance.pet_name = chosen_pet.capitalize()
	
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
	#object_scenes["sink"] = load("res://sceness/objects/sink.tscn")
	object_scenes["card_deck"] = load("res://scenes/objects/card_deck.tscn")
	object_scenes["hourglass"] = load("res://scenes/objects/hourglass.tscn")
	object_scenes["jar"] = load("res://scenes/objects/jar.tscn")
	object_scenes["door"] = load("res://scenes/objects/door.tscn")


"res://assets/objects/card_deck.png"
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
	for pet in active_pets:
		if pet.satisfaction_level >= 100 or pet.wrath_level >= 100:
			game_over(pet)
			break

func game_over(pet):
	# Simple game over implementation
	var game_over_label = Label.new()
	game_over_label.text = "Game Over!"
	game_over_label.set_anchors_preset(Control.PRESET_CENTER)
	
	# Set white text with black outline
	var font_settings = LabelSettings.new()
	font_settings.font_size = 48
	font_settings.font_color = Color(1, 1, 1) # White
	font_settings.outline_size = 4
	font_settings.outline_color = Color(0, 0, 0) # Black
	game_over_label.label_settings = font_settings
	
	var reason = ""
	if pet.satisfaction_level >= 100:
		reason = pet.pet_name + " was too satisfied and exploded with joy!"
	elif pet.wrath_level >= 100:
		reason = pet.pet_name + " got too angry and destroyed everything!"
		
	var reason_label = Label.new()
	reason_label.text = reason
	reason_label.position.y += 50
	reason_label.set_anchors_preset(Control.PRESET_CENTER)
	
	# Also set white text with black outline for reason
	var reason_font_settings = LabelSettings.new()
	reason_font_settings.font_size = 24
	reason_font_settings.font_color = Color(1, 1, 1) # White
	reason_font_settings.outline_size = 2
	reason_font_settings.outline_color = Color(0, 0, 0) # Black
	reason_label.label_settings = reason_font_settings
	
	var ui = CanvasLayer.new()
	add_child(ui)
	ui.add_child(game_over_label)
	ui.add_child(reason_label)
	
	# Stop game logic
	get_tree().paused = true
