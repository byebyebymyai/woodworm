extends Node2D
class_name Level

var _target_blocks: Array[TargetBlock] = []
var _source_blocks: Array[SourceBlock] = []

var _source_block_group_manager: SourceBlockGroupManager = SourceBlockGroupManager.new()
var _hud: CanvasLayer

func _ready():
	GridConfig.update()
	add_child(_source_block_group_manager)
	
	# 连接SourceBlockGroupManager的信号
	_source_block_group_manager.all_blocks_settled.connect(_on_all_blocks_settled)
	
	load_hud()
	load_block_configuration()

func load_hud():
	# 获取已存在的HUD子节点
	_hud = get_node("HUD")
	
	# 连接重置按钮信号
	var reset_button = _hud.get_node("HFlowContainer/Reset")
	reset_button.pressed.connect(on_reset)
	
	# 连接返回按钮信号
	var back_button = _hud.get_node("Back")
	back_button.pressed.connect(on_back)

func get_target_blocks_grid() -> Array[Vector2i]:
	# 这个方法应该在子类中被重写
	return []

func get_target_blocks_grid_position() -> Vector2i:
	# 这个方法应该在子类中被重写
	return Vector2i.ZERO

func get_source_blocks_grid_size() -> Vector2i:
	# 这个方法应该在子类中被重写
	return Vector2i.ZERO

func get_source_blocks_grid_position() -> Vector2i:
	# 这个方法应该在子类中被重写
	return Vector2i.ZERO

func get_level_name() -> String:
	# 这个方法应该在子类中被重写
	return ""

func load_block_configuration():
	var target_blocks_grid = get_target_blocks_grid()
	var target_blocks_grid_position = get_target_blocks_grid_position()
	
	for target_block_grid in target_blocks_grid:
		create_target_block(Vector2i(target_blocks_grid_position.x + target_block_grid.x, target_blocks_grid_position.y + target_block_grid.y))
	
	var source_blocks_grid_size = get_source_blocks_grid_size()
	var source_blocks_grid_position = get_source_blocks_grid_position()
	
	for x in range(source_blocks_grid_size.x):
		for y in range(source_blocks_grid_size.y):
			create_source_block(Vector2i(source_blocks_grid_position.x + x, source_blocks_grid_position.y - y))
	
	_source_block_group_manager.group_source_blocks(_source_blocks)
	
	check_shape_match()

func create_target_block(grid_position: Vector2i):
	var target_block = TargetBlock.new(grid_position)
	add_child(target_block)
	_target_blocks.append(target_block)

func create_source_block(grid_position: Vector2i):
	var source_block = SourceBlock.new(grid_position)
	source_block.being_eaten.connect(_on_source_block_being_eaten)
	add_child(source_block)
	_source_blocks.append(source_block)

func _on_source_block_being_eaten(source_block: SourceBlock):
	# 从列表中移除
	if source_block in _source_blocks:
		_source_blocks.erase(source_block)
	
	# 委托给 SourceBlockGroupManager 处理分组逻辑
	_source_block_group_manager.handle_source_block_being_eaten(source_block)
	
	check_shape_match()

func _on_all_blocks_settled():
	check_shape_match()

func check_shape_match():
	# 标准化两个形状
	var target_positions: Array[Vector2i] = []
	for b in _target_blocks:
		target_positions.append(b.grid_position)
	var normalized_target_shape = normalize_shape(target_positions)
	
	var source_positions: Array[Vector2i] = []
	for b in _source_blocks:
		source_positions.append(b.grid_position)
	var normalized_source_shape = normalize_shape(source_positions)
	
	# 比较形状
	if shapes_equal(normalized_target_shape, normalized_source_shape):
		print("🎉 形状匹配成功！SourceBlocks 的形状与 TargetBlocks 相同！")
		on_level_completed()

func shapes_equal(shape1: Array[Vector2i], shape2: Array[Vector2i]) -> bool:
	if shape1.size() != shape2.size():
		return false
	
	for pos in shape1:
		if pos not in shape2:
			return false
	
	return true

## 关卡完成处理
func on_level_completed():
	# 标记关卡完成
	var progress_manager = LevelProgressManager
	if progress_manager != null:
		progress_manager.mark_level_completed(get_level_name())
	
	# 显示完成消息
	var completion_label = Label.new()
	completion_label.text = "🎉 关卡完成！"
	completion_label.position = Vector2(get_viewport().get_visible_rect().size.x / 2 - 60, 50)
	completion_label.size = Vector2(120, 30)
	completion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	completion_label.add_theme_color_override("font_color", Color.GOLD)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	completion_label.add_theme_stylebox_override("normal", style_box)
	add_child(completion_label)
	
	# 3秒后返回关卡选择界面
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func(): get_tree().call_deferred("change_scene_to_file", "res://scenes/level_select/level_select.tscn"))

## 标准化形状：将形状移动到原点，使最小x和y坐标为0
func normalize_shape(positions: Array[Vector2i]) -> Array[Vector2i]:
	if positions.size() == 0:
		return []
	
	# 找到最小的 x 和 y 坐标
	var min_x = positions[0].x
	var min_y = positions[0].y
	
	for pos in positions:
		if pos.x < min_x:
			min_x = pos.x
		if pos.y < min_y:
			min_y = pos.y
	
	# 将所有位置移动到原点
	var normalized: Array[Vector2i] = []
	for pos in positions:
		normalized.append(Vector2i(pos.x - min_x, pos.y - min_y))
	
	return normalized

func on_reset():
	# 清除所有现有的SourceBlock
	var source_blocks_copy = _source_blocks.duplicate()
	for source_block in source_blocks_copy:
		source_block.queue_free()
	_source_blocks.clear()
	
	# 清除所有现有的TargetBlock
	var target_blocks_copy = _target_blocks.duplicate()
	for target_block in target_blocks_copy:
		target_block.queue_free()
	_target_blocks.clear()
	
	# 清除SourceBlockGroupManager中的分组
	_source_block_group_manager.group_source_blocks([])
	
	# 重置WoodWorm位置和状态
	var wood_worm = get_node("WoodWorm")
	if wood_worm != null:
		wood_worm.reset(get_wood_worm_initial_position())
	
	# 重新加载关卡配置
	call_deferred("load_block_configuration")

func on_back():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_select/level_select.tscn")

func get_wood_worm_initial_position() -> Vector2:
	return Vector2(432 - 16, 368 - 16)