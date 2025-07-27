extends Node2D
class_name Pet

# Pet properties
var pet_name: String = "Unknown Pet"
var draggable: bool = true
var hates_being_moved: bool = false
var moves_by_itself: bool = false
var preferred_objects = []
var forbidden_objects = []
var asprite = null

var interaction_scene: PackedScene = null 
var good_death_scene: PackedScene = null  
var bad_death_scene: PackedScene = null   
var current_animation_instance = null     

var satisfaction_level: float = 0
var wrath_level: float = 0
var satisfaction_decay_rate: float = 0.1
var wrath_increase_rate: float = 0.05

var is_being_held: bool = false
var is_interacting: bool = false
var is_moving: bool = false
var move_direction: Vector2 = Vector2.ZERO
var move_timer: float = 0.0
var idle_timer: float = 0.0

var sprite: Sprite2D = null
var animation_player: AnimationPlayer = null

var satisfaction_meter: ProgressBar = null
var wrath_meter: ProgressBar = null


func _ready():
	setup_collision()
	setup_meters()
	setup_pet_gifs() 


func _process(delta):
	if not is_interacting:
		satisfaction_level = max(0, satisfaction_level - satisfaction_decay_rate * delta * 10)
		wrath_level = min(100, wrath_level + wrath_increase_rate * delta * 10)
	
	update_meters()
	
	if is_being_held and draggable:
		global_position = get_global_mouse_position()
		
		var min_x = 50
		var max_x = Globals.room_width - 50
		var min_y = 50
		var max_y = Globals.room_height - 50
		global_position.x = clamp(global_position.x, min_x, max_x)
		global_position.y = clamp(global_position.y, min_y, max_y)
	else:
		if moves_by_itself and not is_interacting and not is_being_held:
			handleAutonomousMovement(delta)
		
	if satisfaction_level >= 100 or wrath_level >= 100:
		if not is_interacting:
			if satisfaction_level >= 100:
				play_animation("happy")
			else:
				play_animation("angry")
				
			Globals.end_game(self)

func setup_collision():
	if not has_node("Area2D"):
		var area = Area2D.new()
		area.name = "Area2D"
		
		var pet_width = 80
		var pet_height = 80
		var border = 10 
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(pet_width + border * 2, pet_height + border * 2)  # Add border on all sides
		collision.shape = shape
		area.add_child(collision)
		
		area.connect("input_event", _on_area_input_event)
		area.connect("mouse_entered", _on_mouse_entered)
		area.connect("mouse_exited", _on_mouse_exited)
		
		add_child(area)

func setup_pet_gifs():
	print("setting up gifs for pet type:", pet_name) 
	if pet_name == "Wet Owl":
		interaction_scene = load("res://scenes/death/owl.tscn")
		good_death_scene = load("res://scenes/death/owl.tscn")
		bad_death_scene = load("res://scenes/death/owl.tscn") 
		
	elif pet_name == "Gambling addict Pupols":
		interaction_scene = load("res://scenes/death/pupols_good.tscn")
		good_death_scene = load("res://scenes/death/pupols_good.tscn")
		bad_death_scene = load("res://scenes/death/pupols_good.tscn") 
		
	elif pet_name == "Toaster":
		interaction_scene = load("res://scenes/death/toster_good.tscn")
		good_death_scene = load("res://scenes/death/toster_good.tscn")
		bad_death_scene = load("res://scenes/death/toster_good.tscn") 


func play_animation_scene(animation_type = "interaction"):
	if current_animation_instance != null and is_instance_valid(current_animation_instance):
		current_animation_instance.queue_free()
		current_animation_instance = null
	
	print("animation type:", animation_type)
	var scene_to_use = null
	if animation_type == "interaction":
		scene_to_use = interaction_scene
	elif animation_type == "good_death":
		scene_to_use = good_death_scene
	elif animation_type == "bad_death":
		scene_to_use = bad_death_scene
	else:
		print("No scene to use")
	
	if scene_to_use:
		var instance = scene_to_use.instantiate()
		instance.position = Vector2(0, 0)
		add_child(instance)
		current_animation_instance = instance
		if instance.has_node("AnimatedSprite2D"):
			var anim_sprite = instance.get_node("AnimatedSprite2D")
			anim_sprite.position = Vector2.ZERO
			if animation_type == "interaction":
				anim_sprite.play("interaction")
			elif animation_type == "good_death":
				anim_sprite.play("good")
			elif animation_type == "bad_death":
				anim_sprite.play("bad")
			
			var timer = get_tree().create_timer(7.0)
			await timer.timeout
			
			if current_animation_instance != null and is_instance_valid(current_animation_instance):
				current_animation_instance.queue_free()
				current_animation_instance = null
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
			else:
				if Globals.is_holding_pet() and Globals.held_pet == self:
					Globals.drop_pet()

func _on_mouse_entered():
	if draggable:
		scale = Vector2(1.1, 1.1)

func _on_mouse_exited():
	scale = Vector2(1.0, 1.0)

func set_held(held):
	is_being_held = held
	if held and hates_being_moved:
		wrath_level += 10
		play_animation("angry")
		update_meters()
	if held:
		z_index = 10 
	else:
		z_index = 0

func interact_with_object(object):
	is_interacting = true
	print("interacting")
	print(object.name)
	
	if object.name in preferred_objects:
		play_animation_scene("interaction")
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
	var asprite = get_node("AnimatedSprite2D")
	if is_moving:
		move_timer -= delta
		if move_timer <= 0:
			is_moving = false
			idle_timer = randf_range(1.0, 4.0)
			play_animation("idle")
			asprite.play("neutral")
		else:
			asprite.play("walk")
			global_position.x += move_direction.x * delta * 50 # Movement speed
			var room_width = Globals.room_width
			global_position.x = clamp(global_position.x, 50, room_width - 50)
			
			if has_node("Sprite") or has_node("AnimatedSprite2D"):
				if has_node("Sprite2D"):
					$Sprite2D.flip_h = move_direction.x < 0
				elif has_node("AnimatedSprite2D"):
					asprite.flip_h = move_direction.x < 0
	else:
		idle_timer -= delta
		if idle_timer <= 0:
			is_moving = true
			move_timer = randf_range(0.5, 2.0) 
			
			var direction = 1 if randf() > 0.5 else -1
			move_direction = Vector2(direction, 0).normalized()
			
			asprite = get_node("AnimatedSprite2D")
			asprite.play("walk")
			play_animation("walk")

func play_animation(anim_name):
	if has_node("AnimatedSprite2D"):
		var animated_sprite = get_node("AnimatedSprite2D")
		if anim_name == "happy":
			animated_sprite.modulate = Color(0.8, 1.0, 0.8)
		elif anim_name == "angry":
			animated_sprite.modulate = Color(1.0, 0.6, 0.6)
		else:
			animated_sprite.modulate = Color(1.0, 1.0, 1.0)
			
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1), 2.0)

func _on_Area2D_mouse_entered():
	if has_node("MeterPanel"):
		get_node("MeterPanel").visible = true

func _on_Area2D_mouse_exited():
	if has_node("MeterPanel"):
		get_node("MeterPanel").visible = false
