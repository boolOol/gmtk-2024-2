extends Camera2D
class_name  GameCamera

@onready var target_zoom := Vector2.ONE * 1.75

@export var shake_fade := 5.0

var rng := RandomNumberGenerator.new()

var shake_strength := 0.0

func _ready() -> void:
	GameState.camera = self

func apply_shake(intensity := 30.0):
	shake_strength = intensity

func random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("zoom_in"):
		target_zoom.x = clamp(target_zoom.x + CONST.ZOOM_STEP, CONST.ZOOM_MIN, CONST.ZOOM_MAX)
		target_zoom.y = clamp(target_zoom.y + CONST.ZOOM_STEP, CONST.ZOOM_MIN, CONST.ZOOM_MAX)
	if event.is_action("zoom_out"):
		target_zoom.x = clamp(target_zoom.x - CONST.ZOOM_STEP, CONST.ZOOM_MIN, CONST.ZOOM_MAX)
		target_zoom.y = clamp(target_zoom.y - CONST.ZOOM_STEP, CONST.ZOOM_MIN, CONST.ZOOM_MAX)
	

func _physics_process(delta: float) -> void:
	zoom = lerp(zoom, target_zoom, 0.2)

func _process(delta):
	if Input.is_action_pressed("ui_up"):
		position.y -= CONST.CAMERA_MOVE_STEP * delta / zoom.x
	if Input.is_action_pressed("ui_down"):
		position.y += CONST.CAMERA_MOVE_STEP * delta / zoom.x
	if Input.is_action_pressed("ui_left"):
		position.x -= CONST.CAMERA_MOVE_STEP * delta / zoom.x
	if Input.is_action_pressed("ui_right"):
		position.x += CONST.CAMERA_MOVE_STEP * delta / zoom.x
	position.y = clamp(position.y, -GameState.building.get_height_px() - 400, 10 / CONST.ZOOM_MIN)
	position.x = clamp(position.x, -500, 500)
	
	var total_offset = Vector2.ZERO
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		total_offset = random_offset()
	
	total_offset += get_local_mouse_position() * 0.1
	offset = total_offset
	
