extends Control

@onready var score: RichTextLabel = $HBoxContainer/Score

@export var multiplier := 2;

var current_score := 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Eventbus.this.score_increased_by.connect(_on_score_increased_by)
	Eventbus.this._update_score_from_text.connect(_on_update_score_from_text)
	update_score_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_score_increased_by(score: int) -> void:
	current_score += score
	update_score_text()
	print_debug("_on_score_increased_by")
	
func _on_update_score_from_text(text: String, multiplier_active: bool) -> void:
	var score := 0
	if multiplier_active:
		score = text.length() * multiplier
	else:
		score = text.length()
	current_score += score

func update_score_text() -> void:
	score.text = "%s" % current_score;
