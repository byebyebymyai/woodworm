extends Node2D

var cell_size: Vector2i = Vector2i(32, 32)
var astar_grid_2d: AStarGrid2D = AStarGrid2D.new()
var grid_size: Vector2i

func update():
	grid_size = Vector2i(
		int(get_viewport_rect().size.x / cell_size.x),
		int(get_viewport_rect().size.y / cell_size.y)
	)
	print("GridSize: " + str(grid_size))
	astar_grid_2d.cell_size = cell_size
	astar_grid_2d.region = Rect2i(0, 0, grid_size.x, grid_size.y)
	astar_grid_2d.offset = Vector2(cell_size) / 2
	astar_grid_2d.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid_2d.update()

## 网格坐标转换为世界坐标
func grid_to_global_position(grid_position: Vector2i) -> Vector2:
	return Vector2(grid_position.x * cell_size.x, grid_position.y * cell_size.y)

## 世界坐标转换为网格坐标
func global_position_to_grid(world_position: Vector2) -> Vector2i:
	return Vector2i(
		int(world_position.x / cell_size.x),
		int(world_position.y / cell_size.y)
	)

## 世界坐标转换为最接近的世界坐标
func to_nearest_world(world_position: Vector2) -> Vector2:
	return grid_to_global_position(global_position_to_grid(world_position))
