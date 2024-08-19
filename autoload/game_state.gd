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
		building.get_household(Vector2(drag_target.h_index -1, -level)) and
		building.get_household(Vector2(drag_target.h_index +1, -level))):
			if not rude_debounce:
				GameState.build_indicator(
					str("Next-door construction\nwork is rude.\nEvict to expand.\n"),
					drag_target.global_position
				)
				rude_debounce = true
				var t = get_tree().create_timer(3)
				t.timeout.connect(set.bind("rude_debounce", false))
			return false
	
	return true

var rude_debounce := false

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
		#prints("allocating ", Vector2(coord.x + i, coord.y))
		floor.rooms_by_coord[Vector2(coord.x + i, coord.y)] = dragged_room
	
	dragged_room.set_player_owned(true)
	camera.apply_shake()
	Sound.sound("place")
	
	var adjacent_household:int
	var adjacent_coord:Vector2
	#prints("looking for adjacent in ", coord + Vector2.LEFT, coord + (Vector2.RIGHT * size))
	if building.get_household(coord + Vector2.LEFT):
		adjacent_coord = coord + Vector2.LEFT
		adjacent_household = building.get_household_id_of(adjacent_coord)
	if building.get_household(coord + (Vector2.RIGHT * size)):
		adjacent_coord = coord + (Vector2.RIGHT * size)
		adjacent_household = building.get_household_id_of(adjacent_coord)
	if adjacent_household != -1:
		building.household_id_by_coord[adjacent_coord] = adjacent_household
		for i in size:
			building.household_id_by_coord[coord + Vector2(i, 0)] = adjacent_household
		building.household_node_by_id[adjacent_household] = building.get_household_from_id(adjacent_household)
		
				
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
		var hgjdfj : Household = building.household_node_by_id.get(adjacent_household)
		var data = hgjdfj.serialize()
		var old_pos = hgjdfj.position
		hgjdfj.queue_free()
		var new = preload("res://src/household/household.tscn").instantiate()
		
		building.get_node("Tenants").add_child(new)
		new.deserialize(data)
		new.build_from_resource(new.stats)
		new.deserialize(data)
		new.position = old_pos
		building.household_node_by_id[adjacent_household] = new
		
		#new.position.y = CONST.FLOOR_UNIT_HEIGHT * 0.5
	
	if adjacent_household:
		building.update_flat_extents(adjacent_household)

func build_indicator(text_to_display:String, global_pos:Vector2, delay:=0.0, text_color:=Color.LAWN_GREEN, font_size:=32):
	var indicator = preload("res://src/ui/number_indicator.tscn").instantiate()
	game_stage.get_node("Indicators").add_child(indicator)
	indicator.start(text_to_display, global_pos, delay, text_color, font_size)
