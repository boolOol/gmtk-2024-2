extends RichTextLabel


func _ready() -> void:
	visible = false

func start(text_to_display:String, global_pos:Vector2, delay:=0.0, text_color:=Color.LAWN_GREEN, font_size:=32):
	await get_tree().create_timer(delay).timeout
	visible = true
	add_theme_font_size_override("normal_font_size", font_size)
	text = str("[center][color=#", text_color.to_html(), "]", text_to_display, "[/color][/center]")
	
	global_position = global_pos - (size * 0.5)
	var t = create_tween()
	t.set_parallel()
	t.tween_property(self, "global_position", global_position - Vector2(0, 50), 4.0).set_ease(Tween.EASE_IN)
	t.tween_property(self, "modulate:a", 0, 2.0).set_ease(Tween.EASE_OUT).set_delay(2)
	t.finished.connect(queue_free)

#func _process(delta: float) -> void:
	#if GameState.camera:
		#scale = GameState.camera.zoom
