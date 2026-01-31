extends Node2D

@onready var news_feed: VBoxContainer = $ScrollContainer/NewsFeed
@onready var scroll_container: ScrollContainer = $ScrollContainer

var news_article = preload("res://newsticker/news_article.tscn")
var time_since_last_news := 0.0;
var next_news_timestamp := 1.0 + randf() * 3.0;

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
	"More than 50 warriors perished today as Blue and Red forces clashed on the harsh steppe tiles. Environmental damage combined with relentless combat turned the battlefield into a graveyard.",
	"The Green civilization officially advanced to level 5 this morning. Other hubs are reportedly increasing hostility, citing “an uncomfortable power imbalance.”",
	"A newly constructed watchtower successfully repelled multiple incoming enemy units before they reached the hub. Defense-oriented society goals appear to be paying off.",
	"Thanks to continuous investment in science buildings, Yellow civilization improved warrior movement speed. Faster units are already being observed crossing borders more aggressively.",
	"Following a shift to a war-focused society goal, Red civilization’s warriors hut has been spawning units at record rates. Scouts report a steady march toward hostile hubs.",
	"What was shaping up to be the largest battle so far was abruptly ended when a meteor obliterated the combat zone. A decisive victory seemed imminent nevermind, god threw a meteor at it, everybody’s dead.",
	"An attack on Blue civilization’s hub caused a sharp increase in hostility toward its aggressor. Retaliatory warrior deployments are expected within the next few ticks.",
	"Extended fighting degraded nearby grass tiles into steppe, slowly draining unit health over time. Commanders are now reconsidering long engagements in the area.",
	"A sudden lightning strike damaged multiple buildings and units clustered near a hub. Survivors are questioning whether spreading out might anger the gods less.",
	"In an unprecedented event, several warriors and buildings were duplicated instantly. Analysts are unsure whether this will destabilize the balance of power—or reality itself."
];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_since_last_news += delta;
	if time_since_last_news > next_news_timestamp:
		time_since_last_news = 0;
		next_news_timestamp = 1.0 + randf() * 3.0;
		new_headline();
		# scroll_container.get_v_scroll_bar().max_value
		#scroll_container.set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().max_value)

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
	
