extends "res://entities/BaseAgent.gd"

func _ready():
	agent_name = "Dr. Glass"
	agent_role = Role.RESEARCHER
	task_queue = ["RESEARCH","RESEARCH"]
	super._ready()
