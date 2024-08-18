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
var occupation_by_flat := {}
var occupation_by_household_id := {}
var household_data_by_id := {} # filled with tenant data
var household_node_by_id := {} # filled with Household.tscn

func _ready() -> void:
	GameState.building = self
	ground_floor.player_owned = true
	for i in 6:
		ground_floor.add_unit_at(Vector2(i, 0))
	add_floor(0)
	for i in 5:
		get_floor(1).add_unit_at(Vector2(i + 1, -1))
	add_floor(0)
	for i in 5:
		get_floor(2).add_unit_at(Vector2(i + 1, -2))
	


func _process(delta: float) -> void:
	var target_pos = get_local_mouse_position() - (add_unit_button.size * 0.25)
	add_unit_button.position = lerp(add_unit_button.position, target_pos, 0.2)
	
	var button_coord = add_unit_button.get_current_coord()
	add_unit_button.visible = can_coord_be_added(button_coord) and GameState.is_state(GameState.State.Managing)
	$Ghost.visible = add_unit_button.visible
	if add_unit_button.visible:
		var mouse_coord = MapMath.pos_to_coord(get_global_mouse_position())
		$Ghost.global_position = (mouse_coord * CONST.FLOOR_UNIT_HEIGHT)# - global_position
		$Ghost.global_position -= Vector2(CONST.FLOOR_UNIT_WIDTH, CONST.FLOOR_UNIT_HEIGHT) * 0.5

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

func get_sorted_coords(coords:Array) -> Array:
	coords = coords.duplicate()
	coords.sort_custom(sort_coords)
	return coords
func sort_coords(coord_a: Vector2, coord_b: Vector2):
	return coord_a.x < coord_b.x

func get_flats() -> Array:
	var flats := []
	
	for floor : Floor in $Floors.get_children():
		var coords := floor.get_sorted_coords()
		prints("floor", floor.get_index(), "has coords", coords)
		var handled_rooms := [] # track separately bc of multi-slot rooms
		var flats_on_floor := []
		
		var flat_sequence := []
		
		for coord in coords:
			var is_empty = not floor.is_coord_occupied(coord)
			if is_empty:
				if not flat_sequence.is_empty():
					flats.append(get_sorted_coords(flat_sequence.duplicate()))
					flat_sequence.clear()
				continue
			
			if not handled_rooms.has(get_room(coord)):
				flat_sequence.append(coord)
			handled_rooms.append(get_room(coord))
		if not flat_sequence.is_empty():
			flats.append(get_sorted_coords(flat_sequence.duplicate()))
	prints("returning flats", flats)
	return flats


func occupy_flat(flat_amalgam:Array, tenant_data:Dictionary):
	var household_id = tenant_data.get("id")
	occupation_by_flat[flat_amalgam] = household_id
	occupation_by_household_id[household_id] = flat_amalgam
	household_data_by_id[household_id] = tenant_data
	
	
	var tenant_layer = $Tenants
	var tenant = preload("res://src/household/household.tscn").instantiate()
	tenant_layer.add_child(tenant)
	tenant.global_position.y = flat_amalgam.front().y * CONST.FLOOR_UNIT_HEIGHT + (CONST.FLOOR_UNIT_HEIGHT * 0.5)
	tenant.global_position.y -= 2
	tenant.id = household_id
	tenant.rent = tenant_data.get("rent")
	tenant.build_from_resource(tenant_data.get("resource"))
	
	household_node_by_id[household_id] = tenant
	
	update_flat_extents(tenant.id)

func update_flat_extents(household_id:int):
	var flat_amalgam = occupation_by_household_id.get(household_id)
	var tenant = get_household_from_id(household_id)
	var extents = get_physical_flat_extents(flat_amalgam)
	tenant.set_global_move_range(extents.x, extents.y)

func get_room_type(coord:Vector2):
	var room = get_room(coord)
	if not room:
		return -1
	return room.room_type



func get_adjacent_household_ids(coord:Vector2) -> Array:
	var adjacent_coords = get_adjacent_coords_to_flat(get_flat(coord))
	print("coords adjacent to ", coord, ": ", adjacent_coords)
	var ids := []
	for acoord in adjacent_coords:
		var id = get_household_id_of(acoord)
		if not ids.has(id):
			ids.append(id)
	
	return ids

func get_adjacent_household_archetypes(coord:Vector2) -> Array:
	var archetypes := []
	
	var adjacent_households = get_adjacent_household_ids(coord)
	prints("adjacent hh", adjacent_households)
	for ahh in adjacent_households:
		if ahh == -1:
			continue
		var archetype = household_data_by_id.get(ahh).get("archetype")
		archetypes.append(archetype)
	
	return archetypes

func get_room_types_of_flat(flat:Array) -> Array:
	var rooms := []
	var handled_rooms := []
	for coord in flat:
		var room = get_room(coord)
		if not handled_rooms.has(room):
			rooms.append(room.room_type)
		handled_rooms.append(room)
	return rooms

func get_room(coord: Vector2):
	if not get_floor(coord.y):
		return null
	return get_floor(coord.y).rooms_by_coord.get(coord)

func get_household_from_id(id:int):
	for h in $Tenants.get_children():
		if h.id == id:
			return h
	return null

func get_physical_flat_extents(flat:Array) -> Vector2:
	var min_x = 99999
	var max_x = -99999
	
	for coord : Vector2 in flat:
		if coord.x < min_x:
			min_x = coord.x
		if coord.x > max_x:
			max_x = coord.x
	return Vector2(min_x, max_x)

func get_empty_flats() -> Array:
	var flats = get_flats()
	var result := []
	
	for flat in flats:
		if occupation_by_flat.has(flat):
			continue
		result.append(flat)
	return result

func get_adjacent_coords_to_flat(flat:Array):
	var coords := []
	prints("checking flat", flat)
	for cell in flat:
		for neighbor in CONST.NEIGHBOR_OFFSETS:
			var offset = cell + neighbor
			prints(offset, " does exist?", does_coord_exist(offset))
			if (not coords.has(offset)) and does_coord_exist(offset):
				coords.append(offset)
	return coords

func get_household_id_of(coord:Vector2) -> int:
	var a = occupation_by_flat
	for flat : Array in occupation_by_flat:
		if flat.has(coord):
			return occupation_by_flat.get(flat)
	return -1

func get_flat(coord:Vector2) -> Array:
	for flat in get_flats():
		if flat.has(coord):
			return flat
	
	return []

func is_in_flat(coord:Vector2):
	return not get_flat(coord).is_empty()

func get_household(coord:Vector2):
	for flat in occupation_by_flat:
		if coord in flat:
			return occupation_by_flat.get(flat)
	return null

func get_adjacent_neighbors(coord_in_flat:Vector2):
	var adjacents := []
	var neighboring_coords = get_adjacent_coords_to_flat(get_flat(coord_in_flat))
	prints("HIII WORK HERE", coord_in_flat, neighboring_coords, get_flat(coord_in_flat))

func does_coord_exist(coord:Vector2):
	var floor := get_floor(coord.y)
	if not floor:
		return false
	return floor.get_unit(coord.x) != null

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
	
	GameState.camera.apply_shake(10)
	
	GameState.highest_coord = -floor_count

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
	if Data.of("cash") < 20:
		GameState.build_indicator("Need 20$.", get_global_mouse_position())
		return
	Data.change_by_int("cash", -20)
	var floor := get_floor(coord.y)
	floor.add_unit_at(coord)
	GameState.camera.apply_shake(5)

func _on_add_unit_button_place_room_at(coord: Vector2) -> void:
	request_add_unit(coord)
