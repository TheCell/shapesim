class_name World
extends Node2D

const FACTION_COUNT = 5
static var this: World


@export var civScenes: Array[PackedScene]
@export var ground: TileMapLayer

var civilizations = []
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
	for i in FACTION_COUNT:
		var civ = civScenes.pick_random().instantiate() as Civilization
		civ.position = Vector2(randf() * get_viewport_rect().size.x, randf() * get_viewport_rect().size.y)
		add_child(civ)
		civilizations.append(civ)

func _process(delta: float) -> void:
	pass
