class_name WarriorHut
extends Building

@export var warriorSpawnCooldown: float = 5
var untilWarriorSpawn: float = 5
static var warriorScene: PackedScene = preload("res://unit/unit.tscn")
@export var spawnRadiusMax = 30

var lastAvailableMilitaryModifier: float = 1.0
var lastAvailableWarriorHealth: float = 100


func _ready() -> void:
	super._ready()
	untilWarriorSpawn = warriorSpawnCooldown

func _process(delta: float) -> void:
	super._process(delta)
	if !is_instance_valid(civilization):
		return
	untilWarriorSpawn -= delta
	
	if untilWarriorSpawn <= 0 && Civilization.allowedToSpawnUnit(faction):
		spawnWarrior()
		untilWarriorSpawn = warriorSpawnCooldown
		

func spawnWarrior():
	var damageModifier = civilization.stats.totalDamageModifier(civilization.level) if is_instance_valid(civilization) else lastAvailableMilitaryModifier
	var health = civilization.stats.totalWarriorHealth(civilization.level) if is_instance_valid(civilization) else lastAvailableWarriorHealth
		
	var warrior = warriorScene.instantiate() as Unit # TODO: use spawn_warrior instead
	var randomSpawnAngle = randf() * TAU
	var randomDistance = randf() * spawnRadiusMax
	warrior.global_position = global_position + Vector2(cos(randomSpawnAngle), sin(randomSpawnAngle)) * randomDistance
	warrior.civilization = faction
	warrior.civilizationStyle = civilizationStyle
	warrior.damage *= damageModifier
	warrior.health = health
	warrior.level = level
	World.this.factionToUnits[faction].append(warrior)
	Eventbus.this.civ_total_troops_equal.emit(faction, len(World.this.factionToUnits[faction]))
	World.this.add_child(warrior)

static func spawn_warrior(spawn_pos: Vector2, civilization : Constants.Civilization, civilizationStyle : Constants.CivilizationStyle) -> Unit:
	var warrior := warriorScene.instantiate() as Unit
	warrior.global_position = spawn_pos
	warrior.target = spawn_pos
	warrior.civilization = civilization
	warrior.civilizationStyle = civilizationStyle
	return warrior
