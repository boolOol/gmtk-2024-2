extends Node2D

class_name Household

var stats:Resource

var id := 0
var rent := 0
var rentToPay := 0
var rentMod :=1.0
var happiness := 100
var happiness_change := 0

var household_name:String

func serialize() -> Dictionary:
	var result := {}
	
	result["id"] = id
	result["rent"] = rent
	result["rentToPay"] = rentToPay
	result["rentMod"] = rentMod
	result["happiness"] = happiness
	result["happiness_change"] = happiness_change
	result["household_name"] = household_name
	result["stats"] = stats.duplicate()
	
	var people := []
	for person in $People.get_children():
		people.append(person.serialize())
	result["people"] = people
	
	return result

func deserialize(data: Dictionary):
	id = data.get("id")
	rent = data.get("rent")
	rentToPay = data.get("rentToPay")
	rentMod = data.get("rentMod")
	happiness = data.get("happiness")
	happiness_change = data.get("happiness_change")
	household_name = data.get("household_name")
	stats = data.get("stats")
	
	for person in $People.get_children():
		person.queue_free()
	
	for person in data.get("people"):
		var a = preload("res://sprites/people/person.tscn").instantiate()
		$People.add_child(a)
		a.deserialize(person)
	# do more shit

func build_from_resource(res:Resource):
	household_name = res.household_name
	var inhabitants = res.inhabitants
	for inhabitant in inhabitants:
		var child_scale:=1.0
		var offset = 0
		if inhabitant == 0: #adult
			pass
		elif inhabitant == 1:
			child_scale = 0.75
			offset = 32.0 * ((1-child_scale) * 0.5)
			
		
		var person = preload("res://sprites/people/person.tscn").instantiate()
		$People.add_child(person)
		person.scale = Vector2(child_scale, child_scale)
		person.scale.x = -1 if randf() <= 0.5 else 1
		person.position.y += offset
	stats = res
	
	var value := 0
	for coord in GameState.building.household_id_by_coord.keys():
		var household_id = GameState.building.household_id_by_coord.get(coord)
		if household_id != id:
			continue
		var room_type = GameState.building.get_room_type(coord)
		value += CONST.get_rent(room_type)
	rentToPay = value

func set_global_move_range(x_min:float, x_max:float):
	for person in $People.get_children():
		person.global_position.x = randf_range(x_min + 0.25, x_max - 0.25 + 1) * CONST.FLOOR_UNIT_WIDTH
