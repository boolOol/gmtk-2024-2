extends Node2D

func _ready() -> void:
	generate()

func get_fitting_room(size:int) -> CONST.RoomType:
	var room = randi_range(0, CONST.RoomType.size() - 1)
	var room_size = CONST.ROOM_SIZES.get(room)
	
	var safety := 99
	while room_size > size:
		room = randi_range(0, CONST.RoomType.size() - 1)
		room_size = CONST.ROOM_SIZES.get(room)
		
		safety -= 1
		if safety <= 0:
			return 1
	return room

func generate(rooms := 10, building_width := 6):
	await get_tree().process_frame
	var floor := preload("res://src/floor/floor.tscn").instantiate()
	floor.offset = global_position
	floor.player_owned = false
	$Floors.add_child(floor)
	for i in building_width:
		floor.add_unit_at(Vector2(i, 0))
	
	var floor_index := 0
	var room_count := 0
	while room_count < rooms:
		var floor_filled := false
		var remaining_space := building_width
		while not floor_filled:
			var new_room_to_spawn : CONST.RoomType = get_fitting_room(remaining_space)
			floor.add_room(Vector2(building_width - remaining_space, -floor_index), new_room_to_spawn)
			remaining_space -= CONST.ROOM_SIZES.get(new_room_to_spawn)
			floor_filled = remaining_space <= 0
			room_count += 1
			if room_count >= rooms:
				break
		floor_index += 1
		if room_count >= rooms:
			break
		floor = preload("res://src/floor/floor.tscn").instantiate()
		$Floors.add_child(floor)
		floor.offset = global_position
		floor.player_owned = false
		for i in building_width:
			floor.add_unit_at(Vector2(i, -floor_index))
		#floor.position.y = floor_index * CONST.FLOOR_UNIT_HEIGHT
