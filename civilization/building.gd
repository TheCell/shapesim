class_name Building
extends Area2D

const REPELLANT_FORCE_MAX = 1000
const DIST_SQR_FOR_MAX_REPELLANT_FORCE = 25
const OVERLAP_VELOCITY_DECAY = 0.10

@export var deteriorationCountdown: float = INF
@export var health: float = 100.0
@export var animation_player: AnimationPlayer
@export var sprite_2d: Sprite2D
@export var buildingType: Constants.BuildingType

var overlappingBuildings: Dictionary[Building, bool] = {} # Hashset
var overlapVelocityPush: Vector2 = Vector2.ZERO


var level: int
var civilization: Civilization
var faction: Constants.Civilization
var civilizationStyle: Constants.CivilizationStyle

signal destroyed()

func _ready() -> void:
	animation_player.play("spawn")
	level = civilization.level
	setColor()

func _process(delta: float) -> void:
	deteriorationCountdown -= delta
	if deteriorationCountdown <= 0:
		queue_free()
	pushBuildingsAway(delta)
	
func pushBuildingsAway(delta: float):
	overlapVelocityPush *= OVERLAP_VELOCITY_DECAY ** delta
	global_position += overlapVelocityPush * delta
	for building in overlappingBuildings:
		var squareDist = max(building.global_position.distance_squared_to(global_position), DIST_SQR_FOR_MAX_REPELLANT_FORCE)
		var force = DIST_SQR_FOR_MAX_REPELLANT_FORCE / squareDist * REPELLANT_FORCE_MAX
		building.overlapVelocityPush += global_position.direction_to(building.global_position) * force * delta

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(civilization):
			civilization.activeBuildings.erase(self)
		destroyed.emit()

func setColor():
	sprite_2d.texture = Constants.getBuildingTexture(civilization.style, buildingType, level)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("palette", load(Constants.paletteFilePaths.pick_random()))

func hurt(damage: float):
	health -= damage
	if health <= 0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Building:
		overlappingBuildings[area as Building] = true


func _on_area_exited(area: Area2D) -> void:
	if area is Building:
		overlappingBuildings.erase(area)
