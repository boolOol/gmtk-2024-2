extends Node

func pos_to_coord(global_pos: Vector2) -> Vector2:
	var x_coord : int = floor(global_pos.x / float(CONST.FLOOR_UNIT_WIDTH))
	var y_coord : int = floor((global_pos.y + CONST.FLOOR_UNIT_HEIGHT * 0.5) / float(CONST.FLOOR_UNIT_HEIGHT))
	return Vector2(x_coord + 1, y_coord)

## Global Position
func coord_to_pos(coord:Vector2) -> Vector2:
	return Vector2(coord.x * CONST.FLOOR_UNIT_WIDTH, coord.y * CONST.FLOOR_UNIT_HEIGHT)

func floor_indeces_to_coord(x: int, y: int) -> Vector2:
	return Vector2(x * CONST.FLOOR_UNIT_WIDTH, y * CONST.FLOOR_UNIT_HEIGHT)

func get_transparency(mouse_dist: float, transparency_start_at, full_transparency_at) -> float:
	if mouse_dist <= full_transparency_at:
		return 0.0
	else:
		return clamp(pow((1.0 - pow(clamp((transparency_start_at / (mouse_dist - full_transparency_at)), 0, 1), 4)), 2), 0, 1)
	
