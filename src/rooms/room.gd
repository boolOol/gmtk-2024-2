extends Node2D
class_name Room

var player_owned : bool
var selected := false
var drag_start_position:Vector2
var drag_offset:Vector2

var floor := 0
var coord := Vector2.ZERO
var room_size := 0

const sprite_root := "res://src/rooms/room_sprites/spr_room-"

@export var room_type: CONST.RoomType

signal request_room_info(coord:Vector2)

func _ready() -> void:
	GameState.state_changed.connect(on_state_changed)
	$TextureButton.visible = false
	$InfoButton.visible = player_owned

func on_state_changed(new_state:GameState.State):
	$TextureButton.visible = (not player_owned) and new_state == GameState.State.Building
	$InfoButton.visible = player_owned
	

func set_room_type(value):
	room_type = value
	match value:
		CONST.RoomType.Kitchen:
			$Sprite2D.texture = load(str(sprite_root, "kitchenMedium01.png"))
		CONST.RoomType.Bathroom:
			$Sprite2D.texture = load(str(sprite_root, "bathSmall01.png"))
		CONST.RoomType.Livingroom:
			$Sprite2D.texture = load(str(sprite_root, "livingroomMedium01.png"))
		CONST.RoomType.Bedroom:
			$Sprite2D.texture = load(str(sprite_root, "bedroomMedium01.png"))
		CONST.RoomType.Hallway:
			$Sprite2D.texture = load(str(sprite_root, "hallwaySmall01.png"))
		CONST.RoomType.Storeroom:
			$Sprite2D.texture = load(str(sprite_root, "storageSmall01.png"))
		CONST.RoomType.Office:
			$Sprite2D.texture = load("res://src/floor/office.png")
		CONST.RoomType.Fitnessroom:
			$Sprite2D.texture = load("res://src/floor/fitness.png")
		CONST.RoomType.Garage:
			$Sprite2D.texture = load("res://src/floor/garage.png")
		CONST.RoomType.ChildRoom:
			$Sprite2D.texture = load("res://src/floor/childroom.png")
		CONST.RoomType.Library:
			$Sprite2D.texture = load("res://src/floor/library.png")
		CONST.RoomType.GamingRoom:
			$Sprite2D.texture = load("res://src/floor/gaming.png")
		CONST.RoomType.PleasureRoom:
			$Sprite2D.texture = load("res://src/floor/pleasure.png")
	
	room_size = get_room_size()
	if room_size == 1:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorSmallWhite.png")
		$InfoButton.texture_hover = load("res://src/rooms/spr_UI-InfoSmallWhite.png")
		$InfoButton.texture_pressed = load("res://src/rooms/spr_UI-InfoSmallGreen.png")
	elif room_size == 2:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorMediumWhite.png")
		$InfoButton.texture_hover = load("res://src/rooms/spr_UI-InfoMediumWhite.png")
		$InfoButton.texture_pressed = load("res://src/rooms/spr_UI-InfoMediumGreen.png")
func set_dropability(do:bool):
	var size = get_room_size()
	if do:
		if size == 1:
			$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorSmallGreen.png")
		elif size == 2:
			$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorMediumGreen.png")
	else:
		if size == 1:
			$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorSmallRed.png")
		elif size == 2:
			$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorMediumRed.png")
	

func _physics_process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position() - drag_offset, 20*delta)

var mouse_in = false

func _process(delta: float) -> void:
	var mouse_pos := get_local_mouse_position() 
	if (mouse_pos.x > 0 and mouse_pos.x < room_size * CONST.FLOOR_UNIT_WIDTH
	and mouse_pos.y > 0 and mouse_pos.y < room_size * CONST.FLOOR_UNIT_HEIGHT):
		mouse_in = true
	else:
		mouse_in = false
		

func _on_texture_button_button_down() -> void:
	GameState.dragged_room = self
	selected = true
	drag_start_position = global_position
	drag_offset = get_local_mouse_position()
	
	if room_size == 1:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorSmallRed.png")
	elif room_size == 2:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorMediumRed.png")
	
func set_player_owned(value:bool):
	player_owned = value
	$TextureButton.visible = (not player_owned) and GameState.is_state(GameState.State.Building)
	$InfoButton.visible = player_owned

func get_room_size() -> int:
	return CONST.ROOM_SIZES.get(room_type)

func get_center() -> Vector2:
	return global_position + (Vector2(room_size * CONST.FLOOR_UNIT_WIDTH, CONST.FLOOR_UNIT_HEIGHT) * 0.5)

func _on_texture_button_button_up() -> void:
	selected = false
	if GameState.drag_target:
		if GameState.can_drag_target_fit_room(self):
			GameState.transfer_to_drag_target()
		else:
			global_position = drag_start_position
	else:
		global_position = drag_start_position
	GameState.dragged_room = null
	
	if room_size == 1:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorSmallWhite.png")
	elif room_size == 2:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorMediumWhite.png")
	


func _on_info_button_pressed() -> void:
	if player_owned:
		emit_signal("request_room_info", coord)
