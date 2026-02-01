extends Node2D

#@export var news_ticker: NewsTicker
@onready var news_ticker: NewsTicker = $".."

@export var deathCountNewsTresholdRange := 20;

var deathCountNewsTreshold := 10;
var deathCount := 0;
var warriors_pushed := 0;
var buildings_pushed := 0;
var warriors_pulled := 0;
var buildings_pulled := 0;
var warriors_duplicated := 0;
var buildings_duplicated := 0;
var warriors_healed := 0;
var buildings_healed := 0;

var pushCountThreshold := 15;
var pullCountThreshold := 15;
var duplicateCountThreshold := 10;
var healCountThreshold := 20;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Eventbus.this.unit_died.connect(_on_unit_died)
	Eventbus.this.civ_reached_level.connect(_on_civ_reached_level)
	Eventbus.this.died.connect(_on_died)
	Eventbus.this.warriors_pushed.connect(_on_warriors_pushed)
	Eventbus.this.buildings_pushed.connect(_on_buildings_pushed)
	Eventbus.this.warriors_pulled.connect(_on_warriors_pulled)
	Eventbus.this.buildings_pulled.connect(_on_buildings_pulled)
	Eventbus.this.warriors_duplicated.connect(_on_warriors_duplicated)
	Eventbus.this.buildings_duplicated.connect(_on_buildings_duplicated)
	Eventbus.this.warriors_healed.connect(_on_warriors_healed)
	Eventbus.this.buildings_healed.connect(_on_buildings_healed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	news_on_death_count()
	news_on_push_count()
	news_on_pull_count()
	news_on_duplicate_count()
	news_on_heal_count()

# News Triggers
func news_on_death_count() -> void:
	if deathCount > deathCountNewsTreshold:
		news_ticker.add_to_queue({
			"type": Constants.NewsType.War,
			"count": deathCount
		})
		deathCount = 0;
		deathCountNewsTreshold = randi_range(10, deathCountNewsTresholdRange)

func news_on_push_count() -> void:
	var total := warriors_pushed + buildings_pushed
	if total > pushCountThreshold:
		news_ticker.add_to_queue({
			"type": Constants.NewsType.Push,
			"count": total
		})
		warriors_pushed = 0
		buildings_pushed = 0
		pushCountThreshold = randi_range(10, 20)

func news_on_pull_count() -> void:
	var total := warriors_pulled + buildings_pulled
	if total > pullCountThreshold:
		news_ticker.add_to_queue({
			"type": Constants.NewsType.Pull,
			"count": total
		})
		warriors_pulled = 0
		buildings_pulled = 0
		pullCountThreshold = randi_range(10, 20)

func news_on_duplicate_count() -> void:
	var total := warriors_duplicated + buildings_duplicated
	if total > duplicateCountThreshold:
		news_ticker.add_to_queue({
			"type": Constants.NewsType.Duplicate,
			"count": total
		})
		warriors_duplicated = 0
		buildings_duplicated = 0
		duplicateCountThreshold = randi_range(8, 15)

func news_on_heal_count() -> void:
	var total := warriors_healed + buildings_healed
	if total > healCountThreshold:
		news_ticker.add_to_queue({
			"type": Constants.NewsType.Heal,
			"count": total
		})
		warriors_healed = 0
		buildings_healed = 0
		healCountThreshold = randi_range(15, 25)

# Event subscriptions
func _on_died(unit: Unit) -> void:
	deathCount += 1;
	#print_debug("deathCount", deathCount)

func _on_unit_died(attacker_civ: Constants.Civilization, attacked_civ: Constants.Civilization, was_god_intervention: bool) -> void:
	print_debug(attacked_civ, attacked_civ, was_god_intervention)

func _on_civ_reached_level(civ: Constants.Civilization, level: int) -> void:
	print_debug(civ, level)

func _on_warriors_pushed(count: int) -> void:
	warriors_pushed += count;

func _on_buildings_pushed(count: int) -> void:
	buildings_pushed += count;

func _on_warriors_pulled(count: int) -> void:
	warriors_pulled += count;

func _on_buildings_pulled(count: int) -> void:
	buildings_pulled += count;

func _on_warriors_duplicated(count: int) -> void:
	warriors_duplicated += count;

func _on_buildings_duplicated(count: int) -> void:
	buildings_duplicated += count;

func _on_warriors_healed(count: int) -> void:
	warriors_healed += count;
	
func _on_buildings_healed(count: int) -> void:
	buildings_healed += count;
