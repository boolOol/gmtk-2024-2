extends Node2D

@onready var add_floor_container : CenterContainer = find_child("AddFloorContainer")
@onready var notification : PanelContainer = find_child("Notification")

var notification_tween:Tween

func _ready() -> void:
	notification.modulate.a = 0.0
	GameState.state_changed.connect(on_state_changed)
	GameState.set_state(GameState.State.Building)
	
	GameState.game_stage = self
	Data.property_changed.connect(on_property_changed)
	Data.apply("cash", 50000)

func on_state_changed(new_state:int):
	var button = find_child("FinishStageButton")
	match new_state:
		GameState.State.Building:
			button.text = "Next: Manage Building"
		GameState.State.PickingTenants:
			button.text = "Next: Fill Empty Flats"
		GameState.State.Managing:
			button.text = "Next: Absorb Rival Building"
		

func on_property_changed(property_name:String, old_value, new_value):
	match property_name:
		"cash":
			find_child("CashLabel").text = str(new_value)

var last_clicked_coord := Vector2(5342,-45654)
func display_room_info(coord:Vector2):
	if last_clicked_coord == coord:
		find_child("FlatInfo").visible = false
		last_clicked_coord = Vector2(5342,-45654)
		return
	find_child("FlatInfo").visible = true
	#find_child("FlatInfo").position = MapMath.coord_to_pos(coord)# + $Building.position
	#find_child("FlatInfo").position.x += CONST.FLOOR_UNIT_WIDTH * 2.5
	
	var flat = GameState.building.get_flat(coord)
	var flat_index = GameState.building.get_flat_index(coord)
	
	var rooms = GameState.building.get_room_types_of_flat(flat)
	var neighbors = GameState.building.get_adjacent_household_archetypes(coord)
	var id = GameState.building.get_household_id_of(coord)
	
	find_child("FlatInfo").set_id(id)
	find_child("FlatInfo").set_flat_index(flat_index)
	find_child("FlatInfo").handle_room_types_of_flat(rooms)
	find_child("FlatInfo").handle_neighbor_archetypes(neighbors)
	
	var room_string := ""
	var neighbor_string := ""
	
	if id != -1: # occupied
		var data = GameState.building.household_data_by_id.get(id)
		# --- this is in data
		#"name" : tenant.household_name,
		#"rent" : rent,
		#"id": id,
		#"resource": tenant,
		#"archetype": archetype
	
		var resource = data.get("resource")
		var tenant_name = data.get("name")
		var archetype = data.get("archetype")
		var rent = data.get("rent")
		
		#find_child("NameLabel").text = str(tenant_name)
		#find_child("RentLabel").text = str(rent)
		
		var happy_rooms : Array[CONST.RoomType] = resource.happy_rooms
		var sad_rooms : Array[CONST.RoomType] = resource.sad_rooms
		var happy_neighbors : Array[CONST.HouseholdArchetype] = resource.happy_neighbors
		var sad_neighbors : Array[CONST.HouseholdArchetype] = resource.sad_neighbors
		find_child("FlatInfo").set_happiness_preferences(
			happy_rooms,
			sad_rooms,
			happy_neighbors,
			sad_neighbors
		)
		
		var happy_room_presences := []
		var sad_room_presences := []
		var happy_neighbor_presences := []
		var sad_neighbor_presences := []
		
		for room in rooms:
			var color:Color
			if room in happy_rooms:
				happy_room_presences.append(room)
			elif room in sad_rooms:
				sad_room_presences.append(room)
			#else:
				#color = Color.LIGHT_BLUE.to_html()
			#room_string += str("[color=#", color, "]", CONST.ROOM_NAMES.get(room), "[/color]")
			#room_string += "\n"
		#room_string = room_string.trim_suffix("\n")
	
		for nb in neighbors:
			var color:Color
			if nb in happy_neighbors:
				happy_neighbor_presences.append(nb)
			elif nb in sad_neighbors:
				sad_neighbor_presences.append(nb)
			#else:
				#color = Color.LIGHT_BLUE.to_html()
			#neighbor_string += str("[color=#", color, "]", CONST.HOUSEHOLD_NAMES.get(nb), "[/color]")
			#neighbor_string += "\n"
		#neighbor_string = neighbor_string.trim_suffix("\n")
		
		find_child("FlatInfo").set_happiness_affectors(
			happy_room_presences,
			sad_room_presences,
			happy_neighbor_presences,
			sad_neighbor_presences
		)
	else:
		
		for room in rooms:
			room_string += CONST.ROOM_NAMES.get(room)
			room_string += "\n"
		room_string = room_string.trim_suffix("\n")
	
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
	find_child("TenantPicker").present_tenants(get_random_tenants(3), flat_to_handle)

func notify(message:String, duration:=5.0, fade_delay := 2.0):
	notification.modulate.a = 1.0
	if notification_tween:
		notification_tween.kill()
	notification.get_node("NotificationLabel").text = message
	notification_tween = create_tween()
	notification_tween.tween_property(notification, "modulate:a", 0.0, duration).set_delay(fade_delay).set_ease(Tween.EASE_OUT_IN)

func _on_tenant_picker_tenant_picked_for_apartment(apartment_coords: Array, tenant: Dictionary) -> void:
	# building.occupy_flat race conditions are a funny thing (occupy_flat
	GameState.building.occupy_flat(apartment_coords, tenant)
	await get_tree().process_frame
	handle_empty_apartments()



func _on_permanent_reveal_check_box_toggled(toggled_on: bool) -> void:
	Data.apply("global.permanent_reveal", not toggled_on)
