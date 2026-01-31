class_name GodAbility
extends Node2D

static var this : GodAbility

@export var radius: float = 2.0
@export var speed: float = 200.0 # pixels per second
@export var activeAbility : Constants.AbilityType = Constants.AbilityType.Speedup
var registeredUnits : Dictionary = {}

func _enter_tree():
	this = self

func _process(delta: float) -> void:
	Set_Position(get_global_mouse_position())

func is_inside_ability(pos: Vector2) -> bool:
	return global_position.distance_to(pos) < radius

func register_unit(unit: Variant) -> void:
	registeredUnits.assign(unit)

func deregister_unit(unit: Variant) -> void:
	if registeredUnits.has(unit):
		registeredUnits.erase(unit)

func Set_Position(target: Vector2) -> void:
	var to_target := target - global_position
	if to_target.length() < 0.001:
		return
		
	global_position = target
