extends Camera2D

@export var drag_button: MouseButton = MOUSE_BUTTON_LEFT
@export var drag_sensitivity: float = 1.0

# Zoom (editor-controlled)
@export var zoom_step: float = 0.1
@export var zoom_min: float = 0.5
@export var zoom_max: float = 2.5

var _dragging := false

func _ready() -> void:
	make_current()
	_clamp_to_ground_bounds()

# Use _input so UI doesn't block dragging.
func _input(event: InputEvent) -> void:
	# Drag start/stop
	if event is InputEventMouseButton and event.button_index == drag_button:
		_dragging = event.pressed
	
	# Wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_set_zoom_scalar(zoom.x + zoom_step) # zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_set_zoom_scalar(zoom.x - zoom_step) # zoom out
	# Drag motion (use screen delta -> world delta)
	if event is InputEventMouseMotion and _dragging:
		var world_delta : Vector2 = event.relative * zoom * drag_sensitivity
		global_position -= world_delta
		_clamp_to_ground_bounds()

func _set_zoom_scalar(value: float) -> void:
	var z: float = clamp(value, zoom_min, zoom_max)
	zoom = Vector2(z, z)
	_clamp_to_ground_bounds()

func _clamp_to_ground_bounds() -> void:
	if GroundController.this == null:
		return
	
	var top_left := Vector2.ZERO
	
	# IMPORTANT:
	# Make sure GroundController REALLY has cornerBottomRight.
	# If not, change this to boundsTopRight (or whatever your variable is).
	var bottom_right := Vector2(GroundController.this.cornerBottomRight) * 32
	
	# Half of visible size in world units (accounts for zoom)
	var half_size := get_viewport_rect().size * 0.5 * zoom
	
	var min_x := top_left.x + half_size.x
	var max_x := bottom_right.x - half_size.x
	var min_y := top_left.y + half_size.y
	var max_y := bottom_right.y - half_size.y
	# If world smaller than view, center camera
	if min_x > max_x:
		global_position.x = (top_left.x + bottom_right.x) * 0.5
	else:
		global_position.x = clamp(global_position.x, min_x, max_x)
	if min_y > max_y:
		global_position.y = (top_left.y + bottom_right.y) * 0.5
	else:
		global_position.y = clamp(global_position.y, min_y, max_y)
