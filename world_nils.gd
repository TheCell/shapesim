class_name World
extends Node2D

static var this: World


@export var civScenes: Dictionary[Constants.Civilization, PackedScene] = {
	Constants.Civilization.Red: null,
	Constants.Civilization.Blue: null,
	Constants.Civilization.Green: null,
	Constants.Civilization.Yellow: null,
	Constants.Civilization.Purple: null,
}
@export var ground: TileMapLayer

@export var civRespawnTimer: float = 10
@export var ground_size: Vector2i = Vector2i(30, 50)

var untilCivRespawn: float = 0
var tile_size := 32

var civilizations: Dictionary[Constants.Civilization, Civilization] = {}

var factionToUnits: Dictionary[Constants.Civilization, Array] = {
	Constants.Civilization.Red: [],
	Constants.Civilization.Blue: [],
	Constants.Civilization.Green: [],
	Constants.Civilization.Yellow: [],
	Constants.Civilization.Purple: [],
}

func _ready() -> void:
	this = self
	untilCivRespawn = civRespawnTimer
	GroundController.this.set_ground(ground_size)
	init_civilizations()

func init_civilizations():
	for faction in Constants.Civilization.values():
		spawnCivilization(faction)
		
func spawnCivilization(faction: Constants.Civilization) -> Civilization:
	var civ = civScenes[faction].instantiate() as Civilization
	var max_width := ground_size.x * tile_size * 0.8
	var max_height := ground_size.y * tile_size * 0.8
	
	var origin_offset := Vector2(ground_size.x * tile_size / 2.0, ground_size.y * tile_size / 2.0)
	civ.position = Vector2((randf() - 0.5) * max_width + origin_offset.x, (randf() - 0.5) * max_height + origin_offset.y)
	civ.faction = faction
	civ.personality = Constants.CivilizationPersonality.values().pick_random()
	
	var availableStyles = Constants.CivilizationStyle.values()
	for alive in civilizations.keys():
		availableStyles.erase(civilizations[alive].style)
	if len(availableStyles) == 0:
		availableStyles = Constants.CivilizationStyle.values()
	var randomStyle = availableStyles.pick_random()
	civ.style = randomStyle
	
	add_child(civ)
	civilizations[faction] = civ
	return civ

func getRandomWeightedCivilizationTarget(except: Constants.Civilization, weighting: Dictionary) -> Constants.Civilization:
	var totalWeights = 0
	for faction in weighting:
		if faction == except:
			continue
		if !civilizations.has(faction):
			continue
		totalWeights += weighting[faction]
	
	var r = randf() * totalWeights
	var sampledFaction = -1
	for faction in weighting:
		if faction == except:
			continue
		if !civilizations.has(faction):
			continue
		var currentWeight = weighting[faction]
		if r < currentWeight:
			sampledFaction = faction
			break
		r -= currentWeight
	return sampledFaction
		
		
	var target = except
	while target == except:
		target = Constants.Civilization.values().pick_random()
	return target

func _process(delta: float) -> void:
	spawn.call_deferred()
	if len(civilizations) < len(Constants.Civilization.values()):
		untilCivRespawn -= delta
		if untilCivRespawn <= 0:
			respawnNonPresentCiv()
			untilCivRespawn = civRespawnTimer

func respawnNonPresentCiv():
	var dedCivs = Constants.Civilization.values()
	for alive in civilizations.keys():
		dedCivs.erase(alive)
	
	var toSpawn = dedCivs.pick_random()
	var newCiv = spawnCivilization(toSpawn)
	Eventbus.this.civ_rebirthed.emit(newCiv.faction, newCiv.style, newCiv.personality)
	print("Respawned civ " + Constants.Civilization.find_key(toSpawn))

func spawn():
	#TODO: remove this test method.
	if Input.is_action_just_pressed("ui_accept"):
		var building = load("res://civilization/watch_tower.tscn").instantiate() as Building
		building.position = get_global_mouse_position()
		building.faction = Constants.Civilization.Blue
		building.civilization = civilizations[Constants.Civilization.Blue]
		World.this.add_child(building)
		pass
