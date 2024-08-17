extends Node

enum State {
	Managing,
	Building,
	PickingTenants
}

signal state_changed(new_state:State)

var state := State.Managing
var building:Building

var camera:GameCamera
var drag_target : FloorUnit
var dragged_room : Room

func set_drag_target(target: FloorUnit):
	drag_target = target
	if dragged_room:
		dragged_room.set_dropability(can_room_fit_drag_target(dragged_room) and drag_target != null)



func can_room_fit_drag_target(room:Room) -> bool:
	if not drag_target:
		print("c")
		return false
	
	var floor : Floor = building.get_floor(drag_target.floor)
	if not floor:
		print("b")
		return false
	var size = CONST.ROOM_SIZES.get(room.room_type)
	var level = floor.get_index()
	
	print(size)
	for i in size:
		if floor.is_coord_occupied(Vector2(drag_target.h_index + i, level)):
			prints("a", Vector2(drag_target.h_index + i, level))
			return false
	return true

func is_state(value:State) -> bool:
	return value == state

func set_state(value:State):
	state = value
	emit_signal("state_changed", value)

func transfer_to_drag_target():
	if not dragged_room:
		return
	if not drag_target:
		return
	# bad code lmao
	var floor : Floor = drag_target.get_parent().get_parent()
	var coord = Vector2(drag_target.h_index, drag_target.floor)
	dragged_room.reparent(floor.get_node("Rooms"))
	dragged_room.global_position = MapMath.coord_to_pos(coord) + floor.offset
	
	var size = CONST.ROOM_SIZES.get(dragged_room.room_type)
	for i in size:
		prints("allocating ", Vector2(coord.x + i, coord.y))
		floor.rooms_by_coord[Vector2(coord.x + i, coord.y)] = dragged_room
	
	dragged_room.set_player_owned(true)
	camera.apply_shake()
