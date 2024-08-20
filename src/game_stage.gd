extends Node2D

@onready var add_floor_container : CenterContainer = find_child("AddFloorContainer")
@onready var noti : PanelContainer = find_child("Notification")

@onready var build_label : Label = find_child("BuildLabel")
@onready var manage_label : Label = find_child("ManageLabel")
@onready var profit_label : Label = find_child("ProfitLabel")

var notification_tween:Tween

var is_broke := false

func _ready() -> void:
	# shit gets loud yo	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	get_tree().create_timer(2.5).timeout.connect(AudioServer.set_bus_mute.bind(AudioServer.get_bus_index("SFX"), false))

	
	is_broke = false
	noti.modulate.a = 0.0
	GameState.state_changed.connect(on_state_changed)
	GameState.set_state(GameState.State.Building)
	
	GameState.game_stage = self
	Data.property_changed.connect(on_property_changed)
	Data.apply("cash", 1500)
	Data.apply("idle_lives", 3)
	Data.apply("global.permanent_reveal", true)
	
	find_child("SummaryContainer").visible = false
	find_child("HelpContainer").visible = false
	find_child("OutOfLivesContainer").visible = false
	for child in find_child("Events").get_children():
		child.visible = false
	
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
		"Tear the other building apart\nto accomodate your residents :3", 6.0, 5.0
	))
	var t3 = get_tree().create_timer(28)
	t3.timeout.connect(notify.bind(
		"When you're done assimilating the other apartment complex,\ngo to the next phase by pressing\nthe button on the bottom right!", 8.0, 6.0
	))
	
	GameState.set_expanded_this_phase(true)

func on_state_changed(new_state:int):
	var button = find_child("FinishStageButton")
	match new_state:
		GameState.State.Building:
			button.text = "NEXT PHASE"
			#button.text = "Next: Collect Rent"
		GameState.State.PickingTenants:
			button.text = "NEXT PHASE"
			#button.text = "Next: Fill Empty Flats"
		GameState.State.Managing:
			button.text = "NEXT PHASE"
			#button.text = "Next: Absorb Rival Building"
			show_month_summary()
			find_child("LivesWarningLabel").visible = false
			

func show_month_summary():
	Sound.sound("income")
	find_child("SummaryContainer").visible = true
	var building : Building = GameState.building
	
	var items : PackedStringArray = []
	var income := 0
	var expenditures := 0
	var handled_ids := []
	
	var leaving_households : Array[Household] = []
	
	items.append(str("[font_size=30][b]SUMMARY[/b][/font_size]\n"))
	items.append(str("[b][color=lawngreen]Income:[/color][/b]"))
	
	for id in building.household_id_by_coord.values():
		if handled_ids.has(id):
			continue
		handled_ids.append(id)
		var hh : Household = building.get_household_from_id(id)
		if not hh:
			continue
		hh.happiness += hh.happiness_change
		hh.happiness_change = 0
		# if households is too unhappy, they leave
		if (hh.happiness <= 0): 
			leaving_households.append(hh)
			continue
		var flat = building.get_flat_of_household(id)
		
		income += hh.rentToPay
		var flat_index = building.get_flat_index(flat.front())
		var flat_str = str("Floor ", flat_index.y, " - Flat ", flat_index.x)
		items.append(str("[color=lawngreen]+ $", hh.rentToPay, "[/color]\t\t", hh.household_name, " @ ", flat_str, ))
	
	
	if (!leaving_households.is_empty()): 
		items.append("------------------------------------")
		items.append(str("[b][color=grey]Quitters:[/color][/b]"))
	for household in leaving_households:
		var flat = building.get_flat_of_household(household.id)
		var flat_index = building.get_flat_index(flat.front())
		building.evict(household.id)
		items.append(str(household.household_name, " was too unhappy and left. (", "Floor ", flat_index.y, " - Flat ", flat_index.x,")"))
	
	items.append("------------------------------------")
	items.append(str("[b][color=orangered]Expenses:[/color][/b]"))
	var height_cost := 0
	for i in abs(GameState.highest_coord):
		if i >= CONST.PRICE_PER_HEIGHT.size():
			height_cost += CONST.PRICE_PER_HEIGHT.get(CONST.PRICE_PER_HEIGHT.size()-1)
		else:
			height_cost += CONST.PRICE_PER_HEIGHT.get(i)
	expenditures += height_cost
	items.append(str("[color=orangered]- $", height_cost, "[/color]\t\t", abs(GameState.highest_coord) + 1, " Floors"))
	
	items.append("==================")
	if (income - expenditures >= 0):
		items.append(str("Total Income: \t[b][color=lawngreen]$", income - expenditures, "[/color][/b]"))
	else: items.append(str("Total Income: \t[b][color=orangered]$", income - expenditures, "[/color][/b]"))
	
	Data.change_by_int("cash", income - expenditures)
	
	items.append(str("Total Funds: \t[b]$", Data.of("cash"), "[/b]"))
	
	if Data.of("cash") < 0:
		items.append("[font_size=60][color=red]\nYOU ARE BROKE. CLICK TO RESTART.[/color][/font_size]")
		is_broke = true
	
	find_child("Summary").text  = str("[left]", "\n".join(items))
	
func on_property_changed(property_name:String, old_value, new_value):
	match property_name:
		"cash":
			find_child("CashLabel").text = str("$", new_value)
		"idle_lives":
			var container : HBoxContainer = find_child("LivesContainer")
			for child in container.get_children():
				child.queue_free()
			for i in new_value:
				var life = preload("res://src/ui/life.tscn").instantiate()
				container.add_child(life)
				

var last_clicked_coord := Vector2(5342,-45654)
var last_clicked_id := -1
func display_room_info(coord:Vector2):
	var clicked_id = GameState.building.household_id_by_coord.get(coord)
	if last_clicked_id == clicked_id:
		find_child("FlatInfo").visible = false
		last_clicked_coord = Vector2(5342,-45654)
		last_clicked_id = -1
		return
	find_child("FlatInfo").visible = true
	#find_child("FlatInfo").position = MapMath.coord_to_pos(coord)# + $Building.position
	#find_child("FlatInfo").position.x += CONST.FLOOR_UNIT_WIDTH * 2.5
	
	var opinions : Node2D = find_child("NeighborOpinions")
	for child in opinions.get_children():
		child.queue_free()
	
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
		
		var neighbor_ids = GameState.building.get_adjacent_household_ids(coord)
		for nid in neighbor_ids:
			var c:Vector2
			for coooord in GameState.building.household_id_by_coord:
				var hid = GameState.building.household_id_by_coord.get(coooord)
				if hid == nid:
					c = coooord
					
					var icon_pos = MapMath.coord_to_pos(c)
					var icon = Sprite2D.new()
					opinions.add_child(icon)
					icon.global_position = icon_pos
					icon.centered = false
					var a = GameState.building.get_household_archetype(id)
					if a in happy_neighbor_presences:
						icon.texture = load("res://src/household/spr_UI-happy.png")
					elif a in sad_neighbor_presences:
						icon.texture = load("res://src/household/spr_UI-sad.png")
					else:
						icon.texture = load("res://src/household/spr_UI-neutral.png")
		
		var flat_coords := []
		for indexed_coord in GameState.building.household_id_by_coord:
			if GameState.building.household_id_by_coord.get(indexed_coord) == id:
				flat_coords.append(indexed_coord)
		for flat_coord in flat_coords:
			var icon_pos = MapMath.coord_to_pos(flat_coord)
			var icon = Sprite2D.new()
			opinions.add_child(icon)
			icon.global_position = icon_pos
			icon.centered = false
			icon.texture = load("res://src/rooms/spr_UI-selectorSmallWhite.png")
			icon.modulate = Color(Color.AQUA, 0.7)
		
	else:
		
		for room in rooms:
			room_string += CONST.ROOM_NAMES.get(room)
			room_string += "\n"
		room_string = room_string.trim_suffix("\n")
	
	last_clicked_coord = coord
	last_clicked_id = clicked_id

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
		if GameState.dragged_room:
			return
		for child in find_child("Events").get_children():
			if child.visible:
				return
		if find_child("SummaryContainer").visible:
			find_child("SummaryContainer").visible = false
		elif find_child("HelpContainer").visible:
			find_child("HelpContainer").visible = false
		else:
			go_to_next_state()

func _on_finish_stage_button_pressed() -> void:
	go_to_next_state()

func go_to_next_state():
	if Data.of("idle_lives") <= 0:
		return
	if GameState.state == GameState.State.Managing:
		if not GameState.expanded_this_phase:
			notify("WARNING:\nEXPAND THE BUILDING OR ACQUIRE NEW ROOMS.")
		find_child("LivesWarningLabel").visible = false
		#print("expanded", GameState.expanded_this_phase)
		GameState.set_state(GameState.State.Building)
		resetPhaseLabel(profit_label)
		resetPhaseLabel(manage_label)
		highlightPhaseLabel(build_label)
		Sound.sound(Sound.button_build)
	elif GameState.state == GameState.State.Building:
		GameState.set_state(GameState.State.PickingTenants)
		#resetPhaseLabel(profit_label)
		#resetPhaseLabel(build_label)
		#highlightPhaseLabel(manage_label)
		Sound.sound(Sound.button_manage)
		find_child("LivesWarningLabel").visible = not GameState.expanded_this_phase
		
		if not GameState.expanded_this_phase:
			Data.change_by_int("idle_lives", -1)
			if Data.of("idle_lives") <= 0:
				find_child("OutOfLivesContainer").visible = true
			notify(
				"YOU DID NOT EXPAND.\nINVESTORS ARE DISPLEASED."
			)
		
		ignore_list.clear()
		handle_empty_apartments()
	elif GameState.state == GameState.State.PickingTenants:
		GameState.set_state(GameState.State.Managing)
		resetPhaseLabel(manage_label)
		resetPhaseLabel(build_label)
		highlightPhaseLabel(profit_label)
		Sound.sound(Sound.button_profit)
	find_child("FinishStageButton").visible = not GameState.is_state(GameState.State.PickingTenants)
	
func resetPhaseLabel(label: Label):
	if not label or not is_instance_valid(label):
		return
	label.remove_theme_color_override("font_color")
	label.add_theme_font_size_override("font_size", 25)
func highlightPhaseLabel(label: Label):
	if not label or not is_instance_valid(label):
		return
	label.add_theme_color_override("font_color", Color("ffcf00"))
	label.add_theme_font_size_override("font_size", 30)


var flats_to_handle := []
func handle_empty_apartments():
	#highlightPhaseLabel(manage_label)
	#resetPhaseLabel(build_label)
	#resetPhaseLabel(profit_label)
	GameState.set_state(GameState.State.PickingTenants)
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




var ignore_list := []


func _on_tenant_picker_no_tenant_picked(apartment_coords: Array) -> void:
	ignore_list.append(apartment_coords)
	await get_tree().process_frame
	handle_empty_apartments()


var first_event_blockers := 1
func _on_summary_container_visibility_changed() -> void:
	if not find_child("SummaryContainer").visible:
		if first_event_blockers > 0:
			first_event_blockers -= 1
			return
		roll_event()
		
		
		highlightPhaseLabel(manage_label)
		resetPhaseLabel(build_label)
		resetPhaseLabel(profit_label)
		Sound.sound(Sound.button_manage)
	else:
		resetPhaseLabel(manage_label)
		resetPhaseLabel(build_label)
		highlightPhaseLabel(profit_label)
		Sound.sound(Sound.button_profit)
	
	if is_broke and not find_child("SummaryContainer").visible:
		get_tree().reload_current_scene()

func roll_event():
	if randf() > CONST.EVENT_CHANCE:
		return
	Sound.sound("event")
	find_child("Events").get_children().pick_random().visible = true

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


func _on_summary_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			find_child("SummaryContainer").visible = false


func _on_new_story_button_pressed() -> void:
	var highest_y := 0
	var building : Building = GameState.building
	var highest_coord:=Vector2.ZERO
	for coord : Vector2 in building.get_all_coords():
		if coord.y < highest_y:
			highest_coord = coord
	building.add_floor(highest_coord.x)


func _on_flat_info_visibility_changed() -> void:
	find_child("NeighborOpinions").visible = find_child("FlatInfo").visible



func _on_lives_warning_label_visibility_changed() -> void:
	if find_child("LivesWarningLabel").visible:
		if find_child("LivesContainer").get_child_count() > 0:
			find_child("LivesContainer").get_child(0).set_in_danger(true)
	else:
		for child in find_child("LivesContainer").get_children():
			child.set_in_danger(false)
