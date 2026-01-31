class_name GodAbility
extends Node2D

static var this : GodAbility

@export var radius: float = 2.0
@export var speed: float = 200.0 # pixels per second
@export var activeAbility : Constants.AbilityType = Constants.AbilityType.Speedup
@export var abilityCooldown : float = 5
@export var abilityTimer : Timer

var registered_units: Dictionary = {} # id -> WeakRef

func _enter_tree():
	this = self
	abilityTimer.wait_time = abilityCooldown

func _process(delta: float) -> void:
	Set_Position(get_global_mouse_position())
	
	match activeAbility : 
		Constants.AbilityType:
			pass

func is_inside_ability(pos: Vector2) -> bool:
	return global_position.distance_to(pos) < radius

func register_unit(unit: Node) -> void:
	registered_units[unit.get_instance_id()] = weakref(unit)
	
	if unit.get_script() == unit:
		var warrior : Unit = unit
		match activeAbility :
			Constants.AbilityType.Speedup:
				modify_speed_warrior(warrior, 2)
			Constants.AbilityType.Slowdown: 
				modify_speed_warrior(warrior, 0.5)

func deregister_unit(unit: Node) -> void:
	if registered_units.has(unit) :
		registered_units.erase(unit.get_instance_id())
		
		if unit.get_script() == unit:
			var warrior : Unit = unit
			match activeAbility :
				Constants.AbilityType.Speedup:
					modify_speed_warrior(warrior, 0.5)
				Constants.AbilityType.Slowdown: 
					modify_speed_warrior(warrior, 2)

func get_units_alive() -> Array[Node]:
	var result: Array[Node] = []
	for id in registered_units.keys():
		var u := registered_units[id].get_ref() as Node
		if u:
			result.append(u)
		else:
			registered_units.erase(id) # cleanup freed ones
	
	return result

func Set_Position(target: Vector2) -> void:
	var to_target := target - global_position
	if to_target.length() < 0.001:
		return
		
	global_position = target

func apply_timed_ability():
	
	if activeAbility == Constants.AbilityType.Meteorite:
		var units = get_units_alive()
		for unit in units:
			if unit.get_script() == unit:
				var warrior : Unit = unit
				warrior.hurt(100)
				log("hurt enemy %s" + unit.name)
	
	pass

func modify_speed_warrior(unit : Unit, mult : float):
	unit.speed = unit.speed * mult
	
