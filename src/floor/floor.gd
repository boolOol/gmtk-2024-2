extends Area2D
class_name Floor

@onready var seethrough_tween : Tween
# is assumed to be there in all scenes that inherit from this
@onready var hover_area := $HoverArea
@onready var front_wall := $FrontWall
@onready var rooms := $Rooms

var offset := Vector2.ZERO
var player_owned : bool

var rooms_by_coord := {}
var units_by_coord := {}

signal propagate_wall_update(originator:Floor)

func update_walls():
	var highest_point_by_x := {}
	var righest_point_by_y := {}
	
	for wall in $FrontWall.get_children():
		wall.queue_free()
	for coord in units_by_coord:
		var highest = coord.y == GameState.highest_coord
		var left = coord.x == GameState.left_most_coord
		var right = coord.x == GameState.right_most_coord
		var ground = coord.x == 0
		
		var tex_str := "res://src/building/sprites/spr_building-"
		if ground:
			tex_str += "ground"
		elif highest:
			tex_str += "top"
		else:
			tex_str += "middle"
		tex_str += "Floor"
		
		if left:
			tex_str += "Left"
		elif right:
			tex_str += "Right"
		else:
			tex_str += "Center"
		tex_str += "01"
		#tex_str += str(int(coord.x)%3+1)
		tex_str += ".png"
		
		var wall = Sprite2D.new()
		wall.texture = load(tex_str)
		$FrontWall.add_child(wall)
		wall.global_position.x = coord.x * CONST.FLOOR_UNIT_WIDTH
		wall.global_position.y = coord.y * CONST.FLOOR_UNIT_HEIGHT
		wall.centered = false
	emit_signal("propagate_wall_update", self)

func get_sorted_rooms() -> Array:
	var keys := rooms_by_coord.keys().duplicate()
	keys.sort_custom(sort_coords)
	
	var result := []
	for key in keys:
		result.append(rooms_by_coord.get(key))
	
	return result
func get_sorted_units() -> Array:
	var keys := units_by_coord.keys().duplicate()
	keys.sort_custom(sort_coords)
	
	var result := []
	for key in keys:
		result.append(units_by_coord.get(key))
	
	return result
func get_sorted_coords() -> Array:
	var keys := units_by_coord.keys().duplicate()
	keys.sort_custom(sort_coords)
	return keys
func sort_coords(coord_a: Vector2, coord_b: Vector2):
	return coord_a.x < coord_b.x

func _ready():
	
	hover_area.shape.size.x = CONST.FLOOR_UNIT_WIDTH * CONST.MAX_WIDTH
	hover_area.shape.size.y = CONST.FLOOR_UNIT_HEIGHT
	
	Data.property_changed.connect(on_property_changed)


func on_property_changed(property_name:String, old_value, new_value):
	match property_name:
		"global.permanent_reveal":
			$FrontWall.visible = new_value
	
# note: can return null
func get_unit(index:int) -> FloorUnit:
	var found_unit:FloorUnit
	for unit : FloorUnit in $Units.get_children():
		if unit.h_index == index:
			found_unit = unit
			break
	return found_unit

func add_unit_at(coord:Vector2):
	var is_empty := $Units.get_child_count() == 0
	var target_pos = MapMath.coord_to_pos(coord)
	var unit = preload("res://src/floor/floor_unit.tscn").instantiate()
	$Units.add_child(unit)
	unit.floor = get_index()
	unit.global_position = target_pos + offset
	unit.h_index = coord.x
	unit.player_owned = player_owned
	units_by_coord[coord] = unit
	
	var min_x = get_min_unit_x(unit.position.x)
	var max_x = get_max_unit_x(unit.position.x)
	
	$HoverArea.position.x = min_x
	$HoverArea.shape.size.x = max_x - min_x
	
	update_walls()
	
	if player_owned:
		if coord.x < GameState.left_most_coord:
			GameState.left_most_coord = coord.x
		if coord.x > GameState.right_most_coord:
			GameState.right_most_coord = coord.x

func get_min_unit_x(start:=999) -> float:
	var min_x = start
	for u in $Units.get_children():
		if u.position.x < min_x:
			min_x = u.position.x
	return min_x

func get_max_unit_x(start:=-999) -> float:
	var max_x = start
	for u in $Units.get_children():
		if u.position.x > max_x:
			max_x = u.position.x
	return max_x

func on_mouse_entered():
	if Data.of("global.permanent_reveal"):
		return
	if seethrough_tween:
		seethrough_tween.kill()
	seethrough_tween = create_tween()
	seethrough_tween.tween_property(front_wall, "modulate:a", 0, CONST.REVEAL_FADE_TIME).set_ease(Tween.EASE_OUT_IN)

func on_mouse_exited():
	if Data.of("global.permanent_reveal"):
		return
	if seethrough_tween:
		seethrough_tween.kill()
	seethrough_tween = create_tween()
	seethrough_tween.tween_property(front_wall, "modulate:a", 1, CONST.REVEAL_FADE_TIME).set_ease(Tween.EASE_OUT_IN)

func add_room(coord: Vector2, room_type:CONST.RoomType):
	var room = preload("res://src/rooms/room.tscn").instantiate()
	$Rooms.add_child(room)
	if GameState.game_stage:
		room.request_room_info.connect(GameState.game_stage.display_room_info)
	room.coord = coord
	room.set_player_owned(player_owned)
	room.global_position = MapMath.coord_to_pos(coord) + offset
	room.set_room_type(room_type)
	room.floor = get_index()
	
	var size = CONST.ROOM_SIZES.get(room.room_type)
	for i in size:
		rooms_by_coord[Vector2(coord.x + i, coord.y)] = room

func is_coord_occupied(coord:Vector2, non_existent_as_occupied:=true):
	if not units_by_coord.has(coord):
		prints("no ", coord, " in ", units_by_coord)
		return non_existent_as_occupied
	
	return rooms_by_coord.has(coord)


func build_front_wall():
	pass
	# needs to be based on the appearance of each underlying unit for balconies
	# always override on the right most side with corresponding sprite
