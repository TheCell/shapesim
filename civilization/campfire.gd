class_name Campfire
extends Building

func _ready() -> void:
	super._ready()
	sprite_2d.scale = Vector2.ONE * 2

func _process(delta: float) -> void:
	super._process(delta)
