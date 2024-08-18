extends Node


var properties := {}

signal property_changed(property_name:String, old_value, new_value)
signal room_added(at_coord:Vector2)

func _ready() -> void:
	apply("household_counter", 0)
	apply("global.permanent_reveal", false)
	for type in CONST.RoomType:
		apply(str("inventory.", type), 0)

func of(property_name: String, default=false):
	if not properties.has(property_name):
		push_warning(str(property_name, " doesn't exist. returning ", default))
	return properties.get(property_name, default)

func apply(property_name: String, value):
	var old_value = of(property_name, value)
	
	properties[property_name] = value
	
	emit_signal("property_changed", property_name, old_value, value)

func change_by_int(property_name: String, change:int):
	var value = of(property_name)
	if value is not int:
		push_warning(str(property_name, " is not an int"))
		return
	apply(property_name, value + change)
