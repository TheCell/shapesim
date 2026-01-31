class_name World
extends Node2D

const FACTION_COUNT = 5
var civilizations = []

@export var civScenes: Array[PackedScene]
@export var ground: TileMapLayer

static var this: World

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	this = self
	init_civilizations()

func init_civilizations():
	for i in FACTION_COUNT:
		var civ = civScenes.pick_random().instantiate() as Civilization
		civ.position = Vector2(randf() * get_viewport_rect().size.x, randf() * get_viewport_rect().size.y)
		add_child(civ)
		civilizations.append(civ)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
