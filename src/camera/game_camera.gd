extends Camera2D
class_name  GameCamera

@onready var target_zoom := Vector2.ONE * 1.75

@export var shake_fade := 5.0

var rng := RandomNumberGenerator.new()

var shake_strength := 0.0
var mouse_movement := Vector2.ZERO

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
		target_zoom.x = clamp(target_zoom.x + (zoom.x / 1.0) * CONST.ZOOM_STEP, CONST.ZOOM_MIN, CONST.ZOOM_MAX)
		target_zoom.y = clamp(target_zoom.y + (zoom.x / 1.0) * CONST.ZOOM_STEP, CONST.ZOOM_MIN, CONST.ZOOM_MAX)
	if event.is_action("zoom_out"):
		target_zoom.x = clamp(target_zoom.x - (zoom.x / 1.0) * CONST.ZOOM_STEP, CONST.ZOOM_MIN, CONST.ZOOM_MAX)
		target_zoom.y = clamp(target_zoom.y - (zoom.x / 1.0) * CONST.ZOOM_STEP, CONST.ZOOM_MIN, CONST.ZOOM_MAX)
	

func _physics_process(delta: float) -> void:
	zoom = lerp(zoom, target_zoom, 0.2)

func _process(delta):
	#var mouse_pos := get_local_mouse_position()
	#var rect := get_viewport_rect().size
	#rect *= 0.5
	#rect  *= zoom.x
	#var dist_check : float = (2 * zoom.x)
	#printt(dist_check, zoom.x, (rect.x - abs(mouse_pos.x))* zoom.x)
	#if (rect.x - abs(mouse_pos.x))* zoom.x < dist_check:
		#position.x += (CONST.CAMERA_MOVE_STEP * delta / zoom.x) * sign(mouse_pos.x)
	#if (rect.y - abs(mouse_pos.y))* zoom.x < dist_check:
		#position.y += (CONST.CAMERA_MOVE_STEP * delta / zoom.y) * sign(mouse_pos.y)
	
	if mouse_movement.length() > 0:
		position += (CONST.CAMERA_MOVE_STEP * mouse_movement) * delta / zoom.x
	else:
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
	
