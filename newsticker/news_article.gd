extends Control

var threshold := 0.5;
var elapsed_time := 0.0;
var animation_played := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta;
	if !animation_played && elapsed_time > threshold:
		_play_animation();
		animation_played = true;

func _play_animation():
	$AnimationPlayer.play("show")
