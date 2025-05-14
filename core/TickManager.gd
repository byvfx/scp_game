extends Node

class_name TickManager

signal tick(time)

var tick_interval := 0.25  # seconds per tick
var tick_timer := 0.0
var current_time := 0

func _process(delta):
	tick_timer += delta
	if tick_timer >= tick_interval:
		tick_timer -= tick_interval
		current_time += 1
		emit_signal("tick", current_time)
