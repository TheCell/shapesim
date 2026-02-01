extends Camera2D

@export var drag_button: MouseButton = MOUSE_BUTTON_LEFT
@export var drag_sensitivity: float = 1.0

# Position on screen where ground center should appear (0.0 to 1.0)
var ground_center_screen_x: float = 1.1  # 2/3 to the right
var ground_center_screen_y: float = 0.5   # 1/2 in height

# Zoom (editor-controlled)
@export var zoom_step: float = 0.1
@export var zoom_min: float = 0.5
@export var zoom_max: float = 2.5

var _dragging := false

func _ready() -> void:
	make_current()
	_clamp_to_ground_bounds()

func set_camera_startpos() -> void:
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
		#_clamp_to_ground_bounds()

func _set_zoom_scalar(value: float) -> void:
	var z: float = clamp(value, zoom_min, zoom_max)
	zoom = Vector2(z, z)
	_clamp_to_ground_bounds()

func _clamp_to_ground_bounds() -> void:
	if GroundController.this == null:
		return
	
	var top_left := Vector2.ZERO
	var bottom_right := Vector2(GroundController.this.cornerBottomRight) * 32
	
	# Calculate ground center in world coordinates
	var ground_center := (top_left + bottom_right) * 0.5
	
	# Calculate viewport size in world units (accounts for zoom)
	var viewport_size := get_viewport_rect().size * zoom
	
	# Calculate offset to position ground center at desired screen position
	# If we want ground at 0.66 (66% to the right), that's 0.16 right of screen center
	# Camera must move left (negative) to make ground appear right on screen
	var screen_center := Vector2(0.5, 0.5)
	var desired_position := Vector2(ground_center_screen_x, ground_center_screen_y)
	var offset_normalized := desired_position - screen_center
	var center_offset := viewport_size * offset_normalized
	
	# Target position: ground center minus offset (move camera opposite direction)
	var target_position := ground_center - center_offset
	
	# Calculate clamping bounds
	var half_size := viewport_size * 0.5
	
	var min_x := top_left.x + half_size.x
	var max_x := bottom_right.x - half_size.x
	var min_y := top_left.y + half_size.y
	var max_y := bottom_right.y - half_size.y
	
	# Clamp to bounds
	if min_x > max_x:
		global_position.x = (top_left.x + bottom_right.x) * 0.5
	else:
		global_position.x = clamp(target_position.x, min_x, max_x)
	
	if min_y > max_y:
		global_position.y = (top_left.y + bottom_right.y) * 0.5
	else:
		global_position.y = clamp(target_position.y, min_y, max_y)
