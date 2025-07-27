extends Node2D
class_name GameObject

const PetClass = preload("res://scripts/pet.gd")

var object_name = "Unknown Object"
var is_zone = false
var draggable = true
var used_by_pet = null 
var is_being_held = false

var sprite: Sprite2D
var animation_player: AnimationPlayer


func _ready():
	setup_visuals()
	setup_collision()

func _process(delta):
	if is_being_held and draggable:
		var mouse_pos = get_global_mouse_position()
		mouse_pos.x = clamp(mouse_pos.x, 50, Globals.room_width - 50)
		mouse_pos.y = clamp(mouse_pos.y, 50, Globals.room_height - 50)
		
		var interpolation_weight = min(1.0, 25.0 * delta)
		global_position = global_position.lerp(mouse_pos, interpolation_weight)

func setup_visuals():
	if not has_node("AnimationPlayer"):
		animation_player = AnimationPlayer.new()
		animation_player.name = "AnimationPlayer"
		add_child(animation_player)

func setup_collision():
	if not has_node("Area2D"):
		var area = Area2D.new()
		area.name = "Area2D"
		
		var obj_width = 80
		var obj_height = 80
		var border = 10
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(obj_width + border * 2, obj_height + border * 2)
		collision.shape = shape
		area.add_child(collision)
		
		area.connect("input_event", _on_area_input_event)
		area.connect("mouse_entered", _on_mouse_entered)
		area.connect("mouse_exited", _on_mouse_exited)
		area.connect("area_entered", _on_area_entered)
		area.connect("area_exited", _on_area_exited)
		
		add_child(area)

func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if draggable and not is_zone and used_by_pet == null:
					is_being_held = true
					z_index = 10
					Globals.hold_object(self)
				elif is_zone:
					if Globals.is_holding_pet():
						var pet = Globals.held_pet
						pet_interact(pet)
			else:
				if is_being_held:
					release()
					Globals.release_object()
						
func _on_mouse_entered():
	if draggable and not is_zone:
		scale = Vector2(1.1, 1.1)

func _on_mouse_exited():
	scale = Vector2(1.0, 1.0)

func _on_area_entered(area):
	if is_zone and area.get_parent() is PetClass:
		var pet = area.get_parent()
		pet_interact(pet)

func _on_area_exited(area):
	if is_zone and used_by_pet != null and area.get_parent() == used_by_pet:
		used_by_pet = null

func release():
	is_being_held = false
	z_index = 0
	
	var ground_y = Globals.room_height - 50
	var drop_tween = create_tween()
	var start_y = global_position.y
	var drop_distance = ground_y - start_y
	var drop_duration = max(0.1, min(0.5, drop_distance / 500))
	
	drop_tween.tween_property(self, "global_position:y", ground_y, drop_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	drop_tween.tween_property(self, "global_position:y", ground_y - 10, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	drop_tween.tween_property(self, "global_position:y", ground_y, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	var min_x = 50
	var max_x = Globals.room_width - 50
	global_position.x = clamp(global_position.x, min_x, max_x)

func pet_interact(pet):
	used_by_pet = pet
	pet.interact_with_object(self)
	
	if object_name in pet.preferred_objects:
		create_sparkle_effect()
		pet.get_node("AnimatedSprite2D").play("happy")
		play_interaction_animation("preferred")
		Globals.add_score(10)
	elif object_name in pet.forbidden_objects:
		create_anger_effect()
		pet.get_node("AnimatedSprite2D").play("angry")
		play_interaction_animation("forbidden")
	else:
		pet.get_node("AnimatedSprite2D").play("neutral")
		play_interaction_animation("neutral")
	
	await get_tree().create_timer(2.0).timeout
	
	used_by_pet = null
	if not is_zone:
		Globals.remove_object(self)
		queue_free()

func play_interaction_animation(interaction_type = "neutral"):
	var tween = create_tween()
	
	print("interaction_type:", interaction_type)
	
	if interaction_type == "preferred":
		modulate = Color(0.8, 1.5, 0.8)  # Green glow
		tween.tween_property(self, "modulate", Color(1, 1, 1), 1.5)
	elif interaction_type == "forbidden":
		modulate = Color(1.5, 0.5, 0.5)  # Red flash
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.8)
	else: # neutral
		modulate = Color(1.2, 1.2, 1.2)  # Slight brighten
		tween.tween_property(self, "modulate", Color(1, 1, 1), 1.0)
	
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)

func create_sparkle_effect():
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
	particles.color = Color(1, 1, 0.5)
	
	add_child(particles)
	
	await get_tree().create_timer(1.5).timeout
	particles.queue_free()

func create_anger_effect():
	var particles = CPUParticles2D.new()
	particles.position = Vector2(0, -40)
	particles.emitting = true
	particles.amount = 8
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.7
	particles.direction = Vector2(0, -1)
	particles.spread = 90
	particles.gravity = Vector2(0, 30)
	particles.initial_velocity_min = 60
	particles.color = Color(0.8, 0.1, 0.1)
	
	add_child(particles)
	await get_tree().create_timer(1.5).timeout
	particles.queue_free()
