extends Level

# 暂定
static var target_blocks_grid: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(2, 0),
	Vector2i(3, 0),
	Vector2i(4, 0),
	Vector2i(5, 0),
	Vector2i(6, 0),
	Vector2i(7, 0),
	Vector2i(1, 1),
	Vector2i(3, 1),
	Vector2i(5, 1),
	Vector2i(7, 1),
	Vector2i(1, 2),
	Vector2i(2, 2),
	Vector2i(4, 2),
	Vector2i(6, 2),
	Vector2i(7, 2),
	Vector2i(1, 3),
	Vector2i(2, 3),
	Vector2i(3, 3),
	Vector2i(4, 3),
	Vector2i(5, 3),
	Vector2i(6, 3),
	Vector2i(7, 3),
	Vector2i(8, 3),
	Vector2i(9, 3),
	Vector2i(10, 3),
	Vector2i(1, 4),
	Vector2i(2, 4),
	Vector2i(3, 4),
	Vector2i(4, 4),
	Vector2i(5, 4),
	Vector2i(6, 4),
	Vector2i(7, 4),
	Vector2i(10, 4),
	Vector2i(1, 5),
	Vector2i(2, 5),
	Vector2i(3, 5),
	Vector2i(4, 5),
	Vector2i(5, 5),
	Vector2i(6, 5),
	Vector2i(7, 5),
	Vector2i(10, 5),
	Vector2i(1, 6),
	Vector2i(2, 6),
	Vector2i(3, 6),
	Vector2i(4, 6),
	Vector2i(5, 6),
	Vector2i(6, 6),
	Vector2i(7, 6),
	Vector2i(10, 6),
	Vector2i(1, 7),
	Vector2i(2, 7),
	Vector2i(3, 7),
	Vector2i(4, 7),
	Vector2i(5, 7),
	Vector2i(6, 7),
	Vector2i(7, 7),
	Vector2i(8, 7),
	Vector2i(9, 7)
]
var target_blocks_grid_position = Vector2i(-1, 4)
var source_blocks_grid_size = Vector2i(10, 10)
var source_blocks_grid_position = Vector2i(13, 11)
static var level_name = "level_8"

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

func get_wood_worm_initial_position() -> Vector2:
	return Vector2(400 - 16, 368 - 16)