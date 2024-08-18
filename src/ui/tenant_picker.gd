extends Control

var apartment_in_question:Array

signal tenant_picked_for_apartment(apartment_coords:Array, tenant:Dictionary)


# apartment_amalgam is an array of indicies that make up the apartment
func present_tenants(tenants:Dictionary, apartment_amalgam:Array):
	visible = true
	apartment_in_question = apartment_amalgam
	for child in $HBoxContainer.get_children():
		child.queue_free()
	var id:int
	
	var archetypes = tenants.get("archetypes")
	var res = tenants.get("res")
	var i := 0
	while i < tenants.keys().size():
		
		Data.change_by_int("household_counter", 1)
		id = Data.of("household_counter")
		var item = preload("res://src/ui/tenant_picker_item.tscn").instantiate()
		$HBoxContainer.add_child(item)
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
	visibility_tween.tween_property($HBoxContainer, "modulate:a", 1.0, 2.0)


func _on_visibility_hover_mouse_entered() -> void:
	if visibility_tween:
		visibility_tween.kill()
	visibility_tween = create_tween()
	visibility_tween.tween_property($HBoxContainer, "modulate:a", 0.0, 2.0)
