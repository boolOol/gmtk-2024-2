extends Control

var apartment_in_question:Array

signal tenant_picked_for_apartment(apartment_coords:Array, tenant:Dictionary)
signal no_tenant_picked(apartment_coords:Array)

func _ready() -> void:
	GameState.state_changed.connect(on_state_changed)
	visible = false

func on_state_changed(new_state:GameState.State):
	$VisibilityHover.visible = false


# apartment_amalgam is an array of indicies that make up the apartment
func present_tenants(tenants:Dictionary, apartment_amalgam:Array):
	var apartment_summary := "[center]The following applicants want to move into this flat:\n"
	for room_type in GameState.building.get_room_types_of_flat(apartment_amalgam):
		apartment_summary += CONST.ROOM_NAMES.get(room_type)
		apartment_summary += ", "
	apartment_summary = apartment_summary.trim_suffix(", ")
	var index = GameState.building.get_flat_index(apartment_amalgam.front())
	apartment_summary += str("\n", "It is located on floor ", index.y)
	
	find_child("FlatSummary").text = apartment_summary
	
	visible = true
	apartment_in_question = apartment_amalgam
	for child in find_child("ItemContainer").get_children():
		child.queue_free()
	var id:int
	
	var archetypes = tenants.get("archetypes")
	var res = tenants.get("res")
	var i := 0
	while i < tenants.keys().size():
		
		Data.change_by_int("household_counter", 1)
		id = Data.of("household_counter")
		var item = preload("res://src/ui/tenant_picker_item.tscn").instantiate()
		find_child("ItemContainer").add_child(item)
		item.root_coord = apartment_amalgam.front()
		item.tenant_picked.connect(on_tenant_picked)
		item.id = id
		item.archetype = archetypes[i]
		item.present_tenant(res[i])
		i += 1
	

func on_tenant_picked(tenant_data:Dictionary):
	visible = false
	
	# if no other empty flats
	#GameState.set_state(GameState.State.Building)
	
	
	emit_signal("tenant_picked_for_apartment", apartment_in_question, tenant_data)

var visibility_tween:Tween

func _on_visibility_hover_mouse_exited() -> void:
	if visibility_tween:
		visibility_tween.kill()
	visibility_tween = create_tween()
	visibility_tween.tween_property(find_child("ItemContainer"), "modulate:a", 1.0, 2.0)


func _on_visibility_hover_mouse_entered() -> void:
	if visibility_tween:
		visibility_tween.kill()
	visibility_tween = create_tween()
	visibility_tween.tween_property(find_child("ItemContainer"), "modulate:a", 0.0, 2.0)


func _on_ignore_button_pressed() -> void:
	visible = false
	emit_signal("no_tenant_picked", apartment_in_question)
	
