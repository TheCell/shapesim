class_name Building
extends Area2D

@export var deteriorationCountdown: float = INF
@export var health: float = 100.0
@export var animation_player: AnimationPlayer
@export var sprite_2d: Sprite2D
@export var buildingType: Constants.BuildingType

var level: int
var civilization: Civilization
var faction: Constants.Civilization

signal destroyed()

func _ready() -> void:
	animation_player.play("spawn")
	level = civilization.level
	sprite_2d.texture = Constants.getBuildingTexture(civilization.style, buildingType, level)
	setColor()

func _process(delta: float) -> void:
	deteriorationCountdown -= delta
	if deteriorationCountdown <= 0:
		queue_free()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(civilization):
			civilization.activeBuildings.erase(self)
		destroyed.emit()

func setColor():
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("faction", civilization.faction)

func hurt(damage: float):
	health -= damage
	if health <= 0:
		queue_free()

func _on_attack(damage: float) -> void:
	hurt(damage)
