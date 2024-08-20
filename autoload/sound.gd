extends Node


@onready var bgm_player:= AudioStreamPlayer.new()

var eviction := "res://sounds/sfx/sfx_tenantKickedOut.ogg"
var income = "res://sounds/sfx/sfx_incomeNotice.ogg"
var room_rip = "res://sounds/sfx/sfx_roomRippedOut.ogg"
var place = "res://sounds/sfx/sfx_roomConnectedToSelf.ogg"
var event = "res://sounds/sfx/sfx_capitalistNoises.ogg"
var button_build = "res://sounds/sfx/sfx_ButtonBuildPhase.ogg"
var button_profit = "res://sounds/sfx/sfx_ButtonProfitPhase.ogg"
var button_manage = "res://sounds/sfx/sfx_ButtonManagePhase.ogg"
var button_hover = "res://sounds/sfx/sfx_ButtonHover.ogg"
var explosion = "res://sounds/sfx/sfx_explosion.ogg"

var music := [
	"res://sounds/music/DrumApocalypse.ogg",
	"res://sounds/music/MetrosexualCannibals.ogg",
	"res://sounds/music/gentrify my heart.ogg",
]

func _ready() -> void:
	randomize()
	add_child(bgm_player)
	bgm_player.finished.connect(play_random_bgm)
	play_random_bgm()
	bgm_player.bus = "Music"
	

func play_random_bgm():
	bgm_player.stream = load(music.pick_random())
	bgm_player.play()

func sound(sfx:String):
	var path : String
	if not get(sfx):
		path = sfx
	else:
		path = get(sfx)
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "SFX"
	player.stream = load(path)
	player.pitch_scale = randf_range(0.8, 1.1)
	player.play()
	player.finished.connect(player.queue_free)
