extends Control

var tenant : Resource

signal tenant_picked(t:Dictionary)

var id := 0 # will also be set before present_tenant is called

func _ready() -> void:
	visible = true

func present_tenant(t:Resource):
	tenant = t
	var t_name : String = t.household_name
	$VBoxContainer/RichTextLabel.text = str(id, " ", t_name)

func pick_tenant():
	var rent = randi_range(tenant.max_rent_range.x, tenant.max_rent_range.y)
	
	visible = false
	
	emit_signal("tenant_picked", {
		"name" : tenant.household_name,
		"rent" : rent,
		"id": id})


func _on_button_pressed() -> void:
	pick_tenant()
