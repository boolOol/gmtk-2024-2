extends Sprite2D


var sprites := {
	"emptySlot" : 3,
	"groundFloorCenter" : 3,
	"groundFloorLeft" : 1,
	"groundFloorRight" : 1,
	"middleFloorCenter" : 3,
	"middleFloorLeft" : 1,
	"middleFloorRight" : 1,
	"roofDetail": 5,
	"topFloorCenter":3,
	"topFloorLeft":1,
	"topFloorRight":1,
}

# custom: groundFloorDepth, middleFloorDepth, roofDepth

func _ready() -> void:
	Data.property_changed.connect(on_property_changed)
	visible = Data.of("global.permanent_reveal")


func on_property_changed(property_name:String, old_value, new_value):
	match property_name:
		"global.permanent_reveal":
			visible = new_value

func set_from_coord(coord:Vector2, rng:RandomNumberGenerator):
	var highest : bool = coord.y == GameState.highest_coord
	var left : bool = coord.x == GameState.left_most_coord
	var right : bool = coord.x == GameState.right_most_coord
	var ground : bool = coord.x == 0
	var roof = coord.y < GameState.highest_coord
	var depth = coord.x > GameState.right_most_coord
	
	var root := "res://src/building/sprites/spr_building-"
	var tex_str := ""
	if ground:
		tex_str += "ground"
	elif highest:
		tex_str += "top"
	else:
		tex_str += "middle"
	tex_str += "Floor"
	
	if left:
		tex_str += "Left"
	elif right:
		tex_str += "Right"
	else:
		tex_str += "Center"
	
	
	if sprites.keys().has(tex_str):
		tex_str += str("0", int(coord.x) % sprites.get(tex_str) + 1)
	
	if roof:
		tex_str = str("roofDetail0", rng.randi_range(1, 5))
	
	if depth:
		tex_str = ""
		if ground:
			tex_str += "ground"
		elif highest:
			tex_str += "top"
		else:
			tex_str += "middle" 
		tex_str += "FloorDepth"
	
	if roof and depth:
		tex_str = "roofDepth"
	
	var full_str = str(root, tex_str, ".png")
	texture = load(full_str)


func _process(delta: float) -> void:
	modulate.a = MapMath.get_transparency(get_local_mouse_position().length(), 20, 40)
	
