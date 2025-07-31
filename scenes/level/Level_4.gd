extends Level

# 井字形
static var target_blocks_grid: Array[Vector2i] = [
	Vector2i(2, 0),
	Vector2i(4, 0),
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(3, 1),
	Vector2i(4, 1),
	Vector2i(5, 1),
	Vector2i(2, 2),
	Vector2i(4, 2),
	Vector2i(1, 3),
	Vector2i(2, 3),
	Vector2i(3, 3),
	Vector2i(4, 3),
	Vector2i(5, 3),
	Vector2i(2, 4),
	Vector2i(4, 4)
]
var target_blocks_grid_position = Vector2i(3, 7)
var source_blocks_grid_size = Vector2i(4, 5)
var source_blocks_grid_position = Vector2i(15, 11)
static var level_name = "level_4"

static func get_level_data():
	return {
		"target_blocks_grid": target_blocks_grid,
		"name": level_name
	}

func get_target_blocks_grid() -> Array[Vector2i]:
	return target_blocks_grid

func get_target_blocks_grid_position() -> Vector2i:
	return target_blocks_grid_position

func get_source_blocks_grid_size() -> Vector2i:
	return source_blocks_grid_size

func get_source_blocks_grid_position() -> Vector2i:
	return source_blocks_grid_position

func get_level_name() -> String:
	return level_name