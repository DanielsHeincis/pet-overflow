extends Node2D
class_name Pet

# Pet properties
var pet_name: String = "Unknown Pet"
var draggable: bool = true  # Some pets may not be movable
var hates_being_moved: bool = false # Some pets hate being moved
var moves_by_itself: bool = false # Some pets move on their own
var preferred_objects = []  # Objects that satisfy this pet
var forbidden_objects = []  # Objects that make pet angry

# Meters
var satisfaction_level: float = 0  # 0-100
var wrath_level: float = 0  # 0-100
var satisfaction_decay_rate: float = 0.1  # How fast satisfaction decreases
var wrath_increase_rate: float = 0.05  # How fast wrath increases

# State
var is_being_held: bool = false
var is_interacting: bool = false
var is_moving: bool = false
var move_direction: Vector2 = Vector2.ZERO
var move_timer: float = 0.0
var idle_timer: float = 0.0

# Visual components
var sprite: Sprite2D = null
var animation_player: AnimationPlayer = null

# UI components
var satisfaction_meter: ProgressBar = null
var wrath_meter: ProgressBar = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup base components
	setup_visuals()
	setup_collision()
	setup_meters()
	
	# Connect input events - handled by Area2D instead
	# No direct input_event connection needed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update meters over time if not interacting
	if not is_interacting:
		satisfaction_level = max(0, satisfaction_level - satisfaction_decay_rate * delta * 10)
		wrath_level = min(100, wrath_level + wrath_increase_rate * delta * 10)
	
	# Update UI
	update_meters()
	
	# Follow mouse if being held
	if is_being_held and draggable:
		global_position = get_global_mouse_position()
	else:
		# Handle autonomous pet movement if not being held or interacting
		if moves_by_itself and not is_interacting and not is_being_held:
			handleAutonomousMovement(delta)
		
	# Check for overflow conditions
	if satisfaction_level >= 100 or wrath_level >= 100:
		# Pet is going to explode (satisfaction) or rampage (wrath)!
		if not is_interacting:
			if satisfaction_level >= 100:
				play_animation("happy")
			else:
				play_animation("angry")
				
			# Let globals handle the game over
			Globals.end_game(self)

# Setup visual components
func setup_visuals():
	# Create sprite if not present
	if not has_node("AnimatedSprite2D"):
		# If no animated sprite exists, create a basic visualization
		var sprite_node = Node2D.new()
		sprite_node.name = "Sprite"
		add_child(sprite_node)
		
		# Add simple color rect as visual
		var rect = ColorRect.new()
		rect.size = Vector2(100, 100)
		rect.position = Vector2(-50, -50)
		rect.color = Color(0.5, 0.5, 0.9) # Default blue color
		sprite_node.add_child(rect)
	
	# Create collision shape if not present
	if not has_node("CollisionShape2D"):
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 50
		shape.shape = circle
		add_child(shape)

# Setup collision for interaction
func setup_collision():
	# Add area for interaction
	if not has_node("Area2D"):
		var area = Area2D.new()
		area.name = "Area2D"
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(100, 100)
		collision.shape = shape
		area.add_child(collision)
		
		area.connect("input_event", _on_area_input_event)
		area.connect("mouse_entered", _on_mouse_entered)
		area.connect("mouse_exited", _on_mouse_exited)
		
		add_child(area)

# Setup UI meters
func setup_meters():
	# Create container
	var meter_container = VBoxContainer.new()
	meter_container.name = "Meters"
	meter_container.position = Vector2(-50, -130)
	meter_container.size = Vector2(100, 50)
	
	# Satisfaction meter
	satisfaction_meter = ProgressBar.new()
	satisfaction_meter.max_value = 100
	satisfaction_meter.value = satisfaction_level
	satisfaction_meter.size.x = 100
	
	var sat_label = Label.new()
	sat_label.text = "Satisfaction"
	sat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Wrath meter
	wrath_meter = ProgressBar.new()
	wrath_meter.max_value = 100
	wrath_meter.value = wrath_level
	wrath_meter.size.x = 100
	
	var wrath_label = Label.new()
	wrath_label.text = "Wrath"
	wrath_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Add to container
	meter_container.add_child(sat_label)
	meter_container.add_child(satisfaction_meter)
	meter_container.add_child(wrath_label)
	meter_container.add_child(wrath_meter)
	
	add_child(meter_container)

# Update UI meters
func update_meters():
	# Update the progress bar values if they exist
	if satisfaction_meter:
		satisfaction_meter.value = satisfaction_level
		
	if wrath_meter:
		wrath_meter.value = wrath_level
	
	# For backwards compatibility, also check for direct nodes
	if has_node("SatisfactionBar"):
		get_node("SatisfactionBar").value = satisfaction_level
		
	if has_node("WrathBar"):
		get_node("WrathBar").value = wrath_level

# Handle being picked up
func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Try to pick up
				if draggable and not Globals.is_holding_pet():
					Globals.hold_pet(self)
				else:
					# Increase wrath if tried to pick up non-draggable pet
					if not draggable:
						wrath_level += 10
						# Visual feedback
						modulate = Color(1, 0, 0)
						var tween = create_tween()
						tween.tween_property(self, "modulate", Color(1, 1, 1), 0.5)

# Mouse hover feedback
func _on_mouse_entered():
	if draggable:
		scale = Vector2(1.1, 1.1)

# Mouse exit feedback
func _on_mouse_exited():
	scale = Vector2(1.0, 1.0)

# Detect when the pet is grabbed or released
func set_held(held):
	is_being_held = held
	
	# If pet hates being moved, increase wrath when picked up
	if held and hates_being_moved:
		wrath_level += 10
		play_animation("angry")
		update_meters()
	if held:
		z_index = 10  # Bring to front
	else:
		z_index = 0

# Interact with an object
func interact_with_object(object):
	is_interacting = true
	
	if object.name in preferred_objects:
		play_animation("happy")
		satisfaction_level += 20
		wrath_level = max(0, wrath_level - 10)
	elif object.name in forbidden_objects:
		play_animation("angry")
		wrath_level += 15
	else:
		play_animation("neutral")
		wrath_level = max(0, wrath_level - 5)
	
	await get_tree().create_timer(2.0).timeout
	is_interacting = false

func handleAutonomousMovement(delta):
	if is_moving:
		move_timer -= delta
		if move_timer <= 0:
			is_moving = false
			idle_timer = randf_range(1.0, 4.0)
			play_animation("idle")
		else:
			# Continue moving in the current direction - HORIZONTAL ONLY
			# Y position stays the same to keep pet on the ground
			global_position.x += move_direction.x * delta * 50 # Movement speed
			
			# Keep pet within room bounds
			var room_width = Globals.room_width
			global_position.x = clamp(global_position.x, 50, room_width - 50)
			
			# Flip sprite based on movement direction
			if has_node("Sprite") or has_node("AnimatedSprite2D"):
				if move_direction.x < 0:
					scale.x = -1 * abs(scale.x) # Face left
				else:
					scale.x = abs(scale.x) # Face right
	else:
		idle_timer -= delta
		if idle_timer <= 0:
			# Start moving in a random direction - HORIZONTAL ONLY
			is_moving = true
			move_timer = randf_range(0.5, 2.0) # Random movement time between 0.5-2 seconds
			
			# Choose a random horizontal direction (left or right)
			# 50% chance of going left, 50% chance of going right
			var direction = 1 if randf() > 0.5 else -1
			move_direction = Vector2(direction, 0).normalized()
			play_animation("walk")

# Play animation
func play_animation(anim_name):
	# Handle animations
	if has_node("AnimatedSprite2D"):
		var animated_sprite = get_node("AnimatedSprite2D")
		if anim_name == "happy":
			animated_sprite.modulate = Color(0.8, 1.0, 0.8) # Green tint
			animated_sprite.speed_scale = 2.0 # Speed up
		elif anim_name == "angry":
			animated_sprite.modulate = Color(1.0, 0.6, 0.6) # Red tint
			animated_sprite.speed_scale = 1.5 # Speed up
		else: # neutral
			animated_sprite.modulate = Color(1.0, 1.0, 1.0) # Normal
			animated_sprite.speed_scale = 1.0
			
		# Create a tween to reset the modulate after animation
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1), 2.0)
	else:
		# For pets using ColorRect placeholder
		if has_node("Sprite/ColorRect"):
			var color_rect = get_node("Sprite/ColorRect")
			var original_color = color_rect.color
			var tween = create_tween()
			
			if anim_name == "happy":
				# Brighten the color
				color_rect.color = Color(
					original_color.r * 1.2, 
					original_color.g * 1.2, 
					original_color.b * 0.8)
			elif anim_name == "angry":
				# Redden the color
				color_rect.color = Color(
					min(original_color.r * 1.5, 1.0), 
					original_color.g * 0.5, 
					original_color.b * 0.5)
				
			# Reset color after animation
			tween.tween_property(color_rect, "color", original_color, 2.0)
