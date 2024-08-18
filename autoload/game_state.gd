extends Node

enum State {
	Managing,
	Building,
	PickingTenants
}

var left_most_coord := 0
var right_most_coord := 0
var highest_coord := 0

signal state_changed(new_state:State)

var state := State.Managing
var building:Building
var game_stage:Node2D
var camera:GameCamera
var drag_target : FloorUnit
var dragged_room : Room

func set_drag_target(target: FloorUnit):
	drag_target = target
	if dragged_room:
		dragged_room.set_dropability(can_drag_target_fit_room(dragged_room) and drag_target != null)

var indicator_debounce := false


func can_drag_target_fit_room(room:Room) -> bool:
	if not drag_target:
		return false
	
	if Data.of("cash", 0) < CONST.get_price(room.room_type):
		if not indicator_debounce:
			build_indicator(
				str("Not enough cash.\n", CONST.ROOM_NAMES.get(room.room_type), " costs ", CONST.get_price(room.room_type)),
				room.get_center(),
				0.0,
				Color.MEDIUM_VIOLET_RED
				)
			indicator_debounce = true
			var t = get_tree().create_timer(3)
			t.timeout.connect(set.bind("indicator_debounce", false))
		return false
	
	var floor : Floor = building.get_floor(drag_target.floor)
	if not floor:
		return false
	var size = CONST.ROOM_SIZES.get(room.room_type)
	var level = floor.get_index()
	
	for i in size:
		if floor.is_coord_occupied(Vector2(drag_target.h_index + i, -level)):
			return false
			
	
	# squished between
	if (
		building.get_household(Vector2(drag_target.h_index -1, -level)) or
		building.get_household(Vector2(drag_target.h_index +1, -level))):
			GameState.build_indicator(
				str("Next-door construction work is rude.\nEvict either to expand.\n"),
				drag_target.global_position
			)
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
	var coord = Vector2(drag_target.h_index, -drag_target.floor)
	dragged_room.reparent(floor.get_node("Rooms"))
	dragged_room.floor = floor.get_index()
	dragged_room.coord = coord
	dragged_room.global_position = MapMath.coord_to_pos(coord) + floor.offset
	
	var size = CONST.ROOM_SIZES.get(dragged_room.room_type)
	for i in size:
		prints("allocating ", Vector2(coord.x + i, coord.y))
		floor.rooms_by_coord[Vector2(coord.x + i, coord.y)] = dragged_room
	
	dragged_room.set_player_owned(true)
	camera.apply_shake()
	Sound.sound("place")
	
	var adjacent_household
	if building.get_household(coord + Vector2.LEFT):
		adjacent_household = building.get_household(coord + Vector2.LEFT)
	if building.get_household(coord + Vector2.RIGHT):
		adjacent_household = building.get_household(coord + Vector2.RIGHT)
	if adjacent_household:
		var previous_flat:Array
		var new_flat:Array
		var hh
		for household in building.occupation_by_household_id:
			if household == adjacent_household:
				previous_flat = building.occupation_by_household_id[household]
				building.occupation_by_household_id[household].append(coord)
				building.occupation_by_household_id[household] = building.get_sorted_coords(building.occupation_by_household_id[household])
				new_flat = building.occupation_by_household_id[household]
				prints("merged ",coord,"into", building.occupation_by_household_id.get(household))
				hh = household
				break
		for flat in building.occupation_by_flat:
			if flat == previous_flat:
				building.occupation_by_flat[new_flat] = hh#building.occupation_by_flat.get(flat)
				building.occupation_by_flat.erase(previous_flat)
				
			#building.occupation_by_flat.has(adjacent_household)
		#if hh:
			#building.occupation_by_household_id[hh] = new_flat
			#building.occupation_by_flat[new_flat] = hh
			#var household = building.get_household_from_id(hh)
			#var value := 0
			#for flat_coord in new_flat:
				#value += CONST.get_rent(building.get_room_type(flat_coord))
			#household.rentToPay = household.rentMod * value
		#
	#for o in building.occupation_by_flat:
		#if building.occupation_by_flat.get(o) == null or not is_instance_valid(o):
			#building.occupation_by_flat.erase(o)
	#
	var price : int = CONST.get_price(dragged_room.room_type)
	build_indicator(
		str("-",price),
		dragged_room.get_center(),
		2.0,
		Color.CRIMSON)
	build_indicator(
		CONST.ROOM_NAMES.get(dragged_room.room_type),
		dragged_room.get_center(),
		0.0,
		Color.CORAL)
	Data.change_by_int("cash", -price)
	
	building.get_adjacent_neighbors(coord)
	
	if adjacent_household:
		building.update_flat_extents(adjacent_household)

func build_indicator(text_to_display:String, global_pos:Vector2, delay:=0.0, text_color:=Color.LAWN_GREEN, font_size:=32):
	var indicator = preload("res://src/ui/number_indicator.tscn").instantiate()
	building.add_child(indicator)
	indicator.start(text_to_display, global_pos, delay, text_color, font_size)
