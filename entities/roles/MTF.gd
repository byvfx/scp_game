# MTF.gd
extends "res://entities/BaseAgent.gd"

func _ready():
	agent_name = "MTF Bravo-7"
	agent_role = Role.MTF
	task_queue = ["SECURE", "IDLE"]
	super._ready()
