class_name NewsTicker

extends Control

@onready var news_feed: VBoxContainer = $ScrollContainer/NewsFeed
@onready var scroll_container: ScrollContainer = $ScrollContainer

var news_queue: Array[Dictionary] = []

var news_article = preload("res://newsticker/news_article.tscn")
var time_since_last_news := 0.0;
var next_news_timestamp := 2.0 + randf() * 3.0;
var max_news_count := 12;

var generic_headline_usage: Dictionary = {}
var generic_description_usage: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#func _on_unit_died(attacker, attacked, was_god):
	#var ctx := {
		#"civ_a": attacker,
		#"civ_b": attacked,
		#"count": randi_range(10, 80),
		#"god": was_god
	#}
	#spawn_news(Constants.UNIT_DIED, ctx)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_since_last_news += delta;
	if time_since_last_news < next_news_timestamp:
		return
		
	time_since_last_news = 0.0;
	next_news_timestamp = get_next_news_timestamp();
	#new_headline();
	#new_styled_headline();
	#var triggered_news = news_queue.front()
	
	if not news_queue.is_empty():
		var queued_news: Dictionary = news_queue.pop_front()
		handle_queued_news(queued_news)
	else:
		new_generic_news()
	clean_oldest_headline()
	#if (triggered_news != null):
		#switch (triggered_news.type):
			#case war:
				#spawn_news(Constants.UNIT_DIED, ctx);
			#case civ:
				#spawn_news(Constants.CIV_LEVEL, ctx);
	#else:
		#new_generic_news()
	#clean_oldest_headline()
	
func add_to_queue(dictionary: Dictionary) -> void:
	news_queue.push_front(dictionary)
	if (news_queue.size() > 5):
		news_queue.pop_back()
		#todo remove event type that appears most

func handle_queued_news(news: Dictionary) -> void:
	match news.type:
		Constants.NewsType.War:
			var news_desc := spawn_news(Constants.UNIT_DIED, news)
			Eventbus.this.update_score_from_text.emit(news_desc, false)

		Constants.NewsType.CivLevel:
			var ctx := {
				"civ": news.civ,
				"level": news.level,
				"god": news.god
			}
			var news_desc := spawn_news(Constants.CIV_LEVEL, ctx)
			Eventbus.this.update_score_from_text.emit(news_desc, false)

		Constants.NewsType.Push:
			var news_desc := spawn_news(Constants.GOD_PUSH, news)
			Eventbus.this.update_score_from_text.emit(news_desc, true)

		Constants.NewsType.Pull:
			var news_desc := spawn_news(Constants.GOD_PULL, news)
			Eventbus.this.update_score_from_text.emit(news_desc, true)

		Constants.NewsType.Duplicate:
			var news_desc := spawn_news(Constants.GOD_DUPLICATE, news)
			Eventbus.this.update_score_from_text.emit(news_desc, true)

		Constants.NewsType.Heal:
			var news_desc := spawn_news(Constants.GOD_HEAL, news)
			Eventbus.this.update_score_from_text.emit(news_desc, true)

		_:
			var news_desc := new_generic_news()
			Eventbus.this.update_score_from_text.emit(news_desc, false)

func create_war_news() -> void:
	pass

#func new_styled_headline() -> void:
	#var ctx := {
		#"civ_a": Constants.Civilization.Blue,
		#"civ_b": Constants.Civilization.Red,
		#"civ": Constants.Civilization.Purple,
		#"count": 57,
		#"level": 5,
		#"god": false
	#}
	#if randf() > 0.5:
		#spawn_news(Constants.UNIT_DIED, ctx);
	#else:
		#spawn_news(Constants.CIV_LEVEL, ctx);

func new_generic_news() -> String:
	var headline_index := get_weighted_random_index(Constants.GENERIC_NEWS.headlines.size(), generic_headline_usage)
	var description_index := get_weighted_random_index(Constants.GENERIC_NEWS.descriptions.size(), generic_description_usage)
	
	generic_headline_usage[headline_index] = generic_headline_usage.get(headline_index, 0) + 1
	generic_description_usage[description_index] = generic_description_usage.get(description_index, 0) + 1
	
	var ctx := {
		"headline_override": Constants.GENERIC_NEWS.headlines[headline_index],
		"description_override": Constants.GENERIC_NEWS.descriptions[description_index]
	}
	return spawn_news(Constants.GENERIC_NEWS, ctx)

func get_weighted_random_index(max_size: int, usage_dict: Dictionary) -> int:
	# Collect all unused indices (not in dict or count == 0)
	var unused_indices: Array[int] = []
	for i in range(max_size):
		if usage_dict.get(i, 0) == 0:
			unused_indices.append(i)
	
	# If there are unused items, pick randomly from them
	if not unused_indices.is_empty():
		return unused_indices[randi() % unused_indices.size()]
	
	# All items have been used - reset usage dict and pick from all
	usage_dict.clear()
	return randi() % max_size

func spawn_news(template_set: Dictionary, ctx: Dictionary) -> String:
	var headline: String
	var description: String
	
	if ctx.has("headline_override"):
		headline = format_text(ctx.headline_override, ctx)
		description = format_text(ctx.description_override, ctx)
	else:
		var i: int = randi() % template_set.headlines.size()
		headline = format_text(template_set.headlines[i], ctx)
		description = format_text(template_set.descriptions[i], ctx)

	var instance := news_article.instantiate()
	instance.headline_text = headline
	instance.description_text = description

	news_feed.add_child(instance)
	news_feed.move_child(instance, 0)
	return description
	
func clean_oldest_headline() -> void:
	if news_feed.get_child_count() > max_news_count:
		var children := news_feed.get_children();
		children.reverse()
		for n in children.size():
			if  n < children.size() - max_news_count:
				children[n].queue_free()

func get_next_news_timestamp() -> float:
	var next_time := 2.0 + randf() * 3.0
	if news_queue.size() > 4:
		next_time = 0.5
	elif news_queue.size() > 3:
		next_time = 1.0
	elif news_queue.size() > 2:
		next_time = 2.0
	elif news_queue.size() <= 2:
		next_time = 2.0 + randf() * 2.0
	return next_time













# News functions

func colorize(text: String, color: String) -> String:
	return "[color=%s]%s[/color]" % [color, text]

func shake(text: String) -> String:
	return "[shake rate=20 level=10]%s[/shake]" % [text]

func wave(text: String) -> String:
	return "[wave amp=50 freq=5]%s[/wave]" % [text]

func fade(text: String) -> String:
	return "[fade start=4 length=14]%s[/fade]" % [text]

func civ(civ: Constants.Civilization) -> String:
	var name: String = Constants.CIV_NAMES[civ]
	var color: Color = Constants.CIV_COLORS[civ]
	return colorize(name, color.to_html(false))

func event(text: String, type: String) -> String:
	return colorize(text, Constants.EVENT_COLORS[type].to_html(false))

func death(text: String) -> String:
	return shake(event(text, "death"))

func push_pull_event(text: String) -> String:
	return wave(event(text, "push_pull"))

func heal_event(text: String) -> String:
	return fade(event(text, "heal"))

func format_text(template: String, ctx: Dictionary) -> String:
	var t := template

	if "{CIV_A}" in t:
		t = t.replace("{CIV_A}", civ(ctx.civ_a))
	if "{CIV_B}" in t:
		t = t.replace("{CIV_B}", civ(ctx.civ_b))
	if "{CIV}" in t:
		t = t.replace("{CIV}", civ(ctx.civ))
	if "{COUNT}" in t:
		t = t.replace("{COUNT}", str(ctx.count))
	if "{LEVEL}" in t:
		t = t.replace("{LEVEL}", str(ctx.level))
	if "{DEATH}" in t:
		var death_words = ["perished", "died", "decomposed", "succumbed"]
		t = t.replace("{DEATH}", death(death_words[randi_range(0, death_words.size() - 1)]))
	if "{DISPLACED}" in t:
		var displaced_words = ["violently displaced", "flung aside", "scattered", "hurled away"]
		t = t.replace("{DISPLACED}", push_pull_event(displaced_words[randi_range(0, displaced_words.size() - 1)]))
	if "{PULLED}" in t:
		var pulled_words = ["pulled", "drawn", "dragged", "yanked"]
		t = t.replace("{PULLED}", push_pull_event(pulled_words[randi_range(0, pulled_words.size() - 1)]))
	if "{DUPLICATED}" in t:
		var duplicated_words = ["duplicated", "cloned", "replicated", "doubled"]
		t = t.replace("{DUPLICATED}", wave(event(duplicated_words[randi_range(0, duplicated_words.size() - 1)], "event")))
	if "{HEALED}" in t:
		var healed_words = ["miraculously healed", "restored", "rejuvenated", "regenerated"]
		t = t.replace("{HEALED}", heal_event(healed_words[randi_range(0, healed_words.size() - 1)]))

	if ctx.get("god", false):
		t = "[s]%s[/s] %s" % [
			t,
			event("Divine intervention detected.", "event")
		]
	return t
