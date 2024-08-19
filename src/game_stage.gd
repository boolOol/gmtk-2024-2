extends Node2D

@onready var add_floor_container : CenterContainer = find_child("AddFloorContainer")
@onready var noti : PanelContainer = find_child("Notification")

var notification_tween:Tween

var is_broke := false

func _ready() -> void:
	is_broke = false
	noti.modulate.a = 0.0
	GameState.state_changed.connect(on_state_changed)
	GameState.set_state(GameState.State.Building)
	
	GameState.game_stage = self
	Data.property_changed.connect(on_property_changed)
	Data.apply("cash", 1000)
	Data.apply("idle_lives", 3)
	
	find_child("SummaryContainer").visible = false
	find_child("HelpContainer").visible = false
	find_child("OutOfLivesContainer").visible = false
	
	var t0 = get_tree().create_timer(2)
	t0.timeout.connect(notify.bind(
		"Hiiiiii!", 2.0, 3.0
	))
	var t1 = get_tree().create_timer(8)
	t1.timeout.connect(notify.bind(
		"Welcome to NEUBAUHAUS", 2.0, 3.5
	))
	var t2 = get_tree().create_timer(16)
	t2.timeout.connect(notify.bind(
		"Tear the other building apart\nto accomodate your residents :3", 6.0
	))
	var t3 = get_tree().create_timer(28)
	t3.timeout.connect(notify.bind(
		"When you're done assimilating the other apartment complex,\npress the button on the bottom right!", 8.0
	))

func on_state_changed(new_state:int):
	var button = find_child("FinishStageButton")
	match new_state:
		GameState.State.Building:
			button.text = "Next: Collect Rent"
		GameState.State.PickingTenants:
			button.text = "Next: Fill Empty Flats"
		GameState.State.Managing:
			button.text = "Next: Absorb Rival Building"
			show_month_summary()

func show_month_summary():
	Sound.sound("income")
	find_child("SummaryContainer").visible = true
	var building : Building = GameState.building
	
	var items : PackedStringArray = []
	var income := 0
	var expenditures := 0
	var handled_ids := []
	for id in building.household_id_by_coord.values():
		if handled_ids.has(id):
			continue
		handled_ids.append(id)
		var hh : Household = building.get_household_from_id(id)
		if not hh:
			continue
		hh.happiness += hh.happiness_change
		hh.happiness_change = 0
		var flat = building.get_flat_of_household(id)
		
		income += hh.rentToPay
		var flat_index = building.get_flat_index(flat.front())
		var flat_str = str("Floor ", flat_index.y, " - Flat ", flat_index.x)
		items.append(str(hh.household_name, " @ ", flat_str, " \t+$", hh.rentToPay))
	
	items.append("--------")
	var height_cost := 0
	for i in abs(GameState.highest_coord):
		if i >= CONST.PRICE_PER_HEIGHT.size():
			height_cost += CONST.PRICE_PER_HEIGHT.get(CONST.PRICE_PER_HEIGHT.size()-1)
		else:
			height_cost += CONST.PRICE_PER_HEIGHT.get(i)
	expenditures += height_cost
	items.append(str(abs(GameState.highest_coord) + 1, " Floors", ": -$", height_cost))
	
	items.append("========")
	items.append(str("Total Income: $", income - expenditures))
	
	Data.change_by_int("cash", income - expenditures)
	
	items.append(str("Total Funds: $", Data.of("cash")))
	
	if Data.of("cash") < 0:
		items.append("[font_size=60][color=red]\nYOU ARE BROKE. CLICK TO RESTART.[/color][/font_size]")
		is_broke = true
	
	find_child("Summary").text  = str("[left]", "\n".join(items))
	
func on_property_changed(property_name:String, old_value, new_value):
	match property_name:
		"cash":
			find_child("CashLabel").text = str("FUNDS: $", new_value)
		"idle_lives":
			find_child("LivesLabel").text = str("INVESTOR TOLERANCE: ", new_value)

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
	
	if id != -1 and id != 0: # occupied
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("advance"):
		if find_child("SummaryContainer").visible:
			find_child("SummaryContainer").visible = false
		else:
			go_to_next_state()

func _on_finish_stage_button_pressed() -> void:
	go_to_next_state()

func go_to_next_state():
	if Data.of("idle_lives") <= 0:
		return
	if GameState.state == GameState.State.Managing:
		if not GameState.expanded_this_phase:
			Data.change_by_int("idle_lives", -1)
			if Data.of("idle_lives") <= 0:
				find_child("OutOfLivesContainer").visible = true
			notify(
				"YOU DID NOT EXPAND.\nINVESTORS ARE DISPLEASED."
			)
		#print("expanded", GameState.expanded_this_phase)
		GameState.set_state(GameState.State.Building)
	elif GameState.state == GameState.State.Building:
		GameState.set_state(GameState.State.PickingTenants)
		ignore_list.clear()
		handle_empty_apartments()
	elif GameState.state == GameState.State.PickingTenants:
		GameState.set_state(GameState.State.Managing)
	find_child("FinishStageButton").visible = not GameState.is_state(GameState.State.PickingTenants)

var flats_to_handle := []
func handle_empty_apartments():
	flats_to_handle = GameState.building.get_empty_flats()
	var actually := []
	for flat in flats_to_handle:
		if flat in ignore_list:
			continue
		actually.append(flat)
	flats_to_handle = actually
	if flats_to_handle.is_empty():
		GameState.set_state(GameState.State.Managing)
		find_child("FinishStageButton").visible = true
		return
	var flat_to_handle = flats_to_handle.pop_back()
	find_child("TenantPicker").present_tenants(get_random_tenants(3), flat_to_handle)

func notify(message:String, duration:=5.0, fade_delay := 2.0):
	noti.modulate.a = 0.0
	noti.position.y = get_viewport_rect().size.y * 0.33
	if notification_tween:
		notification_tween.kill()
	noti.find_child("NotificationLabel").text = message
	notification_tween = create_tween()
	notification_tween.set_parallel()
	notification_tween.tween_property(noti, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT)
	notification_tween.tween_property(noti, "position:y", 25, 1.0).set_ease(Tween.EASE_OUT)
	notification_tween.tween_property(noti, "modulate:a", 0.0, duration).set_delay(fade_delay).set_ease(Tween.EASE_OUT_IN)

func _on_tenant_picker_tenant_picked_for_apartment(apartment_coords: Array, tenant: Dictionary) -> void:
	# building.occupy_flat race conditions are a funny thing (occupy_flat
	GameState.building.occupy_flat(apartment_coords, tenant)
	await get_tree().process_frame
	handle_empty_apartments()



func _on_permanent_reveal_check_box_toggled(toggled_on: bool) -> void:
	Data.apply("global.permanent_reveal", not toggled_on)


func _on_summary_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			find_child("SummaryContainer").visible = false

var ignore_list := []


func _on_tenant_picker_no_tenant_picked(apartment_coords: Array) -> void:
	ignore_list.append(apartment_coords)
	await get_tree().process_frame
	handle_empty_apartments()


func _on_summary_container_visibility_changed() -> void:
	if is_broke and not find_child("SummaryContainer").visible:
		get_tree().reload_current_scene()


func _on_help_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			find_child("HelpContainer").visible = false


func _on_out_of_lives_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_tree().reload_current_scene()


func _on_help_button_pressed() -> void:
	find_child("HelpContainer").visible = true
