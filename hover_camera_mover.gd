extends TextureRect

@export var direction := Vector2.ZERO

func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)

func _process(delta: float) -> void:
	modulate.a = 1.0 - MapMath.get_transparency(get_local_mouse_position().length(), 200, 50)

func on_mouse_entered():
	GameState.camera.mouse_movement = direction

func on_mouse_exited():
	GameState.camera.mouse_movement = Vector2.ZERO
