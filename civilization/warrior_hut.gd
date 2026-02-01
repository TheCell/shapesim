class_name WarriorHut
extends Building

@export var warriorSpawnCooldown: float = 5
var untilWarriorSpawn: float = 5
@export var warriorScene: PackedScene
@export var spawnRadiusMax = 30

var lastAvailableMilitaryModifier: float = 1.0
var lastAvailableWarriorHealth: float = 100

signal spawnedWarrior(unit: Unit)

func _ready() -> void:
	super._ready()
	untilWarriorSpawn = warriorSpawnCooldown

func _process(delta: float) -> void:
	super._process(delta)
	if !is_instance_valid(civilization):
		return
	untilWarriorSpawn -= delta
	while (untilWarriorSpawn <= 0):
		spawnWarrior()

func spawnWarrior():
	var damageModifier = civilization.stats.totalDamageModifier(civilization.level) if is_instance_valid(civilization) else lastAvailableMilitaryModifier
	var health = civilization.stats.totalWarriorHealth(civilization.level) if is_instance_valid(civilization) else lastAvailableWarriorHealth
		
	var warrior = warriorScene.instantiate() as Unit
	var randomSpawnAngle = randf() * TAU
	var randomDistance = randf() * spawnRadiusMax
	warrior.global_position = global_position + Vector2(cos(randomSpawnAngle), sin(randomSpawnAngle)) * randomDistance
	warrior.civilization = faction
	warrior.civilizationStyle = civilizationStyle
	warrior.damage *= damageModifier
	warrior.health = health
	spawnedWarrior.emit(warrior)
	World.this.factionToUnits[faction].append(warrior)
	World.this.add_child(warrior)
	untilWarriorSpawn += warriorSpawnCooldown
