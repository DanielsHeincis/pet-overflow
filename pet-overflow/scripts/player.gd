extends CharacterBody2D

# Camera movement properties
const CAMERA_SPEED = 500.0
var room_min_x = 0
var room_max_x = 2000  # Will be set based on room size

# Screen boundaries
var view_width = 800
var view_height = 600
var camera_bounds = Vector2(45, 45)  # Border size

# Player state
var holding_pet = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up the camera
	if not has_node("Camera2D"):
		var camera = Camera2D.new()
		camera.name = "Camera2D"
		camera.make_current()
		
		# Set camera limits
		camera.limit_left = room_min_x
		camera.limit_right = room_max_x
		
		add_child(camera)
	
	# Initialize player position
	position = Vector2(float(view_width) / 2.0, float(view_height) / 2.0)
	
	# Register with globals
	Globals.player = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle camera movement
	process_camera_movement(delta)
	
	# Handle dropping pets
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("click"):
		if Globals.is_holding_pet():
			Globals.drop_pet()

# Process camera movement based on input
func process_camera_movement(delta):
	var direction = Vector2.ZERO
	
	# Horizontal movement
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	elif Input.is_action_pressed("ui_left"):
		direction.x -= 1
	
	# Vertical movement - limited in this game
	if Input.is_action_pressed("ui_down"):
		direction.y += 0.5  # Less vertical movement
	elif Input.is_action_pressed("ui_up"):
		direction.y -= 0.5  # Less vertical movement
	
	# Apply movement
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * CAMERA_SPEED
	else:
		velocity = Vector2.ZERO
	
	# Move the player (camera follows)
	position += velocity * delta
	
	# Constrain to room bounds
	position.x = clamp(position.x, room_min_x + float(view_width)/2.0 - camera_bounds.x, 
				room_max_x - float(view_width)/2.0 + camera_bounds.x)
	position.y = clamp(position.y, float(view_height)/2.0, 
				float(view_height)/2.0)  # Keep vertical position fixed

# Set the room size based on the current room
func set_room_bounds(min_x, max_x):
	room_min_x = min_x
	room_max_x = max_x
	
	# Update camera limits
	if has_node("Camera2D"):
		var camera = get_node("Camera2D")
		camera.limit_left = room_min_x
		camera.limit_right = room_max_x
