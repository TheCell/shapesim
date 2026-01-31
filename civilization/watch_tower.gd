class_name WatchTower
extends Building

@export var shotCooldown = 1
var untilShot = 1
@export var shotScene: PackedScene
@export var rangeCollider: Area2D

var enemiesInRange: Dictionary[Unit, bool] = {}


func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	untilShot -= delta
	if untilShot <= 0 && len(enemiesInRange) > 0:
		var unit = enemiesInRange.keys().pick_random()
		var shot = shotScene.instantiate() as Shot
		shot.faction = faction
		shot.global_position = global_position
		shot.direction = global_position.direction_to(unit.global_position)
		untilShot = shotCooldown
		World.this.add_child(shot)


func _on_area_2d_body_entered(body: Node2D) -> void:
	var e = body as Unit
	if e && e.civilization != faction:
		enemiesInRange[e] = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)
