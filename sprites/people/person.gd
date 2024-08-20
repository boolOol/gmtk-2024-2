extends Node2D

var skin:AnimatedSprite2D
var hair:AnimatedSprite2D
var body:AnimatedSprite2D
var legs:AnimatedSprite2D

var skin_idx:=0
var hair_idx:=0
var body_idx:=0
var legs_idx:=0

var direction:Direction = Direction.right

var move_range_min := 0.0
var move_range_max := 0.0

func _ready() -> void:
	skin = get_node("Skin")
	hair = get_node("Hair")
	body = get_node("Body")
	legs = get_node("Legs")
	randomizeLook()
	stop_walking()
	get_tree().create_timer(randf_range(0.5, 5.0)).timeout.connect(start_movement)

var walk_speed := 10.0

func start_movement():
	var target_x = randf_range(move_range_min, move_range_max)
	if target_x > global_position.x:
		change_direction(Direction.right)
	else:
		change_direction(Direction.left)
	var t = create_tween()
	t.tween_property(self, "global_position:x", target_x, (abs(target_x - global_position.x))/ walk_speed)
	t.finished.connect(start_idling)
	start_walking()

func start_idling():
	stop_walking()
	get_tree().create_timer(randf_range(0.5, 10.0)).timeout.connect(start_movement)
	
func randomizeLook():
	skin_idx = randi_range(1,3)
	hair_idx = randi_range(1,3)
	body_idx = randi_range(1,3)
	legs_idx = randi_range(1,3)
	#start idling
	skin.play("idle_skin" + str(skin_idx))
	hair.play("idle_hair" + str(hair_idx))
	body.play("idle_body" + str(body_idx))
	legs.play("idle_legs" + str(legs_idx))

func start_walking():
	skin.play("walk_skin" + str(skin_idx))
	hair.play("walk_hair" + str(hair_idx))
	body.play("walk_body" + str(body_idx))
	legs.play("walk_legs" + str(legs_idx))

func stop_walking():
	skin.play("idle_skin" + str(skin_idx))
	hair.play("idle_hair" + str(hair_idx))
	body.play("idle_body" + str(body_idx))
	legs.play("idle_legs" + str(legs_idx))

func change_direction(newDir:Direction):
	direction = newDir
	if (newDir == Direction.right): 
		skin.flip_h = false
		hair.flip_h = false
		body.flip_h = false
		legs.flip_h = false
	else:
		skin.flip_h = true
		hair.flip_h = true
		body.flip_h = true
		legs.flip_h = true

func make_person_shadow():
	skin.modulate = Color(Color.BLACK)
	hair.modulate = Color(Color.BLACK)
	body.modulate = Color(Color.BLACK)
	legs.modulate = Color(Color.BLACK)

func serialize() -> Dictionary:
	return {
		"body_idx" : body_idx,
		"legs_idx" : legs_idx,
		"hair_idx" : hair_idx,
		"skin_idx" : skin_idx,
		"scale" : scale,
		"move_range_min" : move_range_min,
		"move_range_max" : move_range_max,
		"global_position" : global_position
	}

func deserialize(data:Dictionary):
	skin_idx = data.get("skin_idx")
	skin.play(str("idle_skin", skin_idx))
	hair_idx = data.get("hair_idx")
	hair.play(str("idle_hair", hair_idx))
	body_idx = data.get("body_idx")
	body.play(str("idle_body", body_idx))
	legs_idx = data.get("legs_idx")
	legs.play(str("idle_legs", legs_idx))
	scale = data.get("scale")
	global_position = data.get("global_position")
	move_range_min = data.get("move_range_min")
	move_range_max = data.get("move_range_max")
	
enum Direction {right, left}
