extends Node2D

@onready var add_floor_container : CenterContainer = find_child("AddFloorContainer")



func _ready() -> void:
	GameState.set_state(GameState.State.Building)
	GameState.game_stage = self
	Data.property_changed.connect(on_property_changed)
	$FlatOverview.visible = false
	Data.apply("cash", 50000)

func on_property_changed(property_name:String, old_value, new_value):
	match property_name:
		"cash":
			find_child("CashLabel").text = str(new_value)

var last_clicked_coord := Vector2(5342,-45654)
func display_room_info(coord:Vector2):
	if last_clicked_coord == coord:
		$FlatOverview.visible = false
		last_clicked_coord = Vector2(5342,-45654)
		return
	prints("fdsdfg", coord, GameState.building.get_flat(coord))
	$FlatOverview.visible = true
	$FlatOverview.position = MapMath.coord_to_pos(coord)# + $Building.position
	$FlatOverview.position.x += CONST.FLOOR_UNIT_WIDTH * 2.5
	
	var flat = GameState.building.get_flat(coord)
	var rooms = GameState.building.get_room_types_of_flat(flat)
	var neighbors = GameState.building.get_adjacent_household_archetypes(coord)
	var id = GameState.building.get_household_id_of(coord)
	
	var room_string := ""
	var neighbor_string := ""
	find_child("EvictButton").visible = id != -1
	
	if id != -1: # occupied
		var data = GameState.building.household_data_by_id.get(id)
		# --- this is in data
		#"name" : tenant.household_name,
		#"rent" : rent,
		#"id": id,
		#"resource": tenant,
		#"archetype": archetype
	
		print("occupied")
		var resource = data.get("resource")
		var tenant_name = data.get("name")
		var archetype = data.get("archetype")
		var rent = data.get("rent")
		
		find_child("NameLabel").text = str(tenant_name)
		find_child("RentLabel").text = str(rent)
		
		var happy_rooms : Array[CONST.RoomType] = resource.happy_rooms
		var sad_rooms : Array[CONST.RoomType] = resource.happy_rooms
		var happy_neighbors : Array[CONST.HouseholdArchetype] = resource.happy_neighbors
		var sad_neighbors : Array[CONST.HouseholdArchetype] = resource.sad_neighbors
		
		for room in rooms:
			var color:Color
			if room in happy_rooms:
				color = Color.AQUAMARINE.to_html()
			elif room in sad_rooms:
				color = Color.ORANGE_RED.to_html()
			else:
				color = Color.LIGHT_BLUE.to_html()
			room_string += str("[color=#", color, "]", CONST.ROOM_NAMES.get(room), "[/color]")
			room_string += "\n"
		room_string = room_string.trim_suffix("\n")
	
		for nb in neighbors:
			var color:Color
			if nb in happy_neighbors:
				color = Color.AQUAMARINE.to_html()
			elif nb in sad_neighbors:
				color = Color.ORANGE_RED.to_html()
			else:
				color = Color.LIGHT_BLUE.to_html()
			neighbor_string += str("[color=#", color, "]", nb, "[/color]")
			neighbor_string += "\n"
		neighbor_string = neighbor_string.trim_suffix("\n")
	else:
		print("unoccupied flat")
		find_child("NameLabel").text = ""
		
		for room in rooms:
			room_string += CONST.ROOM_NAMES.get(room)
			room_string += "\n"
		room_string = room_string.trim_suffix("\n")
	
	
	
	find_child("RoomInfoLabel").text = room_string
	find_child("NeighborInfoLabel").text = neighbor_string
	last_clicked_coord = coord

func start_month():
	pass
	# get empty flats
	
	var flats = $Building.get_empty_flats()
	# generate tenants for all of them
	
	


func _on_building_query_add_floor(coord: Vector2) -> void:
	add_floor_container.show_menu(coord)

func get_random_tenants(count:int) -> Dictionary:
	var res :Array[Resource]= []
	
	var hh = []
	for i in count:
		hh.append(GameState.building.get_random_household())
	for h in hh:
		res.append(GameState.building.get_household_res_from_enum(h))
	return {"res":res, "archetypes":hh}


func _on_finish_stage_button_pressed() -> void:
	if GameState.state == GameState.State.Managing:
		GameState.set_state(GameState.State.Building)
	elif GameState.state == GameState.State.Building:
		GameState.set_state(GameState.State.PickingTenants)
		handle_empty_apartments()
	elif GameState.state == GameState.State.PickingTenants:
		GameState.set_state(GameState.State.Managing)
	find_child("FinishStageButton").visible = not GameState.is_state(GameState.State.PickingTenants)

var flats_to_handle := []
func handle_empty_apartments():
	flats_to_handle = GameState.building.get_empty_flats()
	if flats_to_handle.is_empty():
		GameState.set_state(GameState.State.Managing)
		find_child("FinishStageButton").visible = true
		return
	var flat_to_handle = flats_to_handle.pop_back()
	prints("handling", flat_to_handle)
	prints("handled flat has room types", GameState.building.get_room_types_of_flat(flat_to_handle))
	find_child("TenantPicker").present_tenants(get_random_tenants(3), flat_to_handle)
	

func _on_tenant_picker_tenant_picked_for_apartment(apartment_coords: Array, tenant: Dictionary) -> void:
	# building.occupy_flat race conditions are a funny thing (occupy_flat
	GameState.building.occupy_flat(apartment_coords, tenant)
	await get_tree().process_frame
	handle_empty_apartments()
