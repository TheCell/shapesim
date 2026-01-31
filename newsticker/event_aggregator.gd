extends Node2D

#@export var news_ticker: NewsTicker
@onready var news_ticker: NewsTicker = $".."

@export var deathCountNewsTresholdRange := 20;

var deathCountNewsTreshold := 10;
var deathCount := 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Eventbus.this.unit_died.connect(_on_unit_died)
	Eventbus.this.civ_reached_level.connect(_on_civ_reached_level)
	Eventbus.this.died.connect(_on_died)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	news_on_death_count()

# News Triggers
func news_on_death_count() -> void:
	if wasDone:
		return
	if deathCount > deathCountNewsTreshold:
		news_ticker.add_to_queue({
			"type": Constants.NewsType.War,
			"count": deathCount
		})
		deathCount = 0;
		deathCountNewsTreshold = randi_range(10, deathCountNewsTresholdRange)

# Event subscriptions
func _on_died(unit: Unit) -> void:
	deathCount += 1;
	print_debug("deathCount", deathCount)

func _on_unit_died(attacker_civ: Constants.Civilization, attacked_civ: Constants.Civilization, was_god_intervention: bool) -> void:
	print_debug(attacked_civ, attacked_civ, was_god_intervention)

func _on_civ_reached_level(civ: Constants.Civilization, level: int) -> void:
	print_debug(civ, level)
