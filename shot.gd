class_name Shot
extends Area2D

var faction: Constants.Civilization = 0
var direction: Vector2 = Vector2.RIGHT
@export var speed = 300
@export var damage: int = 40
@export var sprite: Sprite2D

var collided: bool = false

func _ready() -> void:
	sprite.material.set_shader_parameter("palette", load(Constants.civsToPaletteFilePaths[faction]))
	pass

func _physics_process(delta: float) -> void:
	position += direction * speed * delta # the shot does not follow the GodAbility's timewarp modifier, because high speed makes collisions problematic
	if !GroundController.this.get_ground_rectangle().grow(32).has_point(position):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	var unit: Unit = body as Unit
	if unit && unit.civilization != faction && !collided && !unit.is_dead:
		unit.hurt(self, damage)
		collided = true # prevent double collision in same frame.
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# TODO: make this a proper rectangle.
	queue_free()
