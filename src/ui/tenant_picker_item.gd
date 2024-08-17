extends Control

var tenant : Resource

signal tenant_picked(t:Dictionary)

func _ready() -> void:
	visible = true

func present_tenants():
	visible = true
	for i in 3:
		var household = GameState.building.get_random_household
		present_tenant(GameState.building.get_household_res_from_enum(household))

func present_tenant(t:Resource):
	tenant = t
	var t_name : String = t.household_name
	

func pick_tenant():
	var rent = randi_range(tenant.max_rent_range.x, tenant.max_rent_range.y)
	
	visible = false
	
	emit_signal("tenant_picked", {"name" : tenant.household_name, "rent" : rent})


func _on_button_pressed() -> void:
	pick_tenant()
