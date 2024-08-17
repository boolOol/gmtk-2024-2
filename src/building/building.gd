extends Node2D
class_name Building

@onready var ground_floor : Floor = find_child("GroundFloor")
@onready var add_unit_button : TextureButton = $AddUnitButton


@export_group("Households")
@export var student_flat_share:Resource
@export var apprentice:Resource
@export var ordinary_family:Resource
@export var single_parent:Resource
@export var young_couple:Resource
@export var workaholic:Resource
@export var polycule:Resource
@export var elderly_couple:Resource
@export var big_family:Resource
@export var widow:Resource
@export var ceo:Resource
@export var influencer_couple:Resource
@export var kevin:Resource
@export var drug_dealer:Resource
@export var marathon_couple :Resource

signal query_add_floor(coord:Vector2)

func _ready() -> void:
	GameState.building = self
	ground_floor.player_owned = true
	for i in 6:
		ground_floor.add_unit_at(Vector2(i, 0))


func _process(delta: float) -> void:
	var target_pos = get_local_mouse_position() - (add_unit_button.size * 0.25)
	add_unit_button.position = lerp(add_unit_button.position, target_pos, 0.2)
	
	var button_coord = add_unit_button.get_current_coord()
	add_unit_button.visible = can_coord_be_added(button_coord)



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print(get_flats())

func get_household_res_from_enum(value:CONST.HouseholdArchetype):
	match value:
		CONST.HouseholdArchetype.StudentFlatShare:
			return student_flat_share
		CONST.HouseholdArchetype.Apprentice:
			return apprentice
		CONST.HouseholdArchetype.OrdinaryFamily:
			return ordinary_family
		CONST.HouseholdArchetype.SingleParent:
			return single_parent
		CONST.HouseholdArchetype.YoungCouple:
			return young_couple
		CONST.HouseholdArchetype.Workaholic:
			return workaholic
		CONST.HouseholdArchetype.Polycule:
			return polycule
		CONST.HouseholdArchetype.ElderlyCouple:
			return elderly_couple
		CONST.HouseholdArchetype.BigFamily:
			return big_family
		CONST.HouseholdArchetype.Widow:
			return widow
		CONST.HouseholdArchetype.CEO:
			return ceo
		CONST.HouseholdArchetype.InfluencerCouple:
			return influencer_couple
		CONST.HouseholdArchetype.Kevin:
			return kevin
		CONST.HouseholdArchetype.DrugDealer:
			return drug_dealer
		CONST.HouseholdArchetype.MarathonCouple:
			return marathon_couple

func get_random_household() -> int:
	var pool := []
	for i in CONST.HouseholdArchetype.size():
		var res = get_household_res_from_enum(i)
		for j in res.popularity:
			pool.append(i)
	return pool.pick_random()

func get_flats() -> Array:
	var flats := []
	
	for floor : Floor in $Floors.get_children():
		var coords := floor.get_sorted_coords()
		var handled_rooms := [] # track separately bc of multi-slot rooms
		var flats_on_floor := []
		
		var flat_sequence := []
		for coord in coords:
			var is_empty = not floor.is_coord_occupied(coord)
			if is_empty:
				if not flat_sequence.is_empty():
					flats.append(flat_sequence.duplicate())
					flat_sequence.clear()
				continue
			flat_sequence.append(coord)
		if not flat_sequence.is_empty():
			flats.append(flat_sequence.duplicate())
	
	return flats

var occupation_by_flat := {}
var occupation_by_household_id := {}

func occupy_flat(flat_amalgam:Array, household_id:int):
	occupation_by_flat[flat_amalgam] = household_id
	occupation_by_household_id[household_id] = flat_amalgam

func get_empty_flats() -> Array:
	var flats = get_flats()
	var result := []
	
	for flat in flats:
		if occupation_by_flat.has(flat):
			continue
		result.append(flat)
	
	return result

func has_floor(index: int) -> bool:
	return get_floor(index) != null

func get_floor(index: int) -> Floor:
	index = abs(index)
	if index >= $Floors.get_child_count():
		return null
	return $Floors.get_child(index)

func add_floor_by_coord(coord: Vector2):
	add_floor(coord.x)

func add_floor(horizontal_index:int):
	var floor_count = $Floors.get_child_count()
	var floor = preload("res://src/floor/floor.tscn").instantiate()
	floor.player_owned = true
	$Floors.add_child(floor)
	floor.position = MapMath.coord_to_pos(Vector2(horizontal_index, -floor_count))# - global_position
	floor.add_unit_at(Vector2(horizontal_index, -floor_count))

func is_coord_free(coord: Vector2) -> bool:
	var floor := get_floor(coord.y)
	if not floor:
		return true
	return floor.get_unit(coord.x) == null

func is_coord_adjacent(coord: Vector2) -> bool:
	var has_adjacent:=false
	for offset in CONST.NEIGHBOR_OFFSETS:
		if not is_coord_free(coord + offset):
			has_adjacent = true
			break
	return has_adjacent

func can_coord_be_added(coord: Vector2):
	if not is_coord_free(coord):
		return false
	if not is_coord_adjacent(coord):
		return false
	if coord.y > 0:
		return false
	
	# only allow free-hanging units with 1 offset
	var floor_beneath := get_floor(abs(coord.y) - 1)
	if floor_beneath:
		var unit_beneath = floor_beneath.get_unit(coord.x)
		if not unit_beneath:
			var has_offset_step = floor_beneath.get_unit(coord.x - 1) != null or floor_beneath.get_unit(coord.x + 1) != null
			if not has_offset_step:
				return false
	
	return coord.x >= CONST.WIDTH_COORD_LIMIT.x and coord.x <= CONST.WIDTH_COORD_LIMIT.y

func request_add_unit(coord: Vector2):
	if not has_floor(coord.y):
		emit_signal("query_add_floor", coord)
		return
	var floor := get_floor(coord.y)
	floor.add_unit_at(coord)

func _on_add_unit_button_place_room_at(coord: Vector2) -> void:
	request_add_unit(coord)
