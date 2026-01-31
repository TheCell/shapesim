extends Node2D

@onready var news_feed: VBoxContainer = $ScrollContainer/NewsFeed
@onready var scroll_container: ScrollContainer = $ScrollContainer

var news_article = preload("res://newsticker/news_article.tscn")
var time_since_last_news := 0.0;
var next_news_timestamp := 2.0 + randf() * 3.0;
var max_news_count := 8;

var headline_text: Array[String] = [
	"Blood on the Steppe",
	"Green Civilization Reaches Level 5, Neighbors Nervous",
	"Watchtowers Prove Their Worth",
	"Scientific Breakthrough Accelerates Warfare",
	"Warriors Hut Working Overtime",
	"Meteor Strike Interrupts Historic Battle",
	"Hostility Spikes After Hub Damage",
	"Steppe Turns Deadly After Prolonged Conflict",
	"Lightning From the Sky Shatters Defenses",
	"Duplication Miracle Doubles an Army Overnight"
];
var description_text: Array[String] = [
	"More than 50 warriors [shake rate=20 level=10][color=red]perished[/color][/shake] today as [color=#ffaadd]Blue[/color] and Red forces clashed on the harsh steppe tiles. Environmental damage combined with relentless combat turned the battlefield into a graveyard.",
	"The Green civilization officially advanced [color=#ffaadd]Blue[/color]to level 5 this morning. Other hubs are reportedly increasing hostility, citing “an uncomfortable power imbalance.”",
	"A newly constructed watchtower successfully [color=#ffaadd]Blue[/color]repelled multiple incoming enemy units before they reached the hub. Defense-oriented society goals appear to be paying off.",
	"Thanks to continuous investment in science[color=#ffaadd]Blue[/color] buildings, Yellow civilization improved warrior movement speed. Faster units are already being observed crossing borders more aggressively.",
	"Following a shift to a war-focused society[color=#ffaadd]Blue[/color] goal, Red civilization’s warriors hut has been spawning units at record rates. Scouts report a steady march toward hostile hubs.",
	"What was shaping up to be the largest battle[color=#ffaadd]Blue[/color] so far was abruptly ended when a meteor obliterated the combat zone. A decisive victory seemed imminent nevermind, god threw a meteor at it, everybody’s dead.",
	"An attack on Blue civilization’s hub caused [color=#ffaadd]Blue[/color]a sharp increase in hostility toward its aggressor. Retaliatory warrior deployments are expected within the next few ticks.",
	"Extended fighting degraded nearby grass[color=#ffaadd]Blue[/color] tiles into steppe, slowly draining unit health over time. Commanders are now reconsidering long engagements in the area.",
	"A sudden lightning strike damaged [color=#ffaadd]Blue[/color]multiple buildings and units clustered near a hub. Survivors are questioning whether spreading out might anger the gods less.",
	"In an unprecedented event, several [color=#ffaadd]Blue[/color]warriors and buildings were duplicated instantly. Analysts are unsure whether this will destabilize the balance of power—or reality itself."
];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_unit_died(attacker, attacked, was_god):
	var ctx := {
		"civ_a": attacker,
		"civ_b": attacked,
		"count": randi_range(10, 80),
		"god": was_god
	}
	spawn_news(Constants.UNIT_DIED, ctx)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_since_last_news += delta;
	if time_since_last_news > next_news_timestamp:
		time_since_last_news = 0;
		next_news_timestamp = 1.0 + randf() * 3.0;
		#new_headline();
		new_styled_headline();
		# scroll_container.get_v_scroll_bar().max_value
		#scroll_container.set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().max_value)
		clean_oldest_headline()

func create_war_news() -> void:
	pass

func new_headline() -> void:
	var index := randi() % headline_text.size();
	var headline := headline_text[index];
	var description := description_text[index];
	var instance := news_article.instantiate();
	instance.headline_text = headline;
	instance.description_text = description;
	news_feed.add_child(instance)
	news_feed.move_child(instance, 0)
	# await get_tree().process_frame
	# scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func new_styled_headline() -> void:
	var ctx := {
		"civ_a": Constants.Civilization.Blue,
		"civ_b": Constants.Civilization.Red,
		"civ": Constants.Civilization.Purple,
		"count": 57,
		"level": 5,
		"god": false
	}
	if randf() > 0.5:
		spawn_news(Constants.UNIT_DIED, ctx);
	else:
		spawn_news(Constants.CIV_LEVEL, ctx);

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
func event_death(text: String) -> String:
	return shake(colorize(text, "red"))
	
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
		t = t.replace("{DEATH}", death("perished"))

	if ctx.get("god", false):
		t = "[s]%s[/s] %s" % [
			t,
			event("Divine intervention detected.", "event")
		]
	return t
