extends Node2D

var room_width = 2000
var room_height = 500

var pet_spawn_delay = 10.0 
var pet_spawn_chance = 0.8 
var max_pets = 5 

var object_spawn_delay = 15.0 
var object_spawn_chance = 0.7 

var active_pets = []
var active_objects = []
var pet_scenes = {
	"Gambling addict Pupols": preload("res://scenes/pets/pupols.tscn"),
	# "julija": preload("res://scenes/pets/julija.tscn"),
	# "time": preload("res://scenes/pets/time.tscn"),
	"Toaster": preload("res://scenes/pets/toaster.tscn"),
	"Wet Owl": preload("res://scenes/pets/wet_owl.tscn")
}

var object_scenes = {}
var object_spawn_rates = {
	"Sink": 0.5,
	"CardDeck": 0.5,
	"HourGlass": 0.5,
	"JamJar": 0.5,
	"OutsideDoor": 0.5,
}

var pet_spawn_points = []
var object_spawn_points = []
var pet_spawn_timer: Timer
var object_spawn_timer: Timer

var pet_spawn_rates = {
	"Gambling addict Pupols": 1.0,
	# "julija": 0.7,
	# "time": 0.5,
	"Toaster": 0.3,
	"Wet Owl": 0.2  # Rare special pet
}

func _ready():
	load_object_scenes()
	setup_timers()
	
	Globals.current_room = self
	pet_spawn_points = $PetSpawnPoints.get_children()
	object_spawn_points = $ObjectSpawnPoints.get_children()

func setup_timers():
	pet_spawn_timer = Timer.new()
	pet_spawn_timer.wait_time = pet_spawn_delay
	pet_spawn_timer.one_shot = false
	pet_spawn_timer.autostart = true
	add_child(pet_spawn_timer)
	pet_spawn_timer.connect("timeout", spawn_random_pet)
	
	object_spawn_timer = Timer.new()
	object_spawn_timer.wait_time = 15.0
	object_spawn_timer.one_shot = false
	object_spawn_timer.autostart = true
	add_child(object_spawn_timer)
	object_spawn_timer.connect("timeout", spawn_random_object)

func spawn_random_pet():
	if randf() > pet_spawn_chance:
		return
	
	if active_pets.size() >= max_pets:
		return
	
	var existing_pet_types = []
	for pet in active_pets:
		print("Active pet: ", pet.name, " - Pet type: ", pet.pet_name)
		var pet_type = pet.get_meta("pet_type") if pet.has_meta("pet_type") else pet.name.split("@")[0].to_lower()
		existing_pet_types.append(pet_type)
	
	print("Existing pet types: ", existing_pet_types)
	var available_pets = []
	for pet_type in pet_spawn_rates.keys():
		if not pet_type in existing_pet_types:
			available_pets.append(pet_type)
	
	print("Available pet types for spawning: ", available_pets)
	
	if available_pets.size() == 0:
		print("No unique pets available to spawn")
		return
	
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
	var pet_instance = pet_scenes[chosen_pet].instantiate()
	pet_instance.set_meta("pet_type", chosen_pet)
	pet_instance.pet_name = chosen_pet
	
	if pet_spawn_points.size() > 0:
		var spawn_point = pet_spawn_points[randi() % pet_spawn_points.size()]
		pet_instance.position = spawn_point.position
		
		# Add to the room
		add_child(pet_instance)
		active_pets.append(pet_instance)
		Globals.register_pet(pet_instance)
		pet_spawn_timer.wait_time = max(pet_spawn_delay * 0.8, 5.0)  # Gradually decrease spawn time (but not too short)
		spawn_random_object()

func load_object_scenes():
	object_scenes["Sink"] = load("res://scenes/objects/sink.tscn")
	object_scenes["CardDeck"] = load("res://scenes/objects/card_deck.tscn")
	object_scenes["HourGlass"] = load("res://scenes/objects/hourglass.tscn")
	object_scenes["JamJar"] = load("res://scenes/objects/jar.tscn")
	object_scenes["OutsideDoor"] = load("res://scenes/objects/door.tscn")


func spawn_random_object():
	if randf() > object_spawn_chance:
		return
		
	var total_rate = 0
	var available_objects = object_spawn_rates.keys()
	for obj_type in available_objects:
		total_rate += object_spawn_rates[obj_type]
	
	var roll = randf() * total_rate
	var current_sum = 0
	var chosen_object = available_objects[0]
	
	for obj_type in available_objects:
		current_sum += object_spawn_rates[obj_type]
		if roll < current_sum:
			chosen_object = obj_type
			break
	
	print(chosen_object)
	var object_instance = object_scenes[chosen_object].instantiate()
	if object_spawn_points.size() > 0:
		var spawn_point = object_spawn_points[randi() % object_spawn_points.size()]
		object_instance.position = spawn_point.position
		add_child(object_instance)
		active_objects.append(object_instance)
		Globals.register_object(object_instance)
	
func _process(_delta):
	for pet in active_pets:
		if pet.satisfaction_level >= 100 or pet.wrath_level >= 100:
			game_over(pet)
			break

func game_over(pet):
	var game_over_label = Label.new()
	game_over_label.text = "Game Over!"
	game_over_label.set_anchors_preset(Control.PRESET_CENTER)
	
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
	
	get_tree().paused = true
