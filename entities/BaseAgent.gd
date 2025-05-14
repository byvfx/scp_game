extends Node2D
class_name BaseAgent

enum Role { RESEARCHER, FIELD_AGENT, MTF }
enum State {
	IDLE,
	WORK,
	FLEE
}

# === FSM ===
var current_state: State = State.IDLE
var state_time := 0

# === Role & Task ===
var agent_role: Role = Role.RESEARCHER
var agent_name := "Unnamed Agent"
var task_queue: Array[String] = []
var current_task := ""
var tick_modulo := 4

# === Task Generation ===
var task_generator_timer = 0
var task_generation_interval = 10  # Generate new tasks every 10 ticks

# === Visual Hook ===
@export var visual_scene: PackedScene
var visual_instance = null

# === Input Handling ===
var input_cooldown = 0
var cooldown_time = 0.2  # seconds

# === Lifecycle ===
func _ready():
	# Initialize random number generator
	randomize()
	
	if visual_scene:
		print(agent_name, "has visual scene. Instantiating...")
		visual_instance = visual_scene.instantiate()
		
		# First, add the instance to the scene tree using deferred call
		get_tree().current_scene.call_deferred("add_child", visual_instance)
		
		# Then configure the instance (this needs to be deferred)
		call_deferred("_configure_visual_instance")
	else:
		print(agent_name, " has NO visual scene!")
	
	# Connect to tick manager
	if Engine.has_singleton("Tick_Manager") or get_node_or_null("/root/Tick_Manager"):
		Tick_Manager.connect("tick", Callable(self, "_on_tick"))
	else:
		print("WARNING: Tick_Manager not found! Create an autoload script for Tick_Manager.")

# New function to configure the visual instance after it's added to the scene
func _configure_visual_instance():
	if visual_instance and is_instance_valid(visual_instance):
		visual_instance.agent_ref = self
		visual_instance.global_position = global_position
		print(agent_name, "'s visual instance configured. Path: ", visual_instance.get_path())
		
		# Debug the scene tree
		print("Visual instance scene tree for ", agent_name, ":")
		_print_scene_tree(visual_instance)
		
		# Call sync_visuals immediately to ensure it's working
		if visual_instance.has_method("sync_visuals"):
			visual_instance.sync_visuals(str(current_state), current_task, agent_name)

func _print_scene_tree(node, indent=""):
	print(indent + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		_print_scene_tree(child, indent + "  ")

func _on_tick(time):
	if visual_instance:
		# Now try to sync visuals
		if visual_instance.has_method("sync_visuals"):
			visual_instance.sync_visuals(str(current_state), current_task, agent_name)

	if time % tick_modulo != 0:
		return

	# Increment task generator timer
	task_generator_timer += 1
	
	# Periodically generate new tasks
	if task_generator_timer >= task_generation_interval:
		task_generator_timer = 0
		generate_random_task()

	state_time += 1
	state_tick()

	if current_task == "":
		assign_task()

	run_task()
	print(agent_name, " ticked at time: ", time)

# Debug with keys to check to see if states with states
func _process(delta):
	# Update cooldown
	if input_cooldown > 0:
		input_cooldown -= delta
	
	# Only process input if cooldown is zero
	if input_cooldown <= 0:
		# Check for spacebar to cycle states
		if Input.is_physical_key_pressed(KEY_SPACE):
			match current_state:
				State.IDLE:
					set_state(State.WORK)
				State.WORK:
					set_state(State.FLEE)
				State.FLEE:
					set_state(State.IDLE)
			input_cooldown = cooldown_time
		
		# Check for number keys to set specific states
		elif Input.is_physical_key_pressed(KEY_1):
			set_state(State.IDLE)
			input_cooldown = cooldown_time
		elif Input.is_physical_key_pressed(KEY_2):
			set_state(State.WORK)
			input_cooldown = cooldown_time
		elif Input.is_physical_key_pressed(KEY_3):
			set_state(State.FLEE)
			input_cooldown = cooldown_time

# New function to generate random tasks based on agent role
func generate_random_task():
	# Each role has specific types of tasks they can do
	match agent_role:
		Role.RESEARCHER:
			var research_tasks = ["RESEARCH", "ANALYZE", "DOCUMENT"]
			task_queue.append(research_tasks[randi() % research_tasks.size()])
		Role.FIELD_AGENT:
			var field_tasks = ["PATROL", "INVESTIGATE", "SURVEY"]
			task_queue.append(field_tasks[randi() % field_tasks.size()])
		Role.MTF:
			var mtf_tasks = ["SECURE", "CONTAIN", "NEUTRALIZE"]
			task_queue.append(mtf_tasks[randi() % mtf_tasks.size()])
	
	print(agent_name, " received new task. Queue size: ", task_queue.size())

# === FSM Logic ===
func set_state(new_state: State):
	if new_state == current_state:
		return

	print(agent_name, " transitioning from ", current_state, " to ", new_state)
	exit_state(current_state)
	current_state = new_state
	enter_state(new_state)
	state_time = 0

func enter_state(state: State):
	match state:
		State.IDLE:
			print(agent_name, " is now idle.")
		State.WORK:
			print(agent_name, " starts working.")
		State.FLEE:
			print(agent_name, " panics and runs!")
		_:
			print(agent_name, " enters unknown state: ", state)

# Parameter is renamed with underscore to indicate it's intentionally unused
func exit_state(_state: State):
	pass

func state_tick():
	match current_state:
		State.IDLE:
			think_about_next_task()
		State.WORK:
			do_work()
		State.FLEE:
			flee()
		_:
			print(agent_name, " is in an unknown state.")

# === Behavior ===
func assign_task():
	if task_queue.size() > 0:
		current_task = task_queue.pop_front()
	else:
		current_task = "IDLE"

func run_task():
	match current_task:
		"IDLE":
			print(agent_name, " is idle.")
		"RESEARCH":
			print(agent_name, " is studying SCP-████.")
		"ANALYZE":
			print(agent_name, " is analyzing anomalous data.")
		"DOCUMENT":
			print(agent_name, " is documenting findings.")
		"PATROL":
			print(agent_name, " is patrolling the hallway.")
		"INVESTIGATE":
			print(agent_name, " is investigating a report.")
		"SURVEY":
			print(agent_name, " is surveying the area.")
		"SECURE":
			print(agent_name, " is securing the breach site.")
		"CONTAIN":
			print(agent_name, " is containing an anomaly.")
		"NEUTRALIZE":
			print(agent_name, " is neutralizing a threat.")
		_:
			print(agent_name, " has unknown task: ", current_task)

func think_about_next_task():
	if task_queue.size() > 0:
		current_task = task_queue.pop_front()
		set_state(State.WORK)
	else:
		current_task = "IDLE"
		print(agent_name, " is bored.")

func do_work():
	print(agent_name, " is doing task: ", current_task)
	
	# Work for a random duration between 3-8 ticks
	var work_duration = 3 + randi() % 6
	
	# Small chance to flee while working (simulating an SCP breach or danger)
	if state_time >= 2 and randf() < 0.05:  # 5% chance each tick after 2 ticks
		print(agent_name, " encountered danger!")
		set_state(State.FLEE)
	# Otherwise complete the task normally
	elif state_time >= work_duration:
		print(agent_name, " completed task: ", current_task)
		current_task = ""  # Clear the current task
		
		# If no more tasks, go idle
		if task_queue.size() == 0:
			set_state(State.IDLE)

func flee():
	print(agent_name, " is running away!")
	
	# After fleeing for a while (5 ticks), go back to work
	if state_time >= 5:
		set_state(State.WORK)
