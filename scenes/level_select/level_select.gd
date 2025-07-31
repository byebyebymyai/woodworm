extends Control

# 关卡图标配置
const ICON_SIZE = 192 # 每个关卡图标的尺寸
const ICON_SPACING = 32 # 图标之间的间距
# BLOCK_SCALE 现在根据目标块的大小动态计算

# 关卡图标图片路径
const COMPLETED_LEVEL_IMAGE = "res://assets/kenney_ui-pack/PNG/Green/Default/button_square_depth_gloss.png"
const UNCOMPLETED_LEVEL_IMAGE = "res://assets/kenney_ui-pack/PNG/Blue/Default/button_square_depth_gloss.png"

# 其他可选的图片样式（注释掉的可以替换使用）：
# const COMPLETED_LEVEL_IMAGE = "res://assets/kenney_ui-pack/PNG/Green/Default/button_round_depth_gloss.png"
# const UNCOMPLETED_LEVEL_IMAGE = "res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_depth_gloss.png"
# const COMPLETED_LEVEL_IMAGE = "res://assets/kenney_ui-pack/PNG/Green/Default/button_rectangle_depth_gloss.png"
# const UNCOMPLETED_LEVEL_IMAGE = "res://assets/kenney_ui-pack/PNG/Blue/Default/button_rectangle_depth_gloss.png"

# 关卡数据
var levels: Array = []

# UI组件
var level_container: HBoxContainer

func _ready():
	# 获取HBoxContainer
	level_container = get_node("VBoxContainer/ScrollContainer/HBoxContainer")
	level_container.add_theme_constant_override("separation", ICON_SPACING)
	
	# 设置滚动容器的padding
	var scroll_container = get_node("VBoxContainer/ScrollContainer")
	scroll_container.add_theme_constant_override("margin_left", ICON_SPACING)
	scroll_container.add_theme_constant_override("margin_right", ICON_SPACING)
	scroll_container.add_theme_constant_override("margin_top", ICON_SPACING)
	scroll_container.add_theme_constant_override("margin_bottom", ICON_SPACING)
	
	update_ui_text()
	
	load_level_data()
	create_level_icons()

## 更新UI文本以支持国际化
func update_ui_text():
	var title_label = get_node("VBoxContainer/Title")
	title_label.text = tr("LEVEL_SELECT_TITLE")

## 加载关卡数据
func load_level_data():
	# 直接定义关卡数据而不依赖类引用
	var level_configs = [
		{"name": "level_1", "target_blocks_grid": [Vector2i(3, 0), Vector2i(2, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2)]},
		{"name": "level_2", "target_blocks_grid": [Vector2i(3, 2), Vector2i(1, 2), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(2, 0)]},
		{"name": "level_3", "target_blocks_grid": [Vector2i(1, 4), Vector2i(4, 4), Vector2i(1, 3), Vector2i(4, 3), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(1, 1), Vector2i(1, 0)]},
		{"name": "level_4", "target_blocks_grid": [Vector2i(2, 0), Vector2i(4, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(2, 2), Vector2i(4, 2), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3), Vector2i(2, 4), Vector2i(4, 4)]},
		{"name": "level_5", "target_blocks_grid": [Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6), Vector2i(4, 6), Vector2i(5, 6), Vector2i(1, 5), Vector2i(5, 5), Vector2i(1, 4), Vector2i(5, 4), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3), Vector2i(1, 2), Vector2i(5, 2), Vector2i(1, 1), Vector2i(5, 1), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0)]},
		{"name": "level_6", "target_blocks_grid": [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0), Vector2i(1, 1), Vector2i(7, 1), Vector2i(1, 2), Vector2i(7, 2), Vector2i(1, 3), Vector2i(7, 3), Vector2i(1, 4), Vector2i(7, 4), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5), Vector2i(7, 5), Vector2i(3, 6), Vector2i(4, 6), Vector2i(5, 6), Vector2i(2, 7), Vector2i(3, 7), Vector2i(4, 7), Vector2i(5, 7), Vector2i(6, 7)]},
		{"name": "level_7", "target_blocks_grid": [Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5), Vector2i(1, 4), Vector2i(2, 4), Vector2i(4, 4), Vector2i(5, 4), Vector2i(1, 3), Vector2i(2, 3), Vector2i(4, 3), Vector2i(5, 3), Vector2i(1, 2), Vector2i(5, 2), Vector2i(1, 1), Vector2i(2, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0)]},
		{"name": "level_8", "target_blocks_grid": [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0), Vector2i(1, 1), Vector2i(3, 1), Vector2i(5, 1), Vector2i(7, 1), Vector2i(1, 2), Vector2i(2, 2), Vector2i(4, 2), Vector2i(6, 2), Vector2i(7, 2), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3), Vector2i(7, 3), Vector2i(8, 3), Vector2i(9, 3), Vector2i(10, 3), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4), Vector2i(10, 4), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5), Vector2i(7, 5), Vector2i(10, 5), Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6), Vector2i(4, 6), Vector2i(5, 6), Vector2i(6, 6), Vector2i(7, 6), Vector2i(10, 6), Vector2i(1, 7), Vector2i(2, 7), Vector2i(3, 7), Vector2i(4, 7), Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7), Vector2i(8, 7), Vector2i(9, 7)]}
	]
	
	levels = level_configs

## 创建关卡图标（横向滚动）
func create_level_icons():
	for i in range(levels.size()):
		create_level_icon(levels[i])

## 创建单个关卡图标
func create_level_icon(level_data):
	var is_completed = false
	if LevelProgressManager != null:
		is_completed = LevelProgressManager.is_level_completed(level_data["name"])
	
	# 创建图标容器（增加高度以容纳名称标签）
	var icon_container = Control.new()
	icon_container.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	icon_container.mouse_filter = Control.MOUSE_FILTER_PASS
	level_container.add_child(icon_container)
	
	# 创建图片背景
	var background_sprite = Sprite2D.new()
	
	# 根据完成状态选择不同颜色的按钮图片
	var button_image_path = COMPLETED_LEVEL_IMAGE if is_completed else UNCOMPLETED_LEVEL_IMAGE
	
	background_sprite.texture = load(button_image_path) as Texture2D
	background_sprite.position = Vector2(ICON_SIZE / 2.0, ICON_SIZE / 2.0)
	
	# 缩放图片以适应图标大小
	var texture_size = background_sprite.texture.get_size()
	var scale_x = float(ICON_SIZE) / texture_size.x
	var scale_y = float(ICON_SIZE) / texture_size.y
	var bg_scale = min(scale_x, scale_y) * 0.9 # 稍微缩小一点留边距
	background_sprite.scale = Vector2(bg_scale, bg_scale)
	
	icon_container.add_child(background_sprite)
	
	# 创建目标块预览
	var preview = create_target_blocks_preview(level_data["target_blocks_grid"])
	icon_container.add_child(preview)
	
	# 添加一个半透明的覆盖层来放置目标块预览
	var overlay = ColorRect.new()
	overlay.position = Vector2(8, 8)
	overlay.size = Vector2(ICON_SIZE - 16, ICON_SIZE - 16)
	overlay.color = Color(0, 0, 0, 0.1)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_container.add_child(overlay)
	
	# 创建可点击区域
	var button = Button.new()
	button.size = Vector2(ICON_SIZE, ICON_SIZE)
	button.flat = true
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# 连接点击事件
	button.pressed.connect(func(): on_level_icon_clicked(level_data["name"]))
	
	icon_container.add_child(button)

## 关卡图标点击事件
func on_level_icon_clicked(level_name: String):
	print("点击了关卡 %s" % level_name)
	
	var scene_path = "res://scenes/level/%s.tscn" % level_name
	
	# 检查场景文件是否存在
	if ResourceLoader.exists(scene_path):
		# 切换到对应关卡
		get_tree().call_deferred("change_scene_to_file", scene_path)

## 创建目标块预览
func create_target_blocks_preview(target_blocks: Array) -> Node2D:
	var container = Node2D.new()
	container.position = Vector2(ICON_SIZE / 2.0, ICON_SIZE / 2.0)
	
	if target_blocks == null or target_blocks.size() == 0:
		return container
	
	# 计算边界框以居中显示
	var min_x = 999999
	var min_y = 999999
	var max_x = -999999
	var max_y = -999999
	
	for block in target_blocks:
		min_x = min(min_x, block.x)
		min_y = min(min_y, block.y)
		max_x = max(max_x, block.x)
		max_y = max(max_y, block.y)
	
	var center_x = (min_x + max_x) / 2.0
	var center_y = (min_y + max_y) / 2.0
	
	# 动态计算缩放比例，基于目标块的边界框大小
	var grid_width = max_x - min_x + 1
	var grid_height = max_y - min_y + 1
	var max_dimension = max(grid_width, grid_height)
	
	# 计算合适的缩放比例，确保预览能够适应图标大小（留一些边距）
	var available_size = ICON_SIZE * 0.7 # 使用图标70%的空间
	var required_size = max_dimension * TileConfig.TILE_SIZE
	var dynamic_scale = min(available_size / required_size, 0.5) # 最大缩放不超过0.5
	
	# 加载TargetBlock纹理
	var texture = TileConfig.load_tile_texture()
	var region = TileConfig.target_block
	
	for block_pos in target_blocks:
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.region_enabled = true
		sprite.region_rect = region
		
		# 计算相对于中心的位置并使用动态缩放
		var relative_pos = Vector2(
			(block_pos.x - center_x) * TileConfig.TILE_SIZE * dynamic_scale,
			(block_pos.y - center_y) * TileConfig.TILE_SIZE * dynamic_scale
		)
		
		sprite.position = relative_pos
		sprite.scale = Vector2(dynamic_scale, dynamic_scale)
		
		container.add_child(sprite)
	
	return container

## 返回主菜单
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			# 按ESC返回主菜单
			get_tree().call_deferred("change_scene_to_file", "res://scenes/main/main.tscn")
