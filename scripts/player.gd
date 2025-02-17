extends CharacterBody2D

@export var speed = 75

var target : Vector2
var map : TileMapLayer
var space_state : Object

var astar_grid : AStarGrid2D = AStarGrid2D.new()
var path_array : Array[Vector2] = []
var path_global : Array[Vector2] = []

func _ready():
	target = global_position
	map = get_node("/root/Node2D/TileMapLayer") 
	
	# Raycast init
	space_state = get_world_2d().direct_space_state
	
	# A* init
	astar_grid.region = map.get_used_rect()
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	# Loop through all cells and if it has collider, set that cells A* Grid cell to solid
	for i in map.get_used_cells():
		if map.get_cell_tile_data(i).get_collision_polygons_count(0):
			astar_grid.set_point_solid(i)
	

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		target = get_global_mouse_position()
		
		# If collision between player and target, initialize A*		
		if is_collide(target):
			var curr_coord : Vector2 = map.local_to_map(global_position)
			var cell_coord : Vector2 = map.local_to_map(target)
		
			for cell_coords in astar_grid.get_id_path(curr_coord, cell_coord):
				var cell_position_local : Vector2 = map.map_to_local(cell_coords)
				var cell_position_global : Vector2 = map.to_global(cell_position_local)
				path_global.append(cell_position_global)

			
func _physics_process(delta):
	
	# If A* has been initialized
	if (path_global):
		
		# If there's a collision between player and target, continue A*
		if is_collide(target):
			velocity = global_position.direction_to(path_global[0]) * speed
			if (global_position.distance_to(path_global[0]) > 1):
				move_and_slide()
			else:
				path_global.remove_at(0)
		# Otherwise, empty array
		else:
			path_global.clear()
	# If no collision, move in a straight line towards target
	else:
		velocity = global_position.direction_to(target) * speed
		if (global_position.distance_to(target) > 1):
			move_and_slide()
				
				
# Uses Raycast to check if collision occurs between global_position and end_position
func is_collide(end_pos):
	var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, end_pos)
	var result : Dictionary = space_state.intersect_ray(query)
	return result
