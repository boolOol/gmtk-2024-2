extends Button

@export var event_screen:Control


func _ready() -> void:
	if event_screen:
		pressed.connect(event_screen.set.bind("visible", false))
