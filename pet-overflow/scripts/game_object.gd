extends Node2D
class_name GameObject

# Need to preload Pet class to avoid circular reference issues
const PetClass = preload("res://scripts/pet.gd")

# Object properties
var object_name = "Unknown Object"
var is_zone = false  # If true, this is a static zone like a bath
var draggable = true  # Most objects can be moved unless they're zones
var used_by_pet = null  # Track which pet is using this object

# Visual elements
var sprite: Sprite2D
var animation_player: AnimationPlayer

# State
var is_being_held = false

func _ready():
	# Setup visuals
	setup_visuals()
	setup_collision()

func _process(delta):
	# Follow mouse if being held - with interpolation for smoother movement
	if is_being_held and draggable:
		# Follow mouse position but keep within screen bounds
		var mouse_pos = get_global_mouse_position()
		# Clamp to room boundaries with some margin
		mouse_pos.x = clamp(mouse_pos.x, 50, Globals.room_width - 50)
		mouse_pos.y = clamp(mouse_pos.y, 50, Globals.room_height - 50)
		
		# Use interpolation for smoother movement (lerp)
		# Adjust the interpolation weight based on delta time
		# Higher values (closer to 1) make movement more responsive but potentially less smooth
		# Lower values (closer to 0) make movement smoother but potentially more laggy
		var interpolation_weight = min(1.0, 25.0 * delta) # Adjust this value as needed
		global_position = global_position.lerp(mouse_pos, interpolation_weight)

# Setup visual components
func setup_visuals():
	# Create a temporary sprite if not already set up
	if not has_node("Sprite"):
		sprite = Sprite2D.new()
		sprite.name = "Sprite"
		
		# Use a placeholder color rect until proper sprites are added
		var obj_color = ColorRect.new()
		obj_color.size = Vector2(80, 80)
		if is_zone:
			obj_color.color = Color(0.2, 0.8, 0.2)
		else:
			obj_color.color = Color(0.8, 0.2, 0.8)
		sprite.add_child(obj_color)
		
		add_child(sprite)
	
	# Add animation player if needed
	if not has_node("AnimationPlayer"):
		animation_player = AnimationPlayer.new()
		animation_player.name = "AnimationPlayer"
		add_child(animation_player)

# Setup collision for interaction
func setup_collision():
	# Add area for interaction
	if not has_node("Area2D"):
		var area = Area2D.new()
		area.name = "Area2D"
		
		# Get the object's visual size (typically 80x80) and add a small border
		var obj_width = 80
		var obj_height = 80
		var border = 10  # 10 pixel border around the object
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(obj_width + border * 2, obj_height + border * 2)  # Add border on all sides
		collision.shape = shape
		area.add_child(collision)
		
		area.connect("input_event", _on_area_input_event)
		area.connect("mouse_entered", _on_mouse_entered)
		area.connect("mouse_exited", _on_mouse_exited)
		area.connect("area_entered", _on_area_entered)
		area.connect("area_exited", _on_area_exited)
		
		add_child(area)

# Handle being picked up or released
func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Try to pick up if not a zone and not being used by a pet
				if draggable and not is_zone and used_by_pet == null:
					is_being_held = true
					z_index = 10  # Bring to front
					# Register with globals that we're holding this object
					Globals.hold_object(self)
				elif is_zone:
					# Check if there's a pet being held that can be dropped here
					if Globals.is_holding_pet():
						var pet = Globals.held_pet
						# Trigger interaction
						pet_interact(pet)
			else: # Mouse button released
				# Release the object if we're holding it
				if is_being_held:
					release()
					# Tell globals we're no longer holding this object
					Globals.release_object()
						
func _on_mouse_entered():
	# Visual feedback on hover
	if draggable and not is_zone:
		scale = Vector2(1.1, 1.1)

func _on_mouse_exited():
	# Reset scale on mouse exit
	scale = Vector2(1.0, 1.0)

func _on_area_entered(area):
	if is_zone and area.get_parent() is PetClass:
		var pet = area.get_parent()
		pet_interact(pet)

func _on_area_exited(area):
	# Pet left the zone
	if is_zone and used_by_pet != null and area.get_parent() == used_by_pet:
		used_by_pet = null

# Handle dropping the object
func release():
	is_being_held = false
	z_index = 0
	
	# Make the object drop to the ground with a falling animation
	var ground_y = Globals.room_height - 50  # Ground level with some offset for the object's height
	
	# Create a more realistic gravity effect with better tween settings
	var drop_tween = create_tween()
	# Start with current position
	var start_y = global_position.y
	# Calculate drop duration based on distance (faster fall from higher positions)
	var drop_distance = ground_y - start_y
	var drop_duration = max(0.1, min(0.5, drop_distance / 500))
	
	# Use CUBIC ease for more natural gravity acceleration
	drop_tween.tween_property(self, "global_position:y", ground_y, drop_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	# Add a small bounce at the end
	drop_tween.tween_property(self, "global_position:y", ground_y - 10, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	drop_tween.tween_property(self, "global_position:y", ground_y, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Ensure the object stays within the room bounds
	var min_x = 50  # Left boundary with offset
	var max_x = Globals.room_width - 50  # Right boundary with offset
	global_position.x = clamp(global_position.x, min_x, max_x)

# When a pet interacts with this object
func pet_interact(pet):
	used_by_pet = pet
	
	if pet.has_method("interact_with_object"):
		pet.interact_with_object(self)
		
	if object_name in pet.preferred_objects:
		play_interaction_animation("preferred")
		create_sparkle_effect()
		Globals.add_score(10)
	elif object_name in pet.forbidden_objects:
		play_interaction_animation("forbidden")
		create_anger_effect()
	else:
		play_interaction_animation("neutral")
	
	# After interaction time
	await get_tree().create_timer(2.0).timeout
	
	# Clean up references
	used_by_pet = null
	
	# Remove the object from the registry and delete it
	if not is_zone:  # Don't delete zones, only consumable objects
		Globals.remove_object(self)
		queue_free()

# Play the interaction animation
func play_interaction_animation(interaction_type = "neutral"):
	# Will be implemented with proper animations
	# For now, just show a visual indication based on interaction type
	var tween = create_tween()
	
	if interaction_type == "preferred":
		# Happy interaction - green glow
		modulate = Color(0.8, 1.5, 0.8)  # Green glow
		tween.tween_property(self, "modulate", Color(1, 1, 1), 1.5)
	elif interaction_type == "forbidden":
		# Bad interaction - red flash
		modulate = Color(1.5, 0.5, 0.5)  # Red flash
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.8)
	else: # neutral
		# Normal interaction - slight brighten
		modulate = Color(1.2, 1.2, 1.2)  # Slight brighten
		tween.tween_property(self, "modulate", Color(1, 1, 1), 1.0)
	
	# Also animate scale for feedback
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)

# Create sparkle effect for positive interactions
func create_sparkle_effect():
	# Create particles for sparkles
	var particles = CPUParticles2D.new()
	particles.position = Vector2(0, 0)
	particles.emitting = true
	particles.amount = 16
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.gravity = Vector2(0, 98)
	particles.initial_velocity_min = 100
	#particles.scale_amount = 4
	particles.color = Color(1, 1, 0.5) # Yellow sparkles
	
	add_child(particles)
	
	# Remove after effect is done
	await get_tree().create_timer(1.5).timeout
	particles.queue_free()

# Create anger effect for negative interactions
func create_anger_effect():
	# Create particles for anger
	var particles = CPUParticles2D.new()
	particles.position = Vector2(0, -40) # Above the object
	particles.emitting = true
	particles.amount = 8
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.7
	particles.direction = Vector2(0, -1)
	particles.spread = 90
	particles.gravity = Vector2(0, 30)
	particles.initial_velocity_min = 60
	#particles.scale_amount = 5
	particles.color = Color(0.8, 0.1, 0.1) # Red anger
	
	add_child(particles)
	
	# Remove after effect is done
	await get_tree().create_timer(1.5).timeout
	particles.queue_free()
