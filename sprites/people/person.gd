extends Node2D

var skin:AnimatedSprite2D
var hair:AnimatedSprite2D
var body:AnimatedSprite2D
var legs:AnimatedSprite2D

func _ready() -> void:
	skin = get_node("Skin")
	hair = get_node("Hair")
	body = get_node("Body")
	legs = get_node("Legs")
	randomizeLook()

func randomizeLook():
	var x = randi_range(1,3)
	var string = "idle_skin" + str(x)
	skin.play(string)
	x = randi_range(1,3)
	string = "idle_hair" + str(x)
	hair.play(string)
	x = randi_range(1,3)
	string = "idle_body" + str(x)
	body.play(string)
	x = randi_range(1,3)
	string = "idle_legs" + str(x)
	legs.play(string)
