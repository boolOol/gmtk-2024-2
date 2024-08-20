extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for shadow in get_children():
		shadow.make_person_shadow()
		shadow.move_range_min = -2000
		shadow.move_range_max = 2000
		shadow.scale.x = -1
		shadow.position.y += randf_range(-3, 3)
		shadow.position.x = randf_range(-2000, 2000)
