# FieldAgent.gd
extends "res://entities/BaseAgent.gd"

func _ready():
	agent_name = "Agent Hawk"
	agent_role = Role.FIELD_AGENT
	task_queue = ["PATROL", "IDLE"]
	super._ready()
