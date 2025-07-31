extends Block
class_name TargetBlock

func _init(grid_position: Vector2i):
	super (grid_position)

func setup_tile_background():
	# 使用宝石瓦片作为背景
	var texture = TileConfig.load_tile_texture()
	var region = TileConfig.target_block
	
	setup_background_sprite(texture, region)