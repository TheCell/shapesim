extends Node

var health := 10.0;
var damage_ticker := 1.0 + 5.0 * randf();
var take_damage_after := 2.4;
var elapsed_time := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta;
	if (elapsed_time > take_damage_after):
		elapsed_time = fmod(elapsed_time, take_damage_after);
		take_damage(damage_ticker);
	
func take_damage(damage: int) -> void:
	# reduce health
	health -= damage;
	print_debug("I lost health, remaining %f" % health)
	if (health <= 0):
		Events.unit_died_for_civ.emit(Constants.Civilization.Red)
		print_debug('oh no I died');
		queue_free();
	
	
