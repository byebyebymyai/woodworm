extends Block
class_name SourceBlock

signal being_eaten(source_block: SourceBlock)

var background_color: Color = Color.YELLOW

func _init(grid_position: Vector2i):
	super (grid_position)
	collision_layer = CollisionLayers.PICKUP

func setup_tile_background():
	# 使用金色瓦片作为背景
	var texture = TileConfig.load_tile_texture()
	var region = TileConfig.source_block
	
	setup_background_sprite(texture, region)

func start_being_eaten():
	being_eaten.emit(self)
	play_eaten_animation()

func play_eaten_animation():
	# 创建缩放和淡出动画
	var tween = create_tween()
	
	# 并行执行多个动画
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 动画完成后移除节点
	tween.tween_callback(queue_free)
