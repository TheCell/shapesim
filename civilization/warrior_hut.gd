class_name WarriorHut
extends Building

@export var warriorSpawnCooldown: float = 5
var untilWarriorSpawn: float = 5
static var warriorScene: PackedScene = preload("res://unit/unit.tscn")
@export var spawnRadiusMax = 30

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
		var randomSpawnAngle = randf() * TAU
		var randomDistance = randf() * spawnRadiusMax
		var spawn_pos : Vector2 = global_position + Vector2(cos(randomSpawnAngle), sin(randomSpawnAngle)) * randomDistance
		
		var warrior := spawn_warrior(spawn_pos, faction, civilizationStyle)
		
		warrior.target = global_position
		
		spawnedWarrior.emit(warrior)
		World.this.factionToUnits[civilization.faction].append(warrior)
		World.this.add_child(warrior)
		
		untilWarriorSpawn += warriorSpawnCooldown

static func spawn_warrior(spawn_pos: Vector2, civilization : Constants.Civilization, civilizationStyle : Constants.CivilizationStyle) -> Unit:
	var warrior := warriorScene.instantiate() as Unit
	warrior.global_position = spawn_pos
	warrior.target = spawn_pos
	warrior.civilization = civilization
	warrior.civilizationStyle = civilizationStyle
	return warrior
