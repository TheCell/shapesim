class_name Unit
extends CharacterBody2D

signal attack(damage: float)

@export var health: float = 100.0
@export var damage: float = 10.0
@export var speed: float = 50.0
@export var civilization: Constants.Civilization
@export var attack_range: Area2D
@export var nav: NavigationAgent2D

var target: Vector2
var is_fighting: bool = false
var last_attacked_enemy: Unit
var last_attacked_building: Building

func _ready() -> void:
	_actor_setup.call_deferred()
	nav.velocity_computed.connect(_velocity_computed)

func _process(_delta: float) -> void:
	if has_enemies_in_range() and not is_fighting:
		attack_unit()
	elif has_buildings_in_range() and not is_fighting:
		attack_building()

func _physics_process(delta: float) -> void:
	move_to_hub()
	#if not has_enemies_in_range() and not has_buildings_in_range():
		#velocity = target.move_toward(target, delta).normalized() * speed
	#else:
		#velocity = Vector2.ZERO
	move_and_slide()

func _velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity

func _actor_setup() -> void:
	await get_tree().physics_frame
	nav.target_position = target

func move_to_hub() -> void:
	nav.target_position = target
	
	if nav.is_navigation_finished():
		return
	
	var current_position := global_position
	var next_position := nav.get_next_path_position()
	
	var new_velocity := current_position.direction_to(next_position) * speed
	
	_velocity_computed(new_velocity)

func attack_unit() -> void:
	is_fighting = true
	var enemies_in_range := get_enemies_in_range()
	if last_attacked_enemy == null:
		last_attacked_enemy = enemies_in_range.pick_random()
	var random_damage_modifier := randf_range(1.0, 5.0)
	last_attacked_enemy.hurt(damage + random_damage_modifier)
	is_fighting = false

func attack_building() -> void:
	is_fighting = true
	var enemies_in_range := get_buildings_in_range()
	if last_attacked_building == null:
		last_attacked_building = enemies_in_range.pick_random()
	var random_damage_modifier := randf_range(1.0, 5.0)
	last_attacked_building.hurt(damage + random_damage_modifier)
	is_fighting = false

func get_enemies_in_range() -> Array[Unit]:
	var units_in_range: Array[Unit] = []
	units_in_range.assign(attack_range.get_overlapping_bodies().filter(
		func(node: Node2D) -> bool:
			return node is Unit
	))
	
	return units_in_range.filter(
		func(unit: Unit) -> bool:
			return self.civilization != unit.civilization
	)

func get_buildings_in_range() -> Array[Building]:
	var buildings_in_range: Array[Building] = []
	buildings_in_range.assign(attack_range.get_overlapping_areas().filter(
		func(node: Area2D) -> bool:
			return node is Building
	))
	
	return buildings_in_range.filter(
		func(building: Building) -> bool:
			return self.civilization != building.civilization.faction
	)

func has_enemies_in_range() -> bool:
	var units_in_range: Array[Unit] = []
	units_in_range.assign(attack_range.get_overlapping_bodies().filter(
		func(node: Node2D) -> bool:
			return node is Unit
	))
	return units_in_range.any(
		func(unit: Unit) -> bool:
			return self.civilization != unit.civilization
	)

func has_buildings_in_range() -> bool:
	var buildings_in_range: Array[Building] = []
	buildings_in_range.assign(attack_range.get_overlapping_areas().filter(
		func(node: Area2D) -> bool:
			return node is Building
	))
	return buildings_in_range.any(
		func(building: Building) -> bool:
			return self.civilization != building.civilization.faction
	)

func hurt(enemy_damage: float) -> void:
	if health - enemy_damage > 0:
		health -= enemy_damage
	else:
		queue_free()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		World.this.factionToUnits[civilization].erase(self)
