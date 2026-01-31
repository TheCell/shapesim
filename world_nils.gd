class_name World
extends Node2D

static var this: World



@export var civScenes: Array[PackedScene]
@export var ground: TileMapLayer

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
	init_civilizations()

func init_civilizations():
	for faction in Constants.Civilization.values():
		var civ = civScenes.pick_random().instantiate() as Civilization
		civ.position = Vector2(randf() * get_viewport_rect().grow(-100).size.x, randf() * get_viewport_rect().grow(-50).size.y)
		civ.faction = faction
		add_child(civ)
		civilizations[faction] = civ

func getRandomWeightedCivilizationTarget(except: Constants.Civilization, weighting: Dictionary[Constants.Civilization, float]) -> Constants.Civilization:
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
	pass
