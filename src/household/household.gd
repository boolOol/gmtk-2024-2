extends Node2D

var stats:Resource

var id := 0
var rent := 0
var happiness := 100

var household_name:String

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
			offset = 32.0 * (1-child_scale)
			
		
		var person = preload("res://sprites/people/person.tscn").instantiate()
		$People.add_child(person)
		person.scale = Vector2(child_scale, child_scale)
		person.scale.x = -1 if randf() <= 0.5 else 1
		person.position.y += offset
	stats = res

func set_global_move_range(x_min:float, x_max:float):
	for person in $People.get_children():
		person.global_position.x = randf_range(x_min + 0.25, x_max - 0.25 + 1) * CONST.FLOOR_UNIT_WIDTH
