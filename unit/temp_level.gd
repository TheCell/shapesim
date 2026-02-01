extends Node2D


@export var button_a: Button
@export var button_b: Button

func _ready() -> void:
	button_a.pressed.connect(_on_button_a_pressed)
	button_b.pressed.connect(_on_button_b_pressed)
	$Unit.target = Vector2(1300, 300)
	$Unit.civilization = Constants.Civilization.Purple

func spawn_unit(pos: Vector2, target: Vector2, civilization: Constants.Civilization) -> void:
	var scene: PackedScene = load("res://unit/unit.tscn")
	var unit: Unit = scene.instantiate()
	unit.position = pos
	unit.target = target
	unit.civilization = civilization
	add_child.call_deferred(unit)

func _on_button_a_pressed() -> void:
	spawn_unit(Vector2(200, randi_range(250, 400)), Vector2(1000, 0), Constants.Civilization.Red)

func _on_button_b_pressed() -> void:
	spawn_unit(Vector2(600, randi_range(250, 400)), Vector2(-1000, 0), Constants.Civilization.Blue)
