class_name Shot
extends Area2D

var faction: Constants.Civilization = 0
var direction: Vector2
@export var speed = 300
@export var damage: int = 40

var collided: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	var unit: Unit = body as Unit
	if unit && unit.civilization != faction && !collided:
		unit.hurt(self, damage)
		collided = true # prevent double collision in same frame.
		queue_free()
