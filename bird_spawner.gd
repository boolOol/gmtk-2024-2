extends Node2D

@onready var timer:Timer = find_child("Timer")

func _ready() -> void:
	timer.timeout.connect(SpawnBird)
	
func SpawnBird():
	var birb = preload("res://vfx/birds/birds.tscn").instantiate()
	add_child(birb)
	birb.position = Vector2(0, randi_range(0,-1000))
	var s = randf_range(0.7,1.0)
	birb.scale = Vector2(s,s)
	var tween = create_tween()
	tween.tween_property(birb, "position", Vector2(-7000,birb.position.y),120)
	tween.finished.connect(birb.queue_free)
