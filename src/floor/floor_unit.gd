extends Area2D
class_name FloorUnit

var h_index := 0
var player_owned : bool
var floor := 0

var mouse_in_last_frame := false

const sprite_paths := [
	"res://src/building/sprites/spr_building-emptySlot01.png",
	"res://src/building/sprites/spr_building-emptySlot02.png",
	"res://src/building/sprites/spr_building-emptySlot03.png",
]

func _process(delta: float) -> void:
	if not player_owned:
		return
	var mouse_pos := get_local_mouse_position()
	if (mouse_pos.x > 0 and mouse_pos.x < CONST.FLOOR_UNIT_WIDTH
		and mouse_pos.y > 0 and mouse_pos.y < CONST.FLOOR_UNIT_HEIGHT):
			if not mouse_in_last_frame:
				on_mouse_entered()
			mouse_in_last_frame = true
	else:
		if  mouse_in_last_frame:
			on_mouse_exited()
		mouse_in_last_frame = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and GameState.dragged_room:
		$Construction.modulate.a = 1.0 - MapMath.get_transparency(get_local_mouse_position().length(), 75, 15)
	else:
		$Construction.modulate.a = lerp($Construction.modulate.a, 0.0, 0.05)


func _ready() -> void:
	$Sprite.texture = load(sprite_paths.pick_random())
	GameState.state_changed.connect(on_state_changed)
	$Construction.visible = false


func on_state_changed(new_state:GameState.State):
	$Construction.visible = player_owned and new_state == GameState.State.Building

func select():
	for unit in get_tree().get_nodes_in_group("floor_unit"):
		unit.deselect()
	$Selector.visible = true

func deselect():
	$Selector.visible = false


func on_mouse_entered() -> void:
	if Input.is_action_pressed("click"):
		GameState.set_drag_target(self)


func on_mouse_exited() -> void:
	if GameState.drag_target == self:
		GameState.set_drag_target(null)
