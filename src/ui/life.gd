extends TextureRect

var in_danger := false
var lifetime := 0.0
var lol = 1

func set_in_danger(value:bool):
	in_danger = value

func _process(delta: float) -> void:
	lifetime += delta
	if in_danger:
		modulate.v = sin((lifetime - floor(lifetime)))
	else:
		modulate.v = 1.0
