class_name WatchTower
extends Building

@export var shotCooldown = 1
var untilShot = 1
@export var shotScene: PackedScene
@export var rangeCollider: Area2D

var enemiesInRange: Dictionary[Unit, bool] = {}

var lastAvailableMilitaryModifier: float = 1.0

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	untilShot -= delta * GodAbility.this.getTimewarpModifier(isRegisteredOnAbility)
	if untilShot <= 0 && len(enemiesInRange) > 0:
		var attackedUnit: Unit = null
		for u in enemiesInRange.keys():
			if is_instance_valid(u) && !u.is_dead:
				attackedUnit = u
				break
		if attackedUnit:
			shoot(attackedUnit)
		
func shoot(target: Unit):
	var damageMod = civilization.stats.totalDamageModifier(civilization.level) if is_instance_valid(civilization) else lastAvailableMilitaryModifier
	
	var shot = shotScene.instantiate() as Shot
	shot.faction = faction
	shot.global_position = global_position
	shot.damage *= damageMod
	shot.direction = global_position.direction_to(target.global_position)
	untilShot = shotCooldown
	World.this.add_child(shot)

func _on_area_2d_body_entered(body: Node2D) -> void:
	var e = body as Unit
	if e && e.civilization != faction:
		enemiesInRange[e] = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)
