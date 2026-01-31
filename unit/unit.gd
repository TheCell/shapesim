class_name Unit
extends CharacterBody2D

signal attack(damage: float)

@export var health: float = 100.0
@export var damage: float = 10.0
@export var speed: float = 80.0
@export var civilization: Constants.Civilization
@export var attack_range: Area2D
@export var sprite_2d: Sprite2D

var target: Vector2
var is_fighting: bool = false
var last_attacked_enemy: Unit
var last_attacked_building: Building

var overlappingUnits: Dictionary[Unit, bool] = {} # Hashset
var overlappingBuildings: Dictionary[Building, bool] = {} # Hashset

func _ready() -> void:
	setColor()

func setColor():
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("faction", civilization)

func _process(_delta: float) -> void:
	if has_enemies_in_range() and not is_fighting:
		attack_unit()
	elif has_buildings_in_range() and not is_fighting:
		attack_building()

func _physics_process(delta: float) -> void:
	if not has_enemies_in_range() and not has_buildings_in_range():
		velocity = global_position.direction_to(target) * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

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
	return overlappingUnits.keys().filter(
		func(unit: Unit) -> bool:
			return self.civilization != unit.civilization
	)

func get_buildings_in_range() -> Array[Building]:
	return overlappingBuildings.keys().filter(
		func(building: Building) -> bool:
			return !is_instance_valid(building.civilization) || self.civilization != building.faction
	)

func has_enemies_in_range() -> bool:
	return overlappingUnits.keys().any(
		func(unit: Unit) -> bool:
			return self.civilization != unit.civilization
	)

func has_buildings_in_range() -> bool:
	return overlappingBuildings.keys().any(
		func(building: Building) -> bool:
			return !is_instance_valid(building.civilization) || self.civilization != building.faction
	)

func hurt(enemy_damage: float) -> void:
	if health - enemy_damage > 0:
		health -= enemy_damage
	else:
		queue_free()

func _on_attack(enemy_damage: float) -> void:
	hurt(enemy_damage)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		World.this.factionToUnits[civilization].erase(self)


func _on_attack_range_area_entered(area: Area2D) -> void:
	if area is Building:
		overlappingBuildings[area as Building] = true


func _on_attack_range_area_exited(area: Area2D) -> void:
	overlappingBuildings.erase(area)


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body is Unit:
		overlappingUnits[body as Unit] = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	overlappingUnits.erase(body)
