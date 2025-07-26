extends Camera2D

# Camera movement settings
var move_speed = 500  # Camera movement speed
var room_width = 2000  # Width of the room (should match room.gd)
var room_height = 500  # Height of the room (should match room.gd)
var camera_width = 800  # Width of the camera view (from Globals.game_width)
var camera_height = 600  # Height of the camera view (from Globals.game_height)

# Camera limits
var min_x = 0
var max_x = 0

func _ready():
	# Set camera limits based on room size and camera size
	# We want to keep the camera within the room boundaries
	min_x = camera_width / 2.0
	max_x = room_width - camera_width / 2.0
	
	# Set camera limits
	limit_left = 0
	limit_right = room_width
	limit_top = 0
	limit_bottom = room_height
	
	# Set initial position
	position.x = min_x
	position.y = room_height / 2.0

func _process(delta):
	# Handle camera movement with arrow keys or WASD
	var movement = Vector2.ZERO
	
	# Check for keyboard input
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_d"):
		movement.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_a"):
		movement.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_s"):
		movement.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_w"):
		movement.y -= 1
	
	# Normalize movement vector to prevent diagonal movement from being faster
	if movement.length() > 0:
		movement = movement.normalized()
	
	# Apply movement
	position += movement * move_speed * delta
	
	# Clamp camera position to room boundaries
	position.x = clamp(position.x, min_x, max_x)
	position.y = clamp(position.y, room_height / 2.0, room_height / 2.0)  # Lock Y position
