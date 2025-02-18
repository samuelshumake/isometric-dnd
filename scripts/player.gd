extends CharacterBody2D

@export var speed = 75

var target : Vector2
var map : TileMapLayer

var astar_grid : AStarGrid2D = AStarGrid2D.new()
var path_array : Array[Vector2] = []
var path_global : Array[Vector2] = []

func _ready():
	target = global_position
	map = get_node("/root/Node2D/TileMapLayer") 
	
	# A* init
	astar_grid.region = map.get_used_rect()
	astar_grid.update()
	
	# Loop through all cells and if it has collider, set that cells A* Grid cell to solid
	for i in map.get_used_cells():
		if map.get_cell_tile_data(i).get_collision_polygons_count(0):
			astar_grid.set_point_solid(i)
	

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		target = get_global_mouse_position()
		path_global.clear()
		
		var curr_coord : Vector2 = map.local_to_map(global_position)
		var cell_coord : Vector2 = map.local_to_map(target)
	
		for cell_coords in astar_grid.get_id_path(curr_coord, cell_coord):
			var cell_position_local : Vector2 = map.map_to_local(cell_coords)
			var cell_position_global : Vector2 = map.to_global(cell_position_local)
			path_global.append(cell_position_global)

			
func _physics_process(delta):
	
	# If A* has been initialized
	if (path_global):
		velocity = global_position.direction_to(path_global[0]) * speed
		if (global_position.distance_to(path_global[0]) > 1):
			move_and_slide()
		else:
			path_global.remove_at(0)
