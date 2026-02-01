extends Control

enum States { INACTIVE, CHOOSING_SHAPEORABILITY, CHOOSING_ABILITY, CHOOSING_SHAPE }

# Point these to your three containers in the scene.
@onready var select_ability_or_shape_container: Control = %ButtonContainer
@onready var select_ability_container: Control = %AbilityButttonContainer
@onready var select_shape_container: Control = %ShapeButtonContainer

@export var configureAbilityButton: MouseButton = MOUSE_BUTTON_RIGHT

@onready var buttonScene: PackedScene = preload("res://GodAbility/buttonScene.tscn")

@export var radius: float = 150.0
@export var animationSpeed: float = 0.25

var state: States = States.INACTIVE
var active := false
var centerPosition: Vector2

func _ready() -> void:
	# Start hidden
	select_ability_or_shape_container.hide()
	select_ability_container.hide()
	select_shape_container.hide()
	
	# Create dynamic buttons
	_spawn_ability_buttons()
	_spawn_shape_buttons()
	
	# Wire the already-configured first menu buttons (2 options)
	for button in select_ability_or_shape_container.get_children():
		if button is BaseButton:
			button.global_position = _get_center_for(select_ability_or_shape_container)
			(button as BaseButton).pressed.connect(_select_option.bind(button.name))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == configureAbilityButton and event.pressed:
		toggle_radial_menu()

func toggle_radial_menu() -> void:
	if active:
		_hide_current_menu()
		state = States.INACTIVE
	else:
		# open the "choose ability or shape" menu first
		global_position = get_global_mouse_position()
		_show_menu(select_ability_or_shape_container)
		state = States.CHOOSING_SHAPEORABILITY

func _select_option(buttonName: String) -> void:
	match state:
		States.CHOOSING_SHAPEORABILITY:
			if buttonName == "AbilityButton":
				_switch_menu(select_ability_or_shape_container, select_ability_container)
				state = States.CHOOSING_ABILITY
			elif buttonName == "ShapeButton":
				_switch_menu(select_ability_or_shape_container, select_shape_container)
				state = States.CHOOSING_SHAPE

func _on_ability_pressed(buttonName: String) -> void:
	_hide_all_menus()
	state = States.INACTIVE
	
	# Convert button name -> enum value
	if Constants.AbilityType.has(buttonName):
		var ability_type: int = Constants.AbilityType[buttonName]
		if GodAbility.this:
			GodAbility.this.set_active_ability(ability_type)

func _on_shape_pressed(buttonName: String) -> void:
	_hide_all_menus()
	state = States.INACTIVE
	
	# Convert button name -> enum value
	if GodAbility.AbilityShape.has(buttonName):
		var shape_type: int = GodAbility.AbilityShape[buttonName]
		if GodAbility.this:
			GodAbility.this.set_ability_shape(shape_type)

# ---------- menu animation / layout ----------

func _get_center_for(container: Control) -> Vector2:
	return global_position + get_rect().size * 0.5 - container.get_rect().size * 0.5

func _show_menu(container: Control) -> void:
	centerPosition = _get_center_for(container)
	global_position = get_global_mouse_position()
	centerPosition = _get_center_for(container)
	
	var buttons := container.get_children()
	if buttons.is_empty():
		return
	
	var spacing := TAU / float(buttons.size())
	
	for child in buttons:
		if not (child is Control):
			continue
		var button := child as Control
		button.global_position = centerPosition
		
		var angle := spacing * float(button.get_index()) - PI
		var target_dir := Vector2(radius, 0).rotated(angle)
		var target_pos := button.global_position - button.get_rect().size * 0.5 + target_dir
		
		var tween := get_tree().create_tween()
		tween.tween_property(button, "global_position", target_pos, animationSpeed)
		tween.parallel()
		tween.tween_property(button, "scale", Vector2.ONE, animationSpeed)
	
	await get_tree().create_timer(animationSpeed).timeout
	container.show()
	active = true

func _hide_menu(container: Control) -> void:
	centerPosition = _get_center_for(container)
	
	for child in container.get_children():
		if not (child is Control):
			continue
		var button := child as Control
		
		var tween := get_tree().create_tween()
		tween.tween_property(button, "global_position", centerPosition, animationSpeed)
		tween.parallel()
		tween.tween_property(button, "scale", Vector2.ONE, animationSpeed)
	
	await get_tree().create_timer(animationSpeed).timeout
	container.hide()
	active = false

func _hide_current_menu() -> void:
	match state:
		States.CHOOSING_SHAPEORABILITY:
			await _hide_menu(select_ability_or_shape_container)
		States.CHOOSING_ABILITY:
			await _hide_menu(select_ability_container)
		States.CHOOSING_SHAPE:
			await _hide_menu(select_shape_container)

func _hide_all_menus() -> void:
	# Hide immediately + reset positions (no animation, "fully hide")
	select_ability_or_shape_container.hide()
	select_ability_container.hide()
	select_shape_container.hide()
	active = false

func _switch_menu(from_container: Control, to_container: Control) -> void:
	await _hide_menu(from_container)
	await _show_menu(to_container)

# ---------- dynamic button creation ----------

func _spawn_ability_buttons() -> void:
	# Clear existing dynamic buttons (keep any static nodes if you have them)
	for child in select_ability_container.get_children():
		child.queue_free()
	
	for ability_name in Constants.AbilityType.keys():
		var b := buttonScene.instantiate()
		select_ability_container.add_child(b)
		
		# Name + label
		b.name = str(ability_name)
		if b is Button:
			(b as Button).text = str(ability_name)
		elif b is BaseButton and b.has_method("set_text"):
			b.set_text(str(ability_name))
		
		if b is BaseButton:
			(b as BaseButton).pressed.connect(_on_ability_pressed.bind(b.name))

func _spawn_shape_buttons() -> void:
	for child in select_shape_container.get_children():
		child.queue_free()
	for shape_name in GodAbility.AbilityShape.keys():
		var b := buttonScene.instantiate()
		select_shape_container.add_child(b)
		b.name = str(shape_name)
		if b is Button:
			(b as Button).text = str(shape_name)
		elif b is BaseButton and b.has_method("set_text"):
			b.set_text(str(shape_name))
		if b is BaseButton:
			(b as BaseButton).pressed.connect(_on_shape_pressed.bind(b.name))
