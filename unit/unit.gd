class_name Unit
extends CharacterBody2D

var maxHealth: float = 100.0
@onready var audioPlayer : AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var health: float = 100.0
@export var damage: float = 10.0
@export var speed: float = 100.0
@export var health_change_player: AnimationPlayer

@export var attack_range: Area2D
@export var sprite_2d: Sprite2D
@export var anim: AnimationPlayer
@export var nav: NavigationAgent2D
@export var dead_timer: Timer
@export var health_bar: TextureProgressBar

var civilization: Constants.Civilization
var civilizationStyle: Constants.CivilizationStyle
var level: int = 0

var target: Vector2 = Vector2.INF
var is_fighting: bool = false
var last_attacked_enemy: Unit
var last_attacked_building: Building
var battle_timout: float = 0.5
var is_dead: bool = false

var isRegisteredOnAbility : bool = false
var godAbility : GodAbility

var overlappingAliveEnemies: Dictionary[Unit, bool] = {} # Hashset
var unitsWantingDeathNotifyOfThis: Dictionary[Unit, bool] = {} # Hashset
var overlappingEnemyBuildings: Dictionary[Building, bool] = {} # Hashset

# variables to measure movement progress towards target over the last few frames. Ensures unit is not stuck.
var posBeforeMove: Vector2
var distanceProgressSqr: float = 0
var untilEnsureProgress: float = 1

func _ready() -> void:
	maxHealth = health
	health_bar.max_value = health
	health_bar.material.set_shader_parameter("palette", load(Constants.civsToPaletteFilePaths[civilization]))
	dead_timer.timeout.connect(_on_dead_timer_timeout)
	_actor_setup.call_deferred()
	nav.velocity_computed.connect(_velocity_computed)
	initSprite()

func initSprite():
	sprite_2d.texture = Constants.getWarriorTexture(civilizationStyle, level)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("palette", load(Constants.civsToPaletteFilePaths[civilization]))

func _process(delta: float) -> void:
	health_bar.value = health
	if is_dead:
		last_attacked_building = null
		last_attacked_enemy = null
	if len(overlappingAliveEnemies) == 0:
		last_attacked_enemy = null
	if len(overlappingEnemyBuildings) == 0:
		last_attacked_building = null
	if len(overlappingAliveEnemies) > 0 and not is_fighting and not is_dead:
		attack_unit(overlappingAliveEnemies.keys())
	if len(overlappingEnemyBuildings) > 0 and not is_fighting and not is_dead:
		attack_building()
	
	if !isRegisteredOnAbility && GodAbility.this.is_inside_ability(global_position):
		GodAbility.this.register_unit(self)
		isRegisteredOnAbility = true
	elif isRegisteredOnAbility && !GodAbility.this.is_inside_ability(global_position):
		GodAbility.this.deregister_unit(self)
		isRegisteredOnAbility = false

func _physics_process(delta: float) -> void:
	if is_dead or target == Vector2.INF or len(overlappingEnemyBuildings) > 0 or len(overlappingAliveEnemies) > 0:
		velocity = Vector2.ZERO
	else:
		if nav.target_position != target:
			nav.target_position = target
		set_velocity_to_target()
		
		posBeforeMove = global_position
		move_and_slide()
		distanceProgressSqr += posBeforeMove.distance_squared_to(global_position)
		resetTargetIfNoProgress(delta)
		
	if global_position.distance_squared_to(target) < 10:
		target = Vector2.INF
	
func resetTargetIfNoProgress(delta: float):
	untilEnsureProgress -= delta
	if untilEnsureProgress <= 0:
		var madeRelevantProgress = distanceProgressSqr > 10
		if !madeRelevantProgress:
			target = Vector2.INF
		distanceProgressSqr = 0
		untilEnsureProgress = 0.5

func _velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity

func _actor_setup() -> void:
	await get_tree().physics_frame
	nav.target_position = target

func set_velocity_to_target() -> void:
	#var stopwatch = Time.get_ticks_msec()
	
	if nav.is_navigation_finished():
		target = Vector2.INF
		return

	var current_position := global_position
	var next_position := nav.get_next_path_position()

	var new_velocity := current_position.direction_to(next_position) * speed * GodAbility.this.getTimewarpModifier(isRegisteredOnAbility)

	_velocity_computed(new_velocity)
	#print("pathfinding done in %s ms" % [Time.get_ticks_msec() - stopwatch])

func attack_unit(living_enemies_in_range) -> void:
	is_fighting = true
	if !is_instance_valid(last_attacked_enemy) || last_attacked_enemy == null:
		last_attacked_enemy = living_enemies_in_range.pick_random()
	anim.seek(0)
	anim.play("attack")
	await get_tree().create_timer(battle_timout).timeout
	if is_dead || !is_instance_valid(last_attacked_enemy) || last_attacked_enemy.is_dead:
		is_fighting = false
		last_attacked_enemy = null
		return
	var random_damage_modifier := randf_range(1.0, 1.2)
	last_attacked_enemy.hurt(self, damage * random_damage_modifier)
	is_fighting = false

func attack_building() -> void:
	is_fighting = true
	if !is_instance_valid(last_attacked_building) || last_attacked_building == null:
		last_attacked_building = overlappingEnemyBuildings.keys().pick_random()
	anim.seek(0)
	anim.play("attack")
	await get_tree().create_timer(battle_timout).timeout
	if is_dead || !is_instance_valid(last_attacked_building):
		is_fighting = false
		last_attacked_building = null
		return
	var random_damage_modifier := randf_range(1.0, 1.2)
	last_attacked_building.hurt(damage * random_damage_modifier)
	is_fighting = false

func hurt(entity: Node2D, enemy_damage: float) -> void:
	health -= enemy_damage
	health = clamp(health, 0, maxHealth)
	health_change_player.seek(0)
	health_change_player.play("blink")
	if health <= 0:
		is_dead = true
		anim.seek(0, true)
		anim.stop()
		sendDeathUpdateForUnitsWantingNotify(true)
		modulate = Color(1, 1, 1, 0.5)
		dead_timer.start()
		if randf() > 0.7:
			audioPlayer.play()
		if entity is Unit:
			Eventbus.this.unit_died.emit(entity.civilization, civilization, false)
			Eventbus.this.died.emit(self)

func heal(amount: float) -> void:
	health += amount
	health = clamp(health, 0, maxHealth)
	health_change_player.seek(0)
	health_change_player.play("healed")
	if is_dead && health > 0:
		dead_timer.stop()
		dead_timer.wait_time = 5.0
		modulate = Color.WHITE
		is_dead = false
		sendDeathUpdateForUnitsWantingNotify(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		World.this.factionToUnits[civilization].erase(self)

func _on_dead_timer_timeout() -> void:
	if is_dead:
		queue_free()

func _on_attack_range_area_entered(area: Area2D) -> void:
	if area is Building && (!is_instance_valid(area.civilization) || civilization != area.faction):
		overlappingEnemyBuildings[area as Building] = true


func _on_attack_range_area_exited(area: Area2D) -> void:
	overlappingEnemyBuildings.erase(area as Building)

func sendDeathUpdateForUnitsWantingNotify(is_dead: bool):
	for unit in unitsWantingDeathNotifyOfThis:
		if is_dead:
			unit.overlappingAliveEnemies.erase(self)
		else:
			unit.overlappingAliveEnemies[self] = true
	
func _on_attack_range_body_entered(body: Node2D) -> void:
	var b = body as Unit
	if b && civilization != b.civilization:
		if !b.is_dead:
			overlappingAliveEnemies[b] = true
		b.unitsWantingDeathNotifyOfThis[self] = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	var b = body as Unit
	if b:
		overlappingAliveEnemies.erase(b)
		if is_instance_valid(b):
			b.unitsWantingDeathNotifyOfThis.erase(self)
