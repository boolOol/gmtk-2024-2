extends Node


@onready var bgm_player:= AudioStreamPlayer.new()

var eviction := "res://sounds/sfx/sfx_tenantKickedOut.ogg"
var income = "res://sounds/sfx/sfx_incomeNotice.ogg"
var room_rip = "res://sounds/sfx/sfx_roomRippedOut.ogg"

func _ready() -> void:
	add_child(bgm_player)
	bgm_player.stream = load("res://sounds/music/KT_Atmos_RainThunder.mp3")
	bgm_player.play()
	bgm_player.bus = "Music"

func sound(sfx:String):
	if not get(sfx):
		push_warning(str("SFX ", sfx, " not defined"))
		return
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "SFX"
	player.stream = load(get(sfx))
	player.play()
	player.finished.connect(player.queue_free)
