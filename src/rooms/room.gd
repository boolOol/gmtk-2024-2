extends Node2D
class_name Room

var player_owned : bool
var selected := false
var drag_start_position:Vector2
var drag_offset:Vector2

var floor := 0

const sprite_root := "res://src/rooms/room_sprites/spr_room-"

@export var room_type: CONST.RoomType

func _ready() -> void:
	GameState.state_changed.connect(on_state_changed)
	$TextureButton.visible = false

func on_state_changed(new_state:GameState.State):
	$TextureButton.visible = (not player_owned) and new_state == GameState.State.Building


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
	
	var size = CONST.ROOM_SIZES.get(room_type)
	if size == 1:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorSmallWhite.png")
	elif size == 2:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorMediumWhite.png")
	#var collider : CollisionShape2D = find_child("CollisionShape2D")
	#var shape = RectangleShape2D.new()
	#shape.size = $Sprite2D.texture.get_size()
	#collider.position = $Sprite2D.texture.get_size() * 0.5
	#collider.shape = shape

func set_dropability(do:bool):
	var size = CONST.ROOM_SIZES.get(room_type)
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var event_position : Vector2 = event.global_position
			var top_left := position
			var bottom_right : Vector2 = position + $Sprite2D.texture.get_size()
			if event_position.x > top_left.x and event_position.x < bottom_right.x and event_position.y > top_left.y and event_position.y < bottom_right.y:
				print(name)
		#if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			#selected = false
			#global_position = drag_start_position
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#
			#var event_position : Vector2 = event.global_position
			##print(event_position)
			#var top_left := global_position
			#var bottom_right : Vector2 = global_position + $Sprite2D.texture.get_size()
			#
			#printt(event_position, top_left, bottom_right)
			#if event_position.x > top_left.x and event_position.x < bottom_right.x and event_position.y > top_left.y and event_position.y < bottom_right.y:
				#print(name)
		##if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			##selected = false
			##global_position = drag_start_position
#


func _on_texture_button_button_down() -> void:
	GameState.dragged_room = self
	selected = true
	drag_start_position = global_position
	drag_offset = get_local_mouse_position()
	
	var size = CONST.ROOM_SIZES.get(room_type)
	if size == 1:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorSmallRed.png")
	elif size == 2:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorMediumRed.png")
	
func set_player_owned(value:bool):
	player_owned = value
	$TextureButton.visible = (not player_owned) and GameState.is_state(GameState.State.Building)

func _on_texture_button_button_up() -> void:
	selected = false
	if GameState.drag_target:
		if GameState.can_room_fit_drag_target(self):
			GameState.transfer_to_drag_target()
		else:
			global_position = drag_start_position
	else:
		global_position = drag_start_position
	GameState.dragged_room = null
	var size = CONST.ROOM_SIZES.get(room_type)
	if size == 1:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorSmallWhite.png")
	elif size == 2:
		$TextureButton.texture_normal = load("res://src/rooms/spr_UI-selectorMediumWhite.png")
	
