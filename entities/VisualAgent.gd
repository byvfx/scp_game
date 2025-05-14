extends Node2D

var sprite_node: Sprite2D = null
var label_node: Label = null

var agent_ref = null
var current_state = "IDLE" # Track the current state

# Visual effect variables
var flash_time = 0
var flashing = false
var alert_effect = false
var alert_time = 0

func _ready():
	# Try to get references to child nodes
	sprite_node = get_node_or_null("Sprite2D")
	label_node = get_node_or_null("Label")
	
	# Debug output
	print("VisualAgent ready. Has Label: ", label_node != null)
	print("VisualAgent ready. Has Sprite2D: ", sprite_node != null)
	
	# If nodes aren't found, try to search for them
	if not sprite_node:
		sprite_node = find_child("Sprite2D", true, false)
	
	if not label_node:
		label_node = find_child("Label", true, false)
	
	# Set up default appearance
	if sprite_node:
		# Default appearance - white
		sprite_node.modulate = Color.WHITE

func _process(delta):
	# Visual effect when state changes
	if flashing:
		flash_time += delta
		if flash_time < 0.5:
			# Flash brighter
			if sprite_node:
				sprite_node.modulate.a = 1.0 + sin(flash_time * 20) * 0.3
		else:
			flashing = false
			flash_time = 0
			# Reset to normal
			if sprite_node:
				sprite_node.modulate.a = 1.0
	
	# Alert effect for FLEE state
	if current_state == "FLEE" and not flashing:
		alert_effect = true
		alert_time += delta
		
		# Pulsing red effect
		if sprite_node:
			var pulse = (sin(alert_time * 8) + 1) / 2.0
			sprite_node.modulate = Color(1.0, 0.2 * (1-pulse), 0.2 * (1-pulse), 1.0)
	elif current_state != "FLEE":
		alert_effect = false

func sync_visuals(state: String, task: String, agent_name: String):
	print("SYNCING VISUALS for:", agent_name, "State:", state, "Task:", task)
	
	# Always re-check that nodes exist
	if not sprite_node:
		sprite_node = get_node_or_null("Sprite2D")
	
	if not label_node:
		label_node = get_node_or_null("Label")
	
	# Update state
	current_state = state
	
	# Apply base color based on state
	if sprite_node:
		match state:
			"IDLE":
				sprite_node.modulate = Color(1.0, 1.0, 1.0, 1.0)  # White
			"WORK":
				sprite_node.modulate = Color(1.0, 0.9, 0.0, 1.0)  # Bright Yellow
			"FLEE":
				sprite_node.modulate = Color(1.0, 0.2, 0.2, 1.0)  # Bright Red
			_:
				sprite_node.modulate = Color(0.8, 0.8, 0.8, 1.0)  # Light Gray
	
	# Update label to show the agent's name, state, and task
	if label_node:
		# Format the text to include name, state and task
		label_node.text = "%s\n(%s) [%s]" % [agent_name, state, task]
		
		# Color the label text based on state too
		match state:
			"IDLE":
				label_node.modulate = Color(1.0, 1.0, 1.0, 1.0)  # White
			"WORK":
				label_node.modulate = Color(1.0, 0.9, 0.0, 1.0)  # Bright Yellow
			"FLEE":
				label_node.modulate = Color(1.0, 0.2, 0.2, 1.0)  # Bright Red
			_:
				label_node.modulate = Color(0.8, 0.8, 0.8, 1.0)  # Light Gray
