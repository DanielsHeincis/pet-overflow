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
		# Check if the pet is being released over an object
		var pet_position = held_pet.global_position
		var interacting_object = null
		
		# Check all registered objects to see if any are under the pet
		for obj_name in object_registry:
			var obj = object_registry[obj_name]
			# Check if the object exists and is a zone (since we only want to interact with zones when dropping pets)
			if obj and is_instance_valid(obj) and obj.is_zone:
				# Calculate distance between pet and object
				var distance = obj.global_position.distance_to(pet_position)
				# If within interaction range
				if distance < 100:  # Approximate interaction radius
					interacting_object = obj
					break
		
		# Set the pet as not held
		held_pet.set_held(false)
		
		# Store the pet reference before clearing it
		var temp_pet = held_pet
		held_pet = null
		
		# Reset cursor to normal state
		cursor_manager.set_normal_cursor()
		
		# If we found an object to interact with, trigger the interaction
		if interacting_object:
			interacting_object.pet_interact(temp_pet)
		else:
			# If no interaction, perform the normal drop animation
			# Make the pet drop to the ground with a falling animation
			var ground_y = room_height - 50  # Ground level with some offset for the pet's height
			
			# Create a more realistic gravity effect with better tween settings
			var drop_tween = create_tween()
			# Start with current position
			var start_y = temp_pet.global_position.y
			# Calculate drop duration based on distance (faster fall from higher positions)
			var drop_distance = ground_y - start_y
			var drop_duration = max(0.1, min(0.5, drop_distance / 500))
			
			# Use CUBIC ease for more natural gravity acceleration
			drop_tween.tween_property(temp_pet, "global_position:y", ground_y, drop_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			# Add a small bounce at the end
			drop_tween.tween_property(temp_pet, "global_position:y", ground_y - 10, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			drop_tween.tween_property(temp_pet, "global_position:y", ground_y, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			
			# Ensure the pet stays within the room bounds
			var min_x = 50  # Left boundary with offset
			var max_x = room_width - 50  # Right boundary with offset
			temp_pet.global_position.x = clamp(temp_pet.global_position.x, min_x, max_x)
			
			# If the pet hates being moved, show anger effect
			if temp_pet.hates_being_moved:
				await get_tree().create_timer(0.2).timeout
				temp_pet.play_animation("angry")

func is_holding_pet() -> bool:
	return held_pet != null

# Object management
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
		# Check if the object is being released over a pet
		var object_position = held_object.global_position
		var interacting_pet = null
		
		# Check all registered pets to see if any are under the object
		for pet_name in pet_registry:
			var pet = pet_registry[pet_name]
			# Check if the pet's collision area overlaps with the object position
			if pet and is_instance_valid(pet) and not pet.is_being_held:
				# Calculate distance between pet and object
				var distance = pet.global_position.distance_to(object_position)
				# If within interaction range (using the collision shape size as reference)
				if distance < 100:  # Approximate interaction radius
					interacting_pet = pet
					break
		
		# Store the object reference before clearing it
		var temp_object = held_object
		held_object = null
		
		# Reset cursor to normal state
		cursor_manager.set_normal_cursor()
		
		# If we found a pet to interact with, trigger the interaction
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
		return  # Already in game over state
	
	game_over = true
	print("Game Over! Pet: ", pet.pet_name)
	
	# Determine reason for game over
	var reason = ""
	
	if pet.satisfaction_level >= 100:
		reason = "Satisfaction Overflow"
		# Play good death animation
		if pet.has_method("play_animation_scene"):
			pet.play_animation_scene("good_death")
		else:
			# Fallback to old GIF system
			if pet.has_method("play_gif"):
				pet.play_gif("good_game_over")
	else:
		reason = "Wrath Overflow"
		# Play bad death animation
		if pet.has_method("play_animation_scene"):
			pet.play_animation_scene("bad_death")
		else:
			# Fallback to old GIF system
			if pet.has_method("play_gif"):
				pet.play_gif("game_over")
	
	# Wait for the animation to play before showing game over screen
	await get_tree().create_timer(3.0).timeout
	
	# Load game over scene
	var game_over_scene = load("res://scenes/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()
	
	# Initialize with game over details
	game_over_instance.initialize(pet.pet_name, reason, current_score)
	
	# Add to a new canvas layer to display on top
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Very high layer to be on top
	canvas_layer.add_child(game_over_instance)
	get_tree().root.add_child(canvas_layer)
	
	# Stop game logic
	get_tree().paused = true

# Reset game state for a new game
func reset_game():
	# Reset game flags
	game_over = false
	
	# Reset score
	current_score = 0
	
	# Clear any held objects/pets
	held_pet = null
	held_object = null
	
	# Clear registries
	pet_registry.clear()
	object_registry.clear()
	
	# Reset rates to default
	pet_spawn_rate = 1.0
	satisfaction_rate_multiplier = 1.0
	wrath_rate_multiplier = 1.0
	
	# Unpause the game
	get_tree().paused = false
