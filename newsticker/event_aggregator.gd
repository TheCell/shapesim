extends Node2D

#@export var news_ticker: NewsTicker
@onready var news_ticker: NewsTicker = $".."

@export var min_significance_threshold := 5  # Minimum count before news is considered
@export var recency_penalty_duration := 10.0  # Seconds before a news type can be published again
@export var check_interval := 1.0  # How often to evaluate news significance

# Significance multipliers for each news type (adjust relative importance)
@export var war_significance_weight := 0.5
@export var push_significance_weight := 0.7
@export var pull_significance_weight := 0.7
@export var duplicate_significance_weight := 2.0
@export var heal_significance_weight := 1.5
@export var civ_level_significance_weight := 3.0
@export var civ_level_down_significance_weight := 2.5
@export var building_destroyed_significance_weight := 1.2
@export var building_decayed_significance_weight := 0.8
@export var strategy_change_significance_weight := 2.0
@export var war_declaration_significance_weight := 3.5
@export var science_breakthrough_significance_weight := 1.8

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
var buildings_destroyed_count := 0
var buildings_decayed_count := 0
var science_upgrades_count := 0

# Store data for single-event news types
var last_civ_level_up: Dictionary = {}  # {civ, level}
var last_civ_level_down: Dictionary = {}  # {civ, level}
var last_strategy_change: Dictionary = {}  # {civ, old_strategy, new_strategy, is_surprising}
var last_war_declaration: Dictionary = {}  # {attacking_civ, receiving_civ}

# Track when each news type was last published (in game time)
var last_published_time := {}  # Dictionary of NewsType -> time

# Track recently published news types to prevent spam
var recent_news_history: Array[Dictionary] = []  # [{type: NewsType, time: timestamp}]
@export var war_news_cooldown_count := 2  # War news can't appear if in last N news
@export var news_history_expire_time := 10.0  # Seconds before news is removed from history

# Timer for checking significance
var time_since_last_check := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Eventbus.this.unit_died.connect(_on_unit_died)
	Eventbus.this.civ_reached_level.connect(_on_civ_reached_level)
	Eventbus.this.civ_descended_level.connect(_on_civ_descended_level)
	Eventbus.this.died.connect(_on_died)
	Eventbus.this.warriors_pushed.connect(_on_warriors_pushed)
	Eventbus.this.buildings_pushed.connect(_on_buildings_pushed)
	Eventbus.this.warriors_pulled.connect(_on_warriors_pulled)
	Eventbus.this.buildings_pulled.connect(_on_buildings_pulled)
	Eventbus.this.warriors_duplicated.connect(_on_warriors_duplicated)
	Eventbus.this.buildings_duplicated.connect(_on_buildings_duplicated)
	Eventbus.this.warriors_healed.connect(_on_warriors_healed)
	Eventbus.this.buildings_healed.connect(_on_buildings_healed)
	Eventbus.this.building_destroyed.connect(_on_building_destroyed)
	Eventbus.this.building_decayed.connect(_on_building_decayed)
	Eventbus.this.civ_changes_strategy.connect(_on_civ_changes_strategy)
	Eventbus.this.civ_goes_to_war.connect(_on_civ_goes_to_war)
	Eventbus.this.civ_science_upgrade.connect(_on_civ_science_upgrade)
	
	# Initialize last published times to 0
	for news_type in Constants.NewsType.values():
		last_published_time[news_type] = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_since_last_check += delta
	
	# Clean up expired news from history
	clean_expired_news_history()
	
	# Periodically evaluate which news is most significant
	if time_since_last_check >= check_interval:
		evaluate_and_publish_most_significant_news()
		time_since_last_check = 0.0

# Remove news from history that are older than the expire time
func clean_expired_news_history() -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	var i := recent_news_history.size() - 1
	while i >= 2:
		if current_time - recent_news_history[i].time > news_history_expire_time:
			recent_news_history.remove_at(i)
		i -= 1

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
	# War news has a hard limit - skip if it was in the last N news
	var war_sig := 0.0
	var war_in_recent_history := false
	for entry in recent_news_history:
		if entry.type == Constants.NewsType.War:
			war_in_recent_history = true
			break
	
	if not war_in_recent_history:
		war_sig = calculate_significance(deathCount, Constants.NewsType.War, war_significance_weight)
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
	
	# Building destroyed
	var building_destroyed_sig := calculate_significance(buildings_destroyed_count, Constants.NewsType.BuildingDestroyed, building_destroyed_significance_weight)
	if building_destroyed_sig > best_significance:
		best_significance = building_destroyed_sig
		best_news_type = Constants.NewsType.BuildingDestroyed
		best_count = buildings_destroyed_count
	
	# Building decayed
	var building_decayed_sig := calculate_significance(buildings_decayed_count, Constants.NewsType.BuildingDecayed, building_decayed_significance_weight)
	if building_decayed_sig > best_significance:
		best_significance = building_decayed_sig
		best_news_type = Constants.NewsType.BuildingDecayed
		best_count = buildings_decayed_count
	
	# Science breakthrough
	var science_sig := calculate_significance(science_upgrades_count, Constants.NewsType.ScienceBreakthrough, science_breakthrough_significance_weight)
	if science_sig > best_significance:
		best_significance = science_sig
		best_news_type = Constants.NewsType.ScienceBreakthrough
		best_count = science_upgrades_count
	
	# Single-event news types (always considered if data exists)
	if not last_civ_level_up.is_empty():
		var level_up_sig := civ_level_significance_weight * 10.0  # High base significance
		if level_up_sig > best_significance:
			best_significance = level_up_sig
			best_news_type = Constants.NewsType.CivLevel
			best_count = 0
	
	if not last_civ_level_down.is_empty():
		var level_down_sig := civ_level_down_significance_weight * 10.0
		if level_down_sig > best_significance:
			best_significance = level_down_sig
			best_news_type = Constants.NewsType.CivLevelDown
			best_count = 0
	
	if not last_strategy_change.is_empty():
		var strategy_sig := strategy_change_significance_weight * (15.0 if last_strategy_change.get("is_surprising", false) else 10.0)
		if strategy_sig > best_significance:
			best_significance = strategy_sig
			best_news_type = Constants.NewsType.StrategyChange
			best_count = 0
	
	if not last_war_declaration.is_empty():
		var war_decl_sig := war_declaration_significance_weight * 15.0  # Very high significance
		if war_decl_sig > best_significance:
			best_significance = war_decl_sig
			best_news_type = Constants.NewsType.WarDeclaration
			best_count = 0
	
	# If we found significant news, publish it
	if best_news_type != -1 && best_significance > 0:
		publish_news(best_news_type, best_count)
		last_published_time[best_news_type] = current_time
		
		# Update recent news history with timestamp
		recent_news_history.push_back({"type": best_news_type, "time": current_time})
		if recent_news_history.size() > war_news_cooldown_count:
			recent_news_history.pop_front()

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
		
		Constants.NewsType.BuildingDestroyed:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.BuildingDestroyed,
				"count": count
			})
			buildings_destroyed_count = 0
		
		Constants.NewsType.BuildingDecayed:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.BuildingDecayed,
				"count": count
			})
			buildings_decayed_count = 0
		
		Constants.NewsType.ScienceBreakthrough:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.ScienceBreakthrough,
				"count": count
			})
			science_upgrades_count = 0
		
		Constants.NewsType.CivLevel:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.CivLevel,
				"civ": last_civ_level_up.civ,
				"level": last_civ_level_up.level
			})
			last_civ_level_up.clear()
		
		Constants.NewsType.CivLevelDown:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.CivLevelDown,
				"civ": last_civ_level_down.civ,
				"level": last_civ_level_down.level
			})
			last_civ_level_down.clear()
		
		Constants.NewsType.StrategyChange:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.StrategyChange,
				"civ": last_strategy_change.civ,
				"old_strategy": last_strategy_change.old_strategy,
				"new_strategy": last_strategy_change.new_strategy,
				"is_surprising": last_strategy_change.is_surprising
			})
			last_strategy_change.clear()
		
		Constants.NewsType.WarDeclaration:
			news_ticker.add_to_queue({
				"type": Constants.NewsType.WarDeclaration,
				"civ_a": last_war_declaration.attacking_civ,
				"civ_b": last_war_declaration.receiving_civ
			})
			last_war_declaration.clear()

# Event subscriptions
func _on_died(unit: Unit) -> void:
	deathCount += 1;
	#print_debug("deathCount", deathCount)

func _on_unit_died(attacker_civ: Constants.Civilization, attacked_civ: Constants.Civilization, was_god_intervention: bool) -> void:
	print_debug(attacked_civ, attacked_civ, was_god_intervention)

func _on_civ_reached_level(civ: Constants.Civilization, level: int) -> void:
	last_civ_level_up = {"civ": civ, "level": level}

func _on_civ_descended_level(civ: Constants.Civilization, level: int) -> void:
	last_civ_level_down = {"civ": civ, "level": level}

func _on_building_destroyed(attacker_civ: Constants.Civilization, attacked_civ: Constants.Civilization, was_god_intervention: bool) -> void:
	buildings_destroyed_count += 1

func _on_building_decayed(civ: Constants.Civilization, buildingType: Constants.BuildingType) -> void:
	buildings_decayed_count += 1

func _on_civ_changes_strategy(civ: Constants.Civilization, old_strategy: Constants.CivilizationGoal, new_strategy: Constants.CivilizationGoal, is_surprising: bool) -> void:
	last_strategy_change = {
		"civ": civ,
		"old_strategy": old_strategy,
		"new_strategy": new_strategy,
		"is_surprising": is_surprising
	}

func _on_civ_goes_to_war(attacking_civ: Constants.Civilization, receiving_civ: Constants.Civilization) -> void:
	last_war_declaration = {
		"attacking_civ": attacking_civ,
		"receiving_civ": receiving_civ
	}

func _on_civ_science_upgrade(civ: Constants.Civilization, total_stat_levels: int, stats) -> void:
	science_upgrades_count += 1

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
