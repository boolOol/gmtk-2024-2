extends Node2D

var skin:AnimatedSprite2D
var hair:AnimatedSprite2D
var body:AnimatedSprite2D
var legs:AnimatedSprite2D

var skin_idx:=0
var hair_idx:=0
var body_idx:=0
var legs_idx:=0

func _ready() -> void:
	skin = get_node("Skin")
	hair = get_node("Hair")
	body = get_node("Body")
	legs = get_node("Legs")
	randomizeLook()

func randomizeLook():
	skin_idx = randi_range(1,3)
	var string = "idle_skin" + str(skin_idx)
	skin.play(string)
	hair_idx = randi_range(1,3)
	string = "idle_hair" + str(hair_idx)
	hair.play(string)
	body_idx = randi_range(1,3)
	string = "idle_body" + str(body_idx)
	body.play(string)
	legs_idx = randi_range(1,3)
	string = "idle_legs" + str(legs_idx)
	legs.play(string)

func serialize() -> Dictionary:
	return {
		"body_idx" : body_idx,
		"legs_idx" : legs_idx,
		"hair_idx" : hair_idx,
		"skin_idx" : skin_idx,
		"scale" : scale
	}

func deserialize(data:Dictionary):
	skin_idx = data.get("_idx")
	skin.play(str("idle_skin"))
	hair_idx = data.get("_idx")
	hair.play(str("idle_hair"))
	body_idx = data.get("_idx")
	body.play(str("body"))
	legs_idx = data.get("_idx")
	legs.play(str("idle_legs"))
	scale = data.get("scale")
