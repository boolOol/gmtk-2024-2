extends TextureButton

signal place_room_at(coord:Vector2)

func get_current_coord() -> Vector2:
	var center = global_position - size * 0.5
	return MapMath.pos_to_coord(center)

func _on_pressed() -> void:
	emit_signal("place_room_at", get_current_coord())
