extends Control

@export var headline_text := "Breaking";
@export var description_text := "Corporis itaque sequi qui magni. Non impedit asperiores qui ipsa. Qui dolorum omnis ea repellat velit quia architecto provident. Enim eveniet ducimus et. Ex velit voluptatibus nesciunt.";

@onready var headline: RichTextLabel = $Headline
@onready var text: RichTextLabel = $Text

var threshold := 0.5;
var elapsed_time := 0.0;
var animation_played := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	headline.text = headline_text
	text.text = description_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta;
	if !animation_played && elapsed_time > threshold:
		_play_animation();
		animation_played = true;

func _play_animation():
	$AnimationPlayer.play("show")
