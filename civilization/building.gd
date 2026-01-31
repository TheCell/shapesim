class_name Building
extends Node2D

@export var deteriorationCountdown = INF
@export var health = 100
@export var animation_player: AnimationPlayer
@export_dir var spriteFolder: String
@export var sprite_2d: Sprite2D
@export var buildingType: Constants.BuildingType

var level: int
var civilization: Civilization


signal destroyed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("spawn")
	level = civilization.level
	sprite_2d.texture = Constants.getBuildingTexture(civilization.style, buildingType, level)

func setSprite():
	sprite_2d.texture = load(spriteFolder + "%s.tres" ) # TODO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	deteriorationCountdown -= delta
	if deteriorationCountdown <= 0:
		queue_free()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		civilization.activeBuildings.erase(self)
		destroyed.emit()

func hurt(damage: int):
	health -= damage
	if health <= 0:
		queue_free()
