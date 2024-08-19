extends Control

var vis_tween:Tween

func _ready() -> void:
	visibility_changed.connect(on_visibility_changed)

func on_visibility_changed():
	if visible:
		modulate.a = 0.0
	if vis_tween:
		vis_tween.kill()
	vis_tween = create_tween()
	vis_tween.tween_property(self, "modulate:a", 1.0, 0.6)
