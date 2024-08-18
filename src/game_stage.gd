extends Node2D

@onready var add_floor_container : CenterContainer = find_child("AddFloorContainer")



func _ready() -> void:
	GameState.set_state(GameState.State.Building)
	Data.property_changed.connect(on_property_changed)
	
	Data.apply("cash", 50000)

func on_property_changed(property_name:String, old_value, new_value):
	match property_name:
		"cash":
			find_child("CashLabel").text = str(new_value)

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
