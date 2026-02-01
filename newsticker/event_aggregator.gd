extends Node2D

#@export var news_ticker: NewsTicker
@onready var news_ticker: NewsTicker = $".."

@export var min_significance_threshold := 5  # Minimum count before news is considered
@export var recency_penalty_duration := 10.0  # Seconds before a news type can be published again
@export var check_interval := 1.0  # How often to evaluate news significance

# Significance multipliers for each news type (adjust relative importance)
@export var war_significance_weight := 1.0
@export var push_significance_weight := 0.7
@export var pull_significance_weight := 0.7
@export var duplicate_significance_weight := 2.0
@export var heal_significance_weight := 1.5
@export var civ_level_significance_weight := 3.0

# Accumulated counts for each news type
var deathCount := 0
var warriors_pushed := 0
var buildings_pushed := 0
var warriors_pulled := 0
var buildings_pulled := 0
var warriors_duplicated := 0
var buildings_duplicated := 0
var warriors_healed := 0
var buildings_healed := 0

# Track when each news type was last published (in game time)
var last_published_time := {}  # Dictionary of NewsType -> time

# Timer for checking significance
var time_since_last_check := 0.0

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
	
	# Initialize last published times to 0
	for news_type in Constants.NewsType.values():
		last_published_time[news_type] = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_since_last_check += delta
	
	# Periodically evaluate which news is most significant
	if time_since_last_check >= check_interval:
		evaluate_and_publish_most_significant_news()
		time_since_last_check = 0.0

# Calculate significance score for a news type based on count and recency
func calculate_significance(count: int, news_type: int, weight: float) -> float:
	if count < min_significance_threshold:
		return 0.0
	
	var current_time := Time.get_ticks_msec() / 1000.0
	var time_since_last_publish: float = current_time - last_published_time.get(news_type, 0.0)
	
	# Base significance is the count multiplied by the news type's weight
	var significance := float(count) * weight
	
	# Apply recency penalty - if published recently, reduce significance
	if time_since_last_publish < recency_penalty_duration:
		var recency_factor := time_since_last_publish / recency_penalty_duration
		significance *= recency_factor * 0.3  # Heavy penalty for recent news
	
	return significance

# Evaluate all news types and publish the most significant one
func evaluate_and_publish_most_significant_news() -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	var best_news_type := -1
	var best_significance := 0.0
	var best_count := 0
	
	# Calculate significance for each news type with their respective weights
	var war_sig := calculate_significance(deathCount, Constants.NewsType.War, war_significance_weight)
	if war_sig > best_significance:
		best_significance = war_sig
		best_news_type = Constants.NewsType.War
		best_count = deathCount
	
	var push_count := warriors_pushed + buildings_pushed
	var push_sig := calculate_significance(push_count, Constants.NewsType.Push, push_significance_weight)
	if push_sig > best_significance:
		best_significance = push_sig
		best_news_type = Constants.NewsType.Push
		best_count = push_count
	
	var pull_count := warriors_pulled + buildings_pulled
	var pull_sig := calculate_significance(pull_count, Constants.NewsType.Pull, pull_significance_weight)
	if pull_sig > best_significance:
		best_significance = pull_sig
		best_news_type = Constants.NewsType.Pull
		best_count = pull_count
	
	var duplicate_count := warriors_duplicated + buildings_duplicated
	var duplicate_sig := calculate_significance(duplicate_count, Constants.NewsType.Duplicate, duplicate_significance_weight)
	if duplicate_sig > best_significance:
		best_significance = duplicate_sig
		best_news_type = Constants.NewsType.Duplicate
		best_count = duplicate_count
	
	var heal_count := warriors_healed + buildings_healed
	var heal_sig := calculate_significance(heal_count, Constants.NewsType.Heal, heal_significance_weight)
	if heal_sig > best_significance:
		best_significance = heal_sig
		best_news_type = Constants.NewsType.Heal
		best_count = heal_count
	
	# If we found significant news, publish it
	if best_news_type != -1 && best_significance > 0:
		publish_news(best_news_type, best_count)
		last_published_time[best_news_type] = current_time

# Publish a specific news type and reset its count
func publish_news(news_type: int, count: int) -> void:
	match news_type:
		Constants.NewsType.War:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.War,
				"count": count
			})
			deathCount = 0
		
		Constants.NewsType.Push:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.Push,
				"count": count
			})
			warriors_pushed = 0
			buildings_pushed = 0
		
		Constants.NewsType.Pull:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.Pull,
				"count": count
			})
			warriors_pulled = 0
			buildings_pulled = 0
		
		Constants.NewsType.Duplicate:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.Duplicate,
				"count": count
			})
			warriors_duplicated = 0
			buildings_duplicated = 0
		
		Constants.NewsType.Heal:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.Heal,
				"count": count
			})
			warriors_healed = 0
			buildings_healed = 0

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
