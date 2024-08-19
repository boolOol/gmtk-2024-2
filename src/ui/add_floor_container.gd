extends CenterContainer

signal confirm_add_floor(coord: Vector2)
var current_coord : Vector2

var popup_tween:Tween

func _ready() -> void:
	visible = false
	scale = Vector2.ZERO

func show_menu(coord:Vector2):
	current_coord = coord
	visible = true
	
	var more_costs : int
	if abs(coord.y) >= CONST.PRICE_PER_HEIGHT.size():
		more_costs = CONST.PRICE_PER_HEIGHT.get(CONST.PRICE_PER_HEIGHT.size() - 1)
	else:
		more_costs = CONST.PRICE_PER_HEIGHT.get(int(abs(coord.y)))
	find_child("RichTextLabel").text = str("[center]Do you want to add floor ", abs(coord.y) + 1, "? This will increase maintenance fees by ", more_costs, ".")
	find_child("ConfirmButton").grab_focus()
	if popup_tween:
		popup_tween.kill()
	popup_tween = create_tween()
	popup_tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT_IN)

func hide_menu():
	if popup_tween:
		popup_tween.kill()
	popup_tween = create_tween()
	popup_tween.tween_property(self, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT_IN)
	popup_tween.tween_property(self, "visible", false, 0.0)

func _on_cancel_button_pressed() -> void:
	hide_menu()


func _on_confirm_button_pressed() -> void:
	emit_signal("confirm_add_floor", current_coord)
	hide_menu()
	GameState.building.update_walls()
	
