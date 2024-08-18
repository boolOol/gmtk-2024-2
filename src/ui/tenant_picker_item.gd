extends Control

var tenant : Resource

signal tenant_picked(t:Dictionary)

var id := 0 # will also be set before present_tenant is called
var archetype := 0
var root_coord := Vector2.ZERO

@onready var label_income : Label = find_child("Income")
@onready var label_name : Label = find_child("HouseholdName")
@onready var label_rooms : RichTextLabel = find_child("PreferenceRooms")
@onready var label_neighbours : RichTextLabel = find_child("PreferenceNeighbours")

func _ready() -> void:
	visible = true

func present_tenant(t:Resource):
	tenant = t
	var t_name : String = t.household_name
	label_name.text = t_name
	label_income.text = "Income\n" + str(tenant.max_rent_range.x) + " - " +  str(tenant.max_rent_range.y)+ " $\n"
	
	var roomPref:String = ""
	for room in tenant.happy_rooms:
		roomPref += "[color=lawngreen]+ " + CONST.ROOM_NAMES.get(room) + "[/color]\n"
	for room in tenant.sad_rooms:
		roomPref += "[color=orangered]- " + CONST.ROOM_NAMES.get(room) + "[/color]\n"
	label_rooms.text = "Room Preferences:\n" +  roomPref
	
	var neighbourPref:String = ""
	for n in tenant.happy_neighbors:
		neighbourPref += "[color=lawngreen]+ " + CONST.HOUSEHOLD_NAMES.get(n) + "[/color]\n"
	for n in tenant.sad_neighbors:
		neighbourPref += "[color=orangered]- " + CONST.HOUSEHOLD_NAMES.get(n) + "[/color]\n"
	label_neighbours.text = "Neighbour Preferences:\n" +  neighbourPref
	
func pick_tenant():
	var rent = randi_range(tenant.max_rent_range.x, tenant.max_rent_range.y)
	
	visible = false
	
	emit_signal("tenant_picked", {
		"name" : tenant.household_name,
		"rent" : rent,
		"id": id,
		"resource": tenant,
		"archetype": archetype})


func _on_button_pressed() -> void:
	pick_tenant()
