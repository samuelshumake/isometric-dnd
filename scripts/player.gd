extends CharacterBody2D


@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@export var speed = 75
var target
var map
var space_state
var nav_agent

func _ready():
	target = global_position
	map = get_node("/root/Node2D/TileMapLayer") 
	space_state = get_world_2d().direct_space_state
	nav_agent = false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var cell_coord = map.local_to_map(mouse_pos)
		if (map.get_cell_tile_data(cell_coord)):
			target = mouse_pos
#			# Use raycast to check if collisions. If so, use NavigationAgent
			var query = PhysicsRayQueryParameters2D.create(global_position, target)
			var result = space_state.intersect_ray(query)
			if result:
				nav_agent = true
				navigation_agent_2d.target_position = target
			
			
func _physics_process(delta):
	velocity = global_position.direction_to(target) * speed
	
#	TODO: Gets stuck on walls and movement completely stops
	if nav_agent:
		if navigation_agent_2d.is_navigation_finished():
			nav_agent = false
			return
			
		var next_path_position = navigation_agent_2d.get_next_path_position()
		velocity =  global_position.direction_to(next_path_position) * speed
		
		if navigation_agent_2d.avoidance_enabled:
			navigation_agent_2d.set_velocity(velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(velocity)
		
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	pass # Replace with function body.
