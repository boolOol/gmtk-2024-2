extends Button



func _on_mouse_entered() -> void:
	Sound.sound(Sound.button_hover)
	$AnimatedSprite2D.play("hover")


func _on_pressed() -> void:
	$AnimatedSprite2D.play("click")


func _on_mouse_exited() -> void:
	if $AnimatedSprite2D.animation == "hover":
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 0
