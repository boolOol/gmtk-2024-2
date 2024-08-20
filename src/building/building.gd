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

@onready var roof_rng = RandomNumberGenerator.new()

signal query_add_floor(coord:Vector2)
#var occupation_by_flat := {}
#var occupation_by_household_id := {}
var household_id_by_coord := {}
var household_data_by_id := {} # filled with tenant data
var household_node_by_id := {} # filled with Household.tscn

## X > 0, Y > 0
@export var start_size := Vector2(6, 3)

func _ready() -> void:
	GameState.building = self
	ground_floor.player_owned = true
	ground_floor.unit_added.connect(update_walls)
	for i in start_size.x:
		ground_floor.add_unit_at(Vector2(i, 0))
	for height in start_size.y - 1:
		add_floor(0)
		for i in start_size.x - 1:
			get_floor(height + 1).add_unit_at(Vector2(i + 1, -(height + 1)))

func get_all_coords() -> Array:
	var all_coords := []
	for floor in $Floors.get_children():
		all_coords.append_array(floor.units_by_coord.keys())
	return all_coords



var wall_sprites := {
	"emptySlot" : 3,
	"groundFloorCenter" : 3,
	"groundFloorLeft" : 1,
	"groundFloorRight" : 1,
	"middleFloorCenter" : 3,
	"middleFloorLeft" : 1,
	"middleFloorRight" : 1,
	"roofDetail": 5,
	"topFloorCenter":3,
	"topFloorLeft":1,
	"topFloorRight":1,
}

func update_walls():
	var highest_point_by_x := {}
	var rightest_point_by_y := {}
	var leftest_point_by_y := {}
	var top_right_corners := []
	
	var empty_on_right := []
	var empty_on_top := []
	
	var placed_roofs := []
	var placed_depths := []
	
	var overhanging_coords := []
	
	for wall in $FrontWall.get_children():
		wall.queue_free()
	
	var all_coords := get_all_coords()
	#print(all_coords)
	for coord in all_coords:
		if highest_point_by_x.has(coord.x):
			if highest_point_by_x[coord.x] > coord.y:
				highest_point_by_x[coord.x] = coord.y
		else:
			highest_point_by_x[coord.x] = coord.y
		
		if rightest_point_by_y.has(coord.y):
			if rightest_point_by_y[coord.y] < coord.x:
				rightest_point_by_y[coord.y] = coord.x
		else:
			rightest_point_by_y[coord.y] = coord.x
		if leftest_point_by_y.has(coord.y):
			if leftest_point_by_y[coord.y] > coord.x:
				leftest_point_by_y[coord.y] = coord.x
		else:
			leftest_point_by_y[coord.y] = coord.x
		
		if not all_coords.has(coord + Vector2.DOWN):
			overhanging_coords.append(coord)
		if not all_coords.has(coord + Vector2.RIGHT):
			empty_on_right.append(coord)
		if not all_coords.has(coord + Vector2.UP):
			empty_on_top.append(coord)
		
	for coord in all_coords:
		var wall = preload("res://src/floor/wall.tscn").instantiate()
		$FrontWall.add_child(wall)
		wall.global_position.x = coord.x * CONST.FLOOR_UNIT_WIDTH
		wall.global_position.y = coord.y * CONST.FLOOR_UNIT_HEIGHT
		#wall.set_from_coord(coord, roof_rng)
		
		var path := "res://src/building/sprites/spr_building-"
		
		var texName := ""
		if coord.y == 0:
			texName += "ground"
		elif coord.y == highest_point_by_x.get(coord.x):
			texName += "top"
		else:
			texName += "middle"
		
		texName += "Floor"
		
		if coord.x == leftest_point_by_y.get(coord.y):
			texName += "Left"
		elif coord.x == rightest_point_by_y.get(coord.y):
			texName += "Right"
		else:
			texName += "Center"
		
		if wall_sprites.keys().has(texName):
			texName += str("0", roof_rng.randi() % wall_sprites.get(texName) + 1)
		
		path += texName
		path += ".png"
		wall.texture = load(path)
	
	#prints("highest point by x", highest_point_by_x)
	#prints("rightest point by y", rightest_point_by_y)
	
	for coord in overhanging_coords:
		var path := ""
		var support_coord:Vector2 = coord + Vector2.DOWN
		if all_coords.has(coord + Vector2(1, 1)): # down right
			path = "res://src/building/sprites/spr_building-supportLeft-2.png"
			
		elif all_coords.has(coord + Vector2(-1, 1)): # down left
			path = "res://src/building/sprites/spr_building-supportRight-2.png"
		if not path.is_empty():
			var wall = preload("res://src/floor/wall.tscn").instantiate()
			$FrontWall.add_child(wall)
			wall.global_position.x = support_coord.x * CONST.FLOOR_UNIT_WIDTH
			wall.global_position.y = support_coord.y * CONST.FLOOR_UNIT_HEIGHT
			wall.texture = load(path)
		
	
	for coord in empty_on_top:
		var roof_coord = coord + Vector2.UP
		#var coord = Vector2(x, highest_point_by_x.get(x) - 1)
		var wall = preload("res://src/floor/wall.tscn").instantiate()
		$FrontWall.add_child(wall)
		wall.global_position.x = roof_coord.x * CONST.FLOOR_UNIT_WIDTH
		wall.global_position.y = roof_coord.y * CONST.FLOOR_UNIT_HEIGHT
		wall.texture = load(str("res://src/building/sprites/spr_building-roofDetail0", roof_rng.randi_range(1, 5), ".png"))
		
		placed_roofs.append(roof_coord)
		
	var highest := Vector2.ZERO
	
	for y in rightest_point_by_y:
		if y < highest.y:
			highest = Vector2(rightest_point_by_y.get(y) + 1, y - 1)
	
	for coord in empty_on_right:
		var depth_coord = coord + Vector2.RIGHT
		#var coord = Vector2(rightest_point_by_y.get(y) + 1, y)
		var wall = preload("res://src/floor/wall.tscn").instantiate()
		$FrontWall.add_child(wall)
		wall.global_position.x = depth_coord.x * CONST.FLOOR_UNIT_WIDTH
		wall.global_position.y = depth_coord.y * CONST.FLOOR_UNIT_HEIGHT
		
		var word : String
		if coord.y == 0:
			word = "ground"
		elif coord.y == highest.y:
			word = "top"
		else:
			word = "middle"
		
		var depth_path := str("res://src/building/sprites/spr_building-", word, "FloorDepth.png")
		wall.texture = load(depth_path)
		wall.z_index = -1
		
		placed_depths.append(depth_coord)
	
	for roof_coord in placed_roofs:
		var depth_coord : Vector2 = roof_coord + Vector2(1, 1)
		if placed_depths.has(depth_coord):
			var wall = preload("res://src/floor/wall.tscn").instantiate()
			$FrontWall.add_child(wall)
			wall.global_position.x = depth_coord.x * CONST.FLOOR_UNIT_WIDTH
			wall.global_position.y = (depth_coord.y - 1) * CONST.FLOOR_UNIT_HEIGHT
			wall.texture = load("res://src/building/sprites/spr_building-roofDepth.png")
			wall.z_index = -1
	
	var wall = preload("res://src/floor/wall.tscn").instantiate()
	$FrontWall.add_child(wall)
	wall.global_position.x = highest.x * CONST.FLOOR_UNIT_WIDTH
	wall.global_position.y = highest.y * CONST.FLOOR_UNIT_HEIGHT
	wall.texture = load("res://src/building/sprites/spr_building-roofDepth.png")
	wall.z_index = -1

func _process(delta: float) -> void:
	var target_pos = get_local_mouse_position() - (add_unit_button.size * 0.25)
	add_unit_button.position = lerp(add_unit_button.position, target_pos, 0.2)
	
	var button_coord = add_unit_button.get_current_coord()
	add_unit_button.visible = can_coord_be_added(button_coord) and (GameState.is_state(GameState.State.Managing) or GameState.is_state(GameState.State.Building))
	$Ghost.visible = add_unit_button.visible
	if add_unit_button.visible:
		var mouse_coord = MapMath.pos_to_coord(get_global_mouse_position() + Vector2(0, 16))
		$Ghost.global_position = (button_coord * CONST.FLOOR_UNIT_HEIGHT) + Vector2(CONST.FLOOR_UNIT_WIDTH, CONST.FLOOR_UNIT_HEIGHT)
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
			
			#if not handled_rooms.has(get_room(coord)):
			flat_sequence.append(coord)
			#handled_rooms.append(get_room(coord))
		if not flat_sequence.is_empty():
			flats.append(get_sorted_coords(flat_sequence.duplicate()))
	#prints("returning flats", flats)
	return flats

func occupy_flat(flat_amalgam:Array, tenant_data:Dictionary):
	var household_id = tenant_data.get("id")
	for coord in flat_amalgam:
		household_id_by_coord[coord] = household_id
	#occupation_by_flat[flat_amalgam] = household_id
	#occupation_by_household_id[household_id] = flat_amalgam
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

func get_flat_of_household(id:int) -> Array:
	var flat_amalgam:=[]
	for coord in household_id_by_coord.keys():
		if household_id_by_coord.get(coord) == id:
			flat_amalgam = get_flat(coord)
			break
	return flat_amalgam

func get_building_width():
	return get_right_most_x() - get_left_most_x()

func get_left_most_x():
	var all_cords := get_all_coords()
	var n = all_cords.front().x
	for coord in all_cords:
		if coord.x < n:
			n = coord.x
	return n
func get_right_most_x():
	var all_cords := get_all_coords()
	var n = all_cords.front().x
	for coord in all_cords:
		if coord.x > n:
			n = coord.x
	return n
		

func update_flat_extents(household_id:int):
	var flat_amalgam: = get_flat_of_household(household_id)
	
	
	
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
	#print("coords adjacent to ", coord, ": ", adjacent_coords)
	var ids := []
	for acoord in adjacent_coords:
		var id = get_household_id_of(acoord)
		if not ids.has(id):
			ids.append(id)
	
	var self_id = get_household_id_of(coord)
	while ids.has(self_id):
		ids.erase(self_id)
	ids.erase(-1)
	ids.erase(0)
	return ids

func get_adjacent_household_archetypes(coord:Vector2) -> Array:
	var archetypes := []
	
	var adjacent_households = get_adjacent_household_ids(coord)
	prints("adjacent hh", adjacent_households)
	for ahh in adjacent_households:
		if ahh == -1 or ahh == 0:
			continue
		var archetype = household_data_by_id.get(ahh).get("archetype")
		archetypes.append(archetype)
	
	return archetypes

func get_household_archetype(id:int):
	prints("archetype of ", id , " is ", household_data_by_id.get(id).get("archetype"), CONST.HOUSEHOLD_NAMES.get(household_data_by_id.get(id).get("archetype")))
	return household_data_by_id.get(id).get("archetype")

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
	return household_node_by_id.get(id, null)

func get_physical_flat_extents(flat:Array) -> Vector2:
	var min_x = 99999
	var max_x = -99999
	
	for coord : Vector2 in flat:
		if coord.x < min_x:
			min_x = coord.x
		if coord.x > max_x:
			max_x = coord.x
	return Vector2(min_x, max_x)

func is_coord_in_flat_index_occupied(index:Vector2) -> bool:
	pass
	return false



func get_empty_flats() -> Array:
	var flats = get_flats()
	var result := []
	var occupations_with_indices := []
	for flat in flats:
		var occupied := false
		for coord in flat:
			if get_household(coord):
				occupied = true
				break
		if occupied:
			continue
		#if occupation_by_flat.has(flat):
			#continue
		result.append(flat)
	
	prints("returning empty flats", result)
	return result

func get_adjacent_coords_to_flat(flat:Array):
	var coords := []
	for cell in flat:
		for neighbor in CONST.NEIGHBOR_OFFSETS:
			var offset = cell + neighbor
			if (not coords.has(offset)) and does_coord_exist(offset):
				coords.append(offset)
	return coords

func get_household_id_of(coord:Vector2) -> int:
	return household_id_by_coord.get(coord, -1)
	#var a = occupation_by_flat
	#
	#prints("looking for occupation in ", coord, ":", occupation_by_flat)
	#for flat : Array in occupation_by_flat.keys():
		#prints("checking if", flat, " has ", coord)
		#if flat.has(coord):
			#if not occupation_by_flat.get(flat):
				#continue
			#return occupation_by_flat.get(flat)
	#return -1

func get_flat(coord:Vector2) -> Array:
	for flat in get_flats():
		if flat.has(coord):
			return flat
	
	return []

func get_flat_index(coord:Vector2) -> Vector2:
	var flats = get_flats()
	var flats_on_floor := 1
	for flat in flats:
		if flat.has(coord):
			break
		if flat.front().y == coord.y:
			flats_on_floor += 1
			continue
	
	return Vector2(flats_on_floor, abs(coord.y))

func evict(id: int):
	household_node_by_id.get(id).queue_free()
	household_node_by_id.erase(id)
	household_data_by_id.erase(id)
	for coord in household_id_by_coord.keys():
		if household_id_by_coord.get(coord) == id:
			household_id_by_coord.erase(coord)
	#var flat = occupation_by_household_id.get(id)
	#occupation_by_flat.erase(flat)
	#occupation_by_household_id.erase(id)
	
	Sound.sound("eviction")

func is_in_flat(coord:Vector2):
	return not get_flat(coord).is_empty()

func get_household(coord:Vector2):
	var id = household_id_by_coord.get(coord)
	if id:
		return household_node_by_id.get(id)
	else:
		return null
	#for flat in occupation_by_flat:
		#if coord in flat:
			#return occupation_by_flat.get(flat)
	#return null

func get_adjacent_neighbors(coord_in_flat:Vector2):
	var adjacents := []
	var neighboring_coords = get_adjacent_coords_to_flat(get_flat(coord_in_flat))
	#prints("HIII WORK HERE", coord_in_flat, neighboring_coords, get_flat(coord_in_flat))

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
	GameState.set_expanded_this_phase(true)
	var floor_count = $Floors.get_child_count()
	var floor = preload("res://src/floor/floor.tscn").instantiate()
	floor.player_owned = true
	$Floors.add_child(floor)
	floor.unit_added.connect(update_walls)
	floor.position = MapMath.coord_to_pos(Vector2(horizontal_index, -floor_count))# - global_position
	floor.add_unit_at(Vector2(horizontal_index, -floor_count))
	
	GameState.camera.apply_shake(10)
	
	GameState.highest_coord = -floor_count
	Sound.sound(Sound.room_rip)

func get_height_px() -> float:
	return $Floors.get_child_count() * CONST.FLOOR_UNIT_HEIGHT + global_position.y

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

func get_highest(x:int) -> int:
	var max = 0
	
	for coord in get_all_coords():
		if coord.x == x:
			if coord.y < max:
				max = coord.y
	
	return max

func can_coord_be_added(coord: Vector2):
	if coord.y <= get_highest(coord.x) - 2:
		return false
	if get_building_width() >= (CONST.MAX_WIDTH - 1) and (coord.x >= get_right_most_x() or coord.x <= get_left_most_x()):
		return false
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
	if Data.of("cash") < CONST.ROOM_UNIT_PRICE:
		GameState.build_indicator(str("Need ", CONST.ROOM_UNIT_PRICE, "$."), get_global_mouse_position())
		return
	Data.change_by_int("cash", -CONST.ROOM_UNIT_PRICE)
	var floor := get_floor(coord.y)
	floor.add_unit_at(coord)
	GameState.camera.apply_shake(5)
	GameState.build_indicator(
		str("-", CONST.ROOM_UNIT_PRICE, "$"),
		MapMath.coord_to_pos(coord) + Vector2(0.5 * CONST.FLOOR_UNIT_WIDTH, 0)
	)
	GameState.set_expanded_this_phase(true)

func _on_add_unit_button_place_room_at(coord: Vector2) -> void:
	request_add_unit(coord)
