class_name NewsTicker

extends Node2D

@onready var news_feed: VBoxContainer = $ScrollContainer/NewsFeed
@onready var scroll_container: ScrollContainer = $ScrollContainer

var news_queue: Array[Dictionary] = []

var news_article = preload("res://newsticker/news_article.tscn")
var time_since_last_news := 0.0;
var next_news_timestamp := 2.0 + randf() * 3.0;
var max_news_count := 8;

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
	next_news_timestamp = 2.0 + randf() * 3.0;
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
			spawn_news(Constants.UNIT_DIED, news)

		Constants.NewsType.CivLevel:
			var ctx := {
				"civ": news.civ,
				"level": news.level,
				"god": news.god
			}
			spawn_news(Constants.CIV_LEVEL, ctx)

		Constants.NewsType.Push:
			spawn_news(Constants.GOD_PUSH, news)

		Constants.NewsType.Pull:
			spawn_news(Constants.GOD_PULL, news)

		Constants.NewsType.Duplicate:
			spawn_news(Constants.GOD_DUPLICATE, news)

		Constants.NewsType.Heal:
			spawn_news(Constants.GOD_HEAL, news)

		_:
			new_generic_news()

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

func new_generic_news() -> void:
	spawn_news(Constants.GENERIC_NEWS, {})

func spawn_news(template_set: Dictionary, ctx: Dictionary) -> void:
	var i: int = randi() % template_set.headlines.size()

	var headline := format_text(template_set.headlines[i], ctx)
	var description := format_text(template_set.descriptions[i], ctx)

	var instance := news_article.instantiate()
	instance.headline_text = headline
	instance.description_text = description

	news_feed.add_child(instance)
	news_feed.move_child(instance, 0)
	
func clean_oldest_headline() -> void:
	if news_feed.get_child_count() > max_news_count:
		var children := news_feed.get_children();
		children.reverse()
		for n in children.size():
			if  n < children.size() - max_news_count:
				children[n].queue_free()

# News functions

func colorize(text: String, color: String) -> String:
	return "[color=%s]%s[/color]" % [color, text]

func shake(text: String) -> String:
	return "[shake rate=20 level=10]%s[/shake]" % [text]

func civ(civ: Constants.Civilization) -> String:
	var name: String = Constants.CIV_NAMES[civ]
	var color: Color = Constants.CIV_COLORS[civ]
	return colorize(name, color.to_html(false))

func event(text: String, type: String) -> String:
	return colorize(text, Constants.EVENT_COLORS[type].to_html(false))

func death(text: String) -> String:
	return shake(event(text, "death"))

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

	if ctx.get("god", false):
		t = "[s]%s[/s] %s" % [
			t,
			event("Divine intervention detected.", "event")
		]
	return t
