extends Node2D

var lifetime := 3

func _ready() -> void:
	generate()
	GameState.state_changed.connect(on_state_changed)

func on_state_changed(new_state:int):
	if GameState.is_state(GameState.State.Managing):
		lifetime -= 1
		if lifetime <= 0:
			reset()

func reset():
	for floor : Floor in $Floors.get_children():
		floor.queue_free()
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("default")
	var width := randi_range(4, 8)
	generate(randi_range(8, 34), width)
	lifetime = 3
	Sound.sound("explosion")
	
	GameState.build_indicator(
		"A new building appears!",
		global_position + Vector2((width * 0.5) * CONST.FLOOR_UNIT_WIDTH, 0),
		0.0, Color.AQUAMARINE, 50
	)

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
