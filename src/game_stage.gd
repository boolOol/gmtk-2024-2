extends Node2D

@onready var add_floor_container : CenterContainer = find_child("AddFloorContainer")



func _ready() -> void:
	GameState.set_state(GameState.State.Building)
	Data.property_changed.connect(on_property_changed)
	
	Data.apply("cash", 50)

func on_property_changed(property_name:String, old_value, new_value):
	match property_name:
		"cash":
			find_child("CashLabel").text = str(new_value)

func start_month():
	pass
	# get empty flats
	
	var flats = $Building.get_flats()
	# generate tenants for all of them


func _on_building_query_add_floor(coord: Vector2) -> void:
	add_floor_container.show_menu(coord)

func get_random_tenants(count:int):
	var result :Array[Resource]= []
	for i in count:
		result.append(GameState.building.get_household_res_from_enum(GameState.building.get_random_household()))
	return result
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
	#find_child("TenantPicker").present_tenants(get_random_tenants(3), )
