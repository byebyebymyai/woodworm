extends Level

# 显示器
static var target_blocks_grid: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(2, 0),
	Vector2i(3, 0),
	Vector2i(4, 0),
	Vector2i(5, 0),
	Vector2i(6, 0),
	Vector2i(7, 0),
	Vector2i(1, 1),
	Vector2i(7, 1),
	Vector2i(1, 2),
	Vector2i(7, 2),
	Vector2i(1, 3),
	Vector2i(7, 3),
	Vector2i(1, 4),
	Vector2i(7, 4),
	Vector2i(1, 5),
	Vector2i(2, 5),
	Vector2i(3, 5),
	Vector2i(4, 5),
	Vector2i(5, 5),
	Vector2i(6, 5),
	Vector2i(7, 5),
	Vector2i(3, 6),
	Vector2i(4, 6),
	Vector2i(5, 6),
	Vector2i(2, 7),
	Vector2i(3, 7),
	Vector2i(4, 7),
	Vector2i(5, 7),
	Vector2i(6, 7)
]
var target_blocks_grid_position = Vector2i(1, 4)
var source_blocks_grid_size = Vector2i(7, 8)
var source_blocks_grid_position = Vector2i(15, 11)
static var level_name = "level_6"

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