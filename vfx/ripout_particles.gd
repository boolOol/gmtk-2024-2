extends Node2D
class_name RipParticles

@onready var cloud_fx : CPUParticles2D = find_child("Cloud")
@onready var dirt_fx : CPUParticles2D = find_child("Dirt")
@onready var sand_fx : CPUParticles2D = find_child("Sand")
@onready var timer : Timer = find_child("Timer")

func _ready() -> void:
	cloud_fx.emitting = true
	dirt_fx.emitting = true
	sand_fx.emitting = true
	timer.timeout.connect(sand_fx.set.bind("emitting", false))
	sand_fx.finished.connect(queue_free)
