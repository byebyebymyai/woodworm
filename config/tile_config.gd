extends Node2D

# 瓦片纹理路径
const TILES_TEXTURE_PATH = "res://assets/spritesheet-tiles-default.png"
const BACKGROUNDS_TEXTURE_PATH = "res://assets/spritesheet-backgrounds-default.png"

# 瓦片大小
const TILE_SIZE = 64
const BACKGROUND_TILE_SIZE = 256

## 获取瓦片区域
static func get_tile_region(x: int, y: int, size: int = TILE_SIZE) -> Rect2:
	return Rect2(x * size, y * size, size, size)

static var target_block: Rect2 = get_tile_region(16, 6)
static var source_block: Rect2 = get_tile_region(17, 5)

## 加载瓦片纹理
static func load_tile_texture() -> Texture2D:
	return load(TILES_TEXTURE_PATH) as Texture2D