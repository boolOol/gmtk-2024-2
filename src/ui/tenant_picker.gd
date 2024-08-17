extends Control

var apartment_in_question:Array

signal tenant_picked_for_apartment(apartment_coords:Array[Vector2], tenant:Dictionary)


# apartment_amalgam is an array of indicies that make up the apartment
func present_tenants(tenants:Array[Resource], apartment_amalgam:Array):
	apartment_in_question = apartment_amalgam
	for child in $HBoxContainer.get_children():
		child.queue_free()
	for i in tenants:
		var item = preload("res://src/ui/tenant_picker_item.tscn").instantiate()
		$HBoxContainer.add_child(item)
		item.present_tenant(i)
		item.tenant_picked.connect(on_tenant_picked)
	

func on_tenant_picked(lol:Dictionary):
	visible = false
	GameState.set_state(GameState.State.Building)
	
	emit_signal("tenant_picked_for_apartment", apartment_in_question, lol)

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
