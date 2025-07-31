extends Level

# 十字架
static var target_blocks_grid: Array[Vector2i] = [
	Vector2i(1, 5),
	Vector2i(2, 5),
	Vector2i(3, 5),
	Vector2i(4, 5),
	Vector2i(5, 5),
	Vector2i(1, 4),
	Vector2i(2, 4),
	Vector2i(4, 4),
	Vector2i(5, 4),
	Vector2i(1, 3),
	Vector2i(2, 3),
	Vector2i(4, 3),
	Vector2i(5, 3),
	Vector2i(1, 2),
	Vector2i(5, 2),
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(4, 1),
	Vector2i(5, 1),
	Vector2i(2, 0),
	Vector2i(3, 0),
	Vector2i(4, 0)
]
var target_blocks_grid_position = Vector2i(3, 6)
var source_blocks_grid_size = Vector2i(5, 7)
var source_blocks_grid_position = Vector2i(15, 11)
static var level_name = "level_7"

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