class_name Unit
extends CharacterBody2D

signal attack(damage: float)

@export var health: float = 100.0
@export var damage: float = 10.0
@export var speed: float = 80.0
@export var target: Vector2
@export var civilization: Constants.Civilization
@export var is_fighting: bool = false
@export var attack_range: Area2D
var last_attacked_enemy: Unit

func _process(_delta: float) -> void:
	if has_enemies_in_range() and not is_fighting:
		is_fighting = true
		var enemies_in_range := get_enemies_in_range()
		if last_attacked_enemy == null:
			last_attacked_enemy = enemies_in_range.pick_random()
		if not attack.is_connected(last_attacked_enemy._on_attack):
			attack.connect(last_attacked_enemy._on_attack)
		var random_damage_modifier := randf_range(1.0, 5.0)
		await get_tree().create_timer(1.0).timeout
		attack.emit(damage + random_damage_modifier)
		is_fighting = false
	elif not has_enemies_in_range():
		if last_attacked_enemy:
			if attack.is_connected(last_attacked_enemy._on_attack):
				attack.disconnect(last_attacked_enemy._on_attack)

func _physics_process(delta: float) -> void:
	if not has_enemies_in_range():
		velocity = target.move_toward(target, delta).normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

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

func take_damage(enemy_damage: float) -> void:
	if health - enemy_damage > 0:
		health -= enemy_damage
	else:
		queue_free.call_deferred()

func _on_attack(enemy_damage: float) -> void:
	take_damage(enemy_damage)
