extends Node

# References
# No physical player, only cursor interaction as per v2 additions
var held_pet: Node2D = null  # Track if player is holding one
var held_object: Node2D = null  # Track if player is holding an object
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
	# Update cursor to dragging state
	cursor_manager.set_dragging_cursor()
	
func drop_pet():
	if held_pet:
		var pet_position = held_pet.global_position
		var interacting_object = null
		
		for obj_name in object_registry:
			var obj = object_registry[obj_name]
			if obj and is_instance_valid(obj):
				var distance = obj.global_position.distance_to(pet_position)
				if distance < 100:
					interacting_object = obj
					break
		
		held_pet.set_held(false)
		var temp_pet = held_pet
		held_pet = null
		
		cursor_manager.set_normal_cursor()
		
		if interacting_object:
			interacting_object.pet_interact(temp_pet)
		else:
			var ground_y = room_height - 50 
			var drop_tween = create_tween()
			var start_y = temp_pet.global_position.y
			var drop_distance = ground_y - start_y
			var drop_duration = max(0.1, min(0.5, drop_distance / 500))
			
			drop_tween.tween_property(temp_pet, "global_position:y", ground_y, drop_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			drop_tween.tween_property(temp_pet, "global_position:y", ground_y - 10, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			drop_tween.tween_property(temp_pet, "global_position:y", ground_y, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			
			var min_x = 50 
			var max_x = room_width - 50
			temp_pet.global_position.x = clamp(temp_pet.global_position.x, min_x, max_x)
			
			if temp_pet.hates_being_moved:
				await get_tree().create_timer(0.2).timeout
				temp_pet.play_animation("angry")

func is_holding_pet() -> bool:
	return held_pet != null

func register_object(object):
	object_registry[object.name] = object

func remove_object(object):
	if object_registry.has(object.name):
		object_registry.erase(object.name)
		
func hold_object(object):
	if held_object or held_pet:
		return  # Already holding something
	held_object = object
	# Update cursor to dragging state
	cursor_manager.set_dragging_cursor()


func release_object():
	if held_object:
		var object_position = held_object.global_position
		var interacting_pet = null
		
		for pet_name in pet_registry:
			var pet = pet_registry[pet_name]
			if pet and is_instance_valid(pet) and not pet.is_being_held:
				var distance = pet.global_position.distance_to(object_position)
				if distance < 100:  # Approximate interaction radius
					interacting_pet = pet
					break
		
		var temp_object = held_object
		held_object = null
		
		cursor_manager.set_normal_cursor()
		if interacting_pet:
			temp_object.pet_interact(interacting_pet)
		
func is_holding_object() -> bool:
	return held_object != null

# Game state management
func add_score(points):
	current_score += points

# Set game over state
func end_game(pet):
	if game_over:
		return
	
	game_over = true
	print("Game Over! Pet: ", pet.pet_name)
	
	var reason = ""
	
	if pet.satisfaction_level >= 100:
		reason = "Satisfaction Overflow"
		pet.play_animation_scene("good_death")
	else:
		reason = "Wrath Overflow"
		pet.play_animation_scene("bad_death")
	
	await get_tree().create_timer(7.0).timeout
	
	var game_over_scene = load("res://scenes/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()
	
	game_over_instance.initialize(pet.pet_name, reason, current_score)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 
	canvas_layer.add_child(game_over_instance)
	get_tree().root.add_child(canvas_layer)
	
	get_tree().paused = true

func reset_game():
	game_over = false
	current_score = 0
	held_pet = null
	held_object = null
	pet_registry.clear()
	object_registry.clear()
	pet_spawn_rate = 1.0
	satisfaction_rate_multiplier = 1.0
	wrath_rate_multiplier = 1.0
	get_tree().paused = false
