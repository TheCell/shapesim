class_name Science
extends Building

@export var gainStatPointsCooldown = 3
var untilGainStatPoints = 3

@export var statIncreaseFactor = 0.1
@export var statIncreaseSummand = 0

func _ready() -> void:
	super._ready()
	untilGainStatPoints = gainStatPointsCooldown

func _process(delta: float) -> void:
	super._process(delta)
	untilGainStatPoints -= delta
	if untilGainStatPoints <= 0:
		increaseStatPoint()
		untilGainStatPoints = gainStatPointsCooldown
		
func increaseStatPoint():
	if !is_instance_valid(civilization):
		return
	civilization.buffRandomStat(statIncreaseFactor, statIncreaseSummand)
	Eventbus.this.civ_science_upgrade.emit(faction, civilization.stats.totalBuffCount, civilization.stats)
