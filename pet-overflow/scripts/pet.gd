extends Node2D
class_name Pet

# Pet properties
var pet_name: String = "Unknown Pet"
var pet_type: String = "Generic"
var draggable: bool = true  # Some pets may not be movable
var hates_being_moved: bool = false # Some pets hate being moved
var moves_by_itself: bool = false # Some pets move on their own
var preferred_objects = []  # Objects that satisfy this pet
var forbidden_objects = []  # Objects that make pet angry

# GIF animation properties
var interaction_gif: String = "ytuh.gif"  # Default interaction GIF
var game_over_gif: String = "skeleton-burning.gif"  # Default game over GIF
var good_game_over_gif: String = "catkill.gif"  # Default game over GIF
var gif_duration: float = 3.0  # Default duration in seconds
var gif_player: AnimatedSprite2D = null  # AnimatedSprite2D for playing GIFs

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
	setup_pet_gifs()  # Set up pet-specific GIFs
	setup_gif_player()
	
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
	# Check if we already have a proper sprite
	if has_node("AnimatedSprite2D") or has_node("Sprite2D") or has_node("Sprite"):
		return
		
	# Create a more distinctive pet placeholder instead of a blue rectangle
	var sprite_node = Node2D.new()
	sprite_node.name = "Sprite"
	add_child(sprite_node)
	
	# Create a more pet-like shape with multiple parts
	# Body
	var body = ColorRect.new()
	body.size = Vector2(80, 60)
	body.position = Vector2(-40, -40)
	
	# Randomize color to distinguish different pets
	var r = randf_range(0.4, 0.9)
	var g = randf_range(0.4, 0.9)
	var b = randf_range(0.4, 0.9)
	body.color = Color(r, g, b)
	sprite_node.add_child(body)
	
	# Head
	var head = ColorRect.new()
	head.size = Vector2(40, 40)
	head.position = Vector2(-20, -60)
	head.color = body.color.lightened(0.2) # Slightly lighter than body
	sprite_node.add_child(head)
	
	# Eyes
	var left_eye = ColorRect.new()
	left_eye.size = Vector2(8, 8)
	left_eye.position = Vector2(-15, -55)
	left_eye.color = Color(0, 0, 0) # Black eyes
	sprite_node.add_child(left_eye)
	
	var right_eye = ColorRect.new()
	right_eye.size = Vector2(8, 8)
	right_eye.position = Vector2(7, -55)
	right_eye.color = Color(0, 0, 0) # Black eyes
	sprite_node.add_child(right_eye)
	
	# Add pet name label
	var name_label = Label.new()
	name_label.text = pet_name
	name_label.position = Vector2(-40, -90)
	name_label.size = Vector2(80, 20)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font_settings = LabelSettings.new()
	font_settings.font_size = 12
	font_settings.outline_size = 1
	font_settings.outline_color = Color(0, 0, 0)
	name_label.label_settings = font_settings
	sprite_node.add_child(name_label)
	
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
		
		# Get the pet's visual size (body is 80x80) and add a small border
		var pet_width = 80
		var pet_height = 80
		var border = 10  # 10 pixel border around the pet
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(pet_width + border * 2, pet_height + border * 2)  # Add border on all sides
		collision.shape = shape
		area.add_child(collision)
		
		area.connect("input_event", _on_area_input_event)
		area.connect("mouse_entered", _on_mouse_entered)
		area.connect("mouse_exited", _on_mouse_exited)
		
		add_child(area)

# Setup pet-specific GIFs based on pet type
func setup_pet_gifs():
	# Assign different GIFs and durations based on pet type
	
	if pet_type == "WetOwl":
		interaction_gif = "ytuh.gif"
		game_over_gif = "skeleton-burning.gif"
		good_game_over_gif = "catkill.gif"
		gif_duration = 4.0  # Longer duration
	elif pet_type == "Pupols":
		interaction_gif = "ytuh.gif"
		game_over_gif = "skeleton-burning.gif"
		good_game_over_gif = "catkill.gif"
		gif_duration = 2.5  # Medium duration
	elif pet_type == "Julija":
		interaction_gif = "ytuh.gif"
		game_over_gif = "skeleton-burning.gif"
		good_game_over_gif = "catkill.gif"
		gif_duration = 3.0  # Default duration

	print("setup pet gifs")
	print(pet_type)
	print(interaction_gif)
	print(game_over_gif)
	print(good_game_over_gif)
	print(gif_duration)

# Setup GIF player for animations
func setup_gif_player():
	# Create AnimatedSprite2D for GIF playback
	if not has_node("GifPlayer"):
		gif_player = AnimatedSprite2D.new()
		gif_player.name = "GifPlayer"
		gif_player.visible = false  # Hidden by default
		gif_player.position = Vector2(0, -60)  # Position above the pet
		gif_player.scale = Vector2(1.5, 1.5)  # Scale up for visibility
		add_child(gif_player)

# Play a GIF animation
func play_gif(gif_type = "interaction"):
	if not gif_player:
		print("no gif player")
		return
	
	# Determine which GIF to play
	var gif_path = "res://assets/"
	if gif_type == "interaction":
		gif_path += interaction_gif
	else:  # game_over
		gif_path += game_over_gif

	print("playing gif: " + gif_path)
	
	# Load the GIF as SpriteFrames
	var frames = load_gif_frames(gif_path)
	if frames:
		print("loaded gif frames")
		gif_player.sprite_frames = frames
		gif_player.visible = true
		gif_player.play("default")
		
		# Hide after duration
		await get_tree().create_timer(gif_duration).timeout
		gif_player.visible = false
		gif_player.stop()
	else:
		print("failed to load gif frames")

# Helper function to load GIF frames
func load_gif_frames(gif_path):
	# In a real implementation, we would load the GIF and convert it to SpriteFrames
	# For this prototype, we'll create a simple animation with a single frame
	var frames = SpriteFrames.new()
	var texture = load(gif_path)
	if texture:
		frames.add_animation("default")
		frames.add_frame("default", texture)
		return frames
	return null

# Setup UI meters
func setup_meters():
	# Panel background
	var meter_panel = Panel.new()
	meter_panel.name = "MeterPanel"
	meter_panel.position = Vector2(-55, -135)
	meter_panel.size = Vector2(110, 100)

	# Style for the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6)  # Semi-transparent black
	style.set_border_width_all(2)
	style.border_color = Color(1, 1, 1)
	meter_panel.add_theme_stylebox_override("panel", style)

	# Container inside the panel
	var meter_container = VBoxContainer.new()
	meter_container.anchor_right = 1.0
	meter_container.anchor_bottom = 1.0
	meter_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	meter_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	meter_container.anchor_left = 0.0
	meter_container.anchor_top = 0.0
	meter_container.anchor_right = 1.0
	meter_container.anchor_bottom = 1.0

	meter_container.offset_left = 5
	meter_container.offset_top = 5
	meter_container.offset_right = -5
	meter_container.offset_bottom = -5

	# Satisfaction label + bar
	var sat_label = Label.new()
	sat_label.text = "Satisfaction"
	sat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	satisfaction_meter = ProgressBar.new()
	satisfaction_meter.max_value = 100
	satisfaction_meter.value = satisfaction_level
	satisfaction_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Wrath label + bar
	var wrath_label = Label.new()
	wrath_label.text = "Wrath"
	wrath_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	wrath_meter = ProgressBar.new()
	wrath_meter.max_value = 100
	wrath_meter.value = wrath_level
	wrath_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Add all to container
	meter_container.add_child(sat_label)
	meter_container.add_child(satisfaction_meter)
	meter_container.add_child(wrath_label)
	meter_container.add_child(wrath_meter)

	# Add container to panel and panel to pet
	meter_panel.add_child(meter_container)
	add_child(meter_panel)

	# Hide by default (for hover logic)
	meter_panel.visible = false

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


# Handle being picked up or dropped
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
			else: # Button released
				# Drop the pet if we're holding it
				if Globals.is_holding_pet() and Globals.held_pet == self:
					Globals.drop_pet()

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
	print("interacting")
	print(object.name)
	# Play the interaction GIF animation
	play_gif("interaction")
	
	if object.name in preferred_objects:
		print("satisfaction increse")
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
				if has_node("Sprite2D"):
					$Sprite2D.flip_h = move_direction.x < 0
				elif has_node("AnimatedSprite2D"):
					$AnimatedSprite2D.flip_h = move_direction.x < 0
				#else:
				#	scale.x = abs(scale.x) # Face right
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

func _on_Area2D_mouse_entered():
	if has_node("MeterPanel"):
		get_node("MeterPanel").visible = true

func _on_Area2D_mouse_exited():
	if has_node("MeterPanel"):
		get_node("MeterPanel").visible = false
