extends Node


@onready var bgm_player:= AudioStreamPlayer.new()

var eviction := "res://sounds/sfx/sfx_tenantKickedOut.ogg"
var income = "res://sounds/sfx/sfx_incomeNotice.ogg"
var room_rip = "res://sounds/sfx/sfx_roomRippedOut.ogg"
var place = "res://sounds/sfx/sfx_roomConnectedToSelf.ogg"
var explosion = "res://src/building/explosion.png"

var music := [
	"res://sounds/music/DrumApocalypse.ogg"
]

func _ready() -> void:
	add_child(bgm_player)
	bgm_player.finished.connect(play_random_bgm)
	play_random_bgm()
	bgm_player.bus = "Music"

func play_random_bgm():
	bgm_player.stream = load(music.pick_random())
	bgm_player.play()

func sound(sfx:String):
	if not get(sfx):
		push_warning(str("SFX ", sfx, " not defined"))
		return
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "SFX"
	player.stream = load(get(sfx))
	player.pitch_scale = randf_range(0.8, 1.1)
	player.play()
	player.finished.connect(player.queue_free)
