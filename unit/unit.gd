class_name Unit
extends CharacterBody2D

@export var health: float = 100.0
@export var damage: float = 10.0
@export var speed: float = 100.0

@export var attack_range: Area2D
@export var sprite_2d: Sprite2D
@export var anim: AnimationPlayer
@export var nav: NavigationAgent2D

var civilization: Constants.Civilization
var civilizationStyle: Constants.CivilizationStyle
var level: int = 0

var target: Vector2
var is_fighting: bool = false
var last_attacked_enemy: Unit
var last_attacked_building: Building
var battle_timout: float = 0.5

var isRegisteredOnAbility : bool = false
var godAbility : GodAbility

var overlappingUnits: Dictionary[Unit, bool] = {} # Hashset
var overlappingBuildings: Dictionary[Building, bool] = {} # Hashset

func _ready() -> void:
	_actor_setup.call_deferred()
	nav.velocity_computed.connect(_velocity_computed)
	initSprite()
	godAbility = GodAbility.this

func initSprite():
	sprite_2d.texture = Constants.getWarriorTexture(civilizationStyle, level)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("faction", civilization)

func _process(_delta: float) -> void:
	if has_enemies_in_range() and not is_fighting:
		attack_unit()
	elif has_buildings_in_range() and not is_fighting:
		attack_building()
	
	
	if !isRegisteredOnAbility && godAbility.is_inside_ability(global_position):
		godAbility.register_unit(self)
		isRegisteredOnAbility = true
	elif isRegisteredOnAbility && !godAbility.is_inside_ability(global_position):
		godAbility.deregister_unit(self)
		isRegisteredOnAbility = false
		
	

func _physics_process(_delta: float) -> void:
	if has_buildings_in_range() or has_enemies_in_range():
		velocity = Vector2.ZERO
	else:
		move_to_hub()
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
	await get_tree().create_timer(battle_timout).timeout
	anim.play("attack")
	var random_damage_modifier := randf_range(1.0, 5.0)
	if is_instance_valid(last_attacked_building):
		last_attacked_enemy.hurt(damage + random_damage_modifier)
	is_fighting = false

func attack_building() -> void:
	is_fighting = true
	var enemies_in_range := get_buildings_in_range()
	if last_attacked_building == null:
		last_attacked_building = enemies_in_range.pick_random()
	await get_tree().create_timer(battle_timout).timeout
	anim.play("attack")
	var random_damage_modifier := randf_range(1.0, 5.0)
	if is_instance_valid(last_attacked_building):
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
		Events.unit_died.emit(last_attacked_enemy.civilization, civilization, false)
		queue_free()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		World.this.factionToUnits[civilization].erase(self)


func _on_attack_range_area_entered(area: Area2D) -> void:
	if area is Building:
		overlappingBuildings[area as Building] = true


func _on_attack_range_area_exited(area: Area2D) -> void:
	overlappingBuildings.erase(area as Building)


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body is Unit:
		overlappingUnits[body as Unit] = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	overlappingUnits.erase(body)
