extends Node

# Cursor textures
var cursor_normal = null
var cursor_dragging = null
var cursor_interactable = null

# Called when the node enters the scene tree for the first time
func _ready():
	# Load cursor textures
	cursor_normal = load("res://assets/potentially mouse_/freehand.png")
	cursor_dragging = load("res://assets/potentially mouse_/dragging.png")
	cursor_interactable = load("res://assets/potentially mouse_/interactable.png")
	
	# Set default cursor
	set_normal_cursor()

# Set cursor to normal state
func set_normal_cursor():
	Input.set_custom_mouse_cursor(cursor_normal)

# Set cursor to dragging state
func set_dragging_cursor():
	Input.set_custom_mouse_cursor(cursor_dragging)

# Set cursor to interactable state
func set_interactable_cursor():
	Input.set_custom_mouse_cursor(cursor_interactable)

# Reset cursor to default
func reset_cursor():
	Input.set_custom_mouse_cursor(null)
