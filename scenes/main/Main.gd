extends Node2D

# 滚动相关变量
var _tile_map_layer_sky: TileMapLayer
var _tile_map_layer_floor: TileMapLayer
var _tile_map_layer_sky2: TileMapLayer # 用于无缝循环的第二个天空层
var _tile_map_layer_floor2: TileMapLayer # 用于无缝循环的第二个地面层

var _scroll_speed: float = 100.0 # 滚动速度（像素/秒）

# 视差滚动系数
var _sky_parallax_factor: float = 0.7 # 天空滚动速度系数（比地面慢）
var _floor_parallax_factor: float = 1.0 # 地面滚动速度系数

# TileMap尺寸（会在运行时计算）
var _sky_map_width: float
var _floor_map_width: float

# Called when the node enters the scene tree for the first time.
func _ready():
	GridConfig.update()
	
	# 获取现有的TileMapLayer节点
	_tile_map_layer_sky = get_node("TileMapLayerSky")
	_tile_map_layer_floor = get_node("TileMapLayerFloor")
	
	# 计算TileMap的实际宽度
	calculate_tile_map_widths()
	
	# 创建第二套TileMapLayer用于无缝循环
	create_secondary_tile_maps()
	
	print("Main: 无限视差滚动背景已初始化 - 天空宽度: %f, 地面宽度: %f" % [_sky_map_width, _floor_map_width])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# 更新滚动
	update_scrolling(delta)

func _draw():
	draw_grid()

func draw_grid():
	for x in range(GridConfig.grid_size.x + 1):
		draw_line(
			Vector2(x * GridConfig.cell_size.x, 0),
			Vector2(x * GridConfig.cell_size.x, GridConfig.grid_size.y * GridConfig.cell_size.y),
			Color.DIM_GRAY, 2.0
		)
	for y in range(GridConfig.grid_size.y + 1):
		draw_line(
			Vector2(0, y * GridConfig.cell_size.y),
			Vector2(GridConfig.grid_size.x * GridConfig.cell_size.x, y * GridConfig.cell_size.y),
			Color.DIM_GRAY, 2.0
		)

## 计算TileMap的实际宽度
func calculate_tile_map_widths():
	# 获取TileMap的使用区域
	var sky_used_rect = _tile_map_layer_sky.get_used_rect()
	var floor_used_rect = _tile_map_layer_floor.get_used_rect()
	
	# 分别获取各自的TileSet尺寸
	var sky_tile_size = Vector2i.ZERO
	var floor_tile_size = Vector2i.ZERO
	
	if _tile_map_layer_sky.tile_set != null:
		sky_tile_size = _tile_map_layer_sky.tile_set.tile_size
	if _tile_map_layer_floor.tile_set != null:
		floor_tile_size = _tile_map_layer_floor.tile_set.tile_size
	
	# 计算实际像素宽度
	_sky_map_width = sky_used_rect.size.x * sky_tile_size.x
	_floor_map_width = floor_used_rect.size.x * floor_tile_size.x
	
	# 确保两个宽度都不小于屏幕宽度
	var screen_width = get_viewport().get_visible_rect().size.x
	if _sky_map_width < screen_width:
		_sky_map_width = screen_width
	if _floor_map_width < screen_width:
		_floor_map_width = screen_width
	
	print("最终宽度 - Sky: %f, Floor: %f" % [_sky_map_width, _floor_map_width])

## 创建第二套TileMapLayer用于无缝循环
func create_secondary_tile_maps():
	# 复制天空层
	_tile_map_layer_sky2 = _tile_map_layer_sky.duplicate()
	_tile_map_layer_sky2.position = Vector2(_sky_map_width, _tile_map_layer_sky.position.y)
	_tile_map_layer_sky2.name = "TileMapLayerSky2"
	add_child(_tile_map_layer_sky2)
	
	# 复制地面层
	_tile_map_layer_floor2 = _tile_map_layer_floor.duplicate()
	_tile_map_layer_floor2.position = Vector2(_floor_map_width, _tile_map_layer_floor.position.y)
	_tile_map_layer_floor2.name = "TileMapLayerFloor2"
	add_child(_tile_map_layer_floor2)

## 更新视差滚动效果
func update_scrolling(delta: float):
	if _scroll_speed == 0:
		return # 如果速度为0则不滚动
	
	# 计算不同层的滚动偏移量
	var sky_scroll_offset = _scroll_speed * _sky_parallax_factor * delta
	var floor_scroll_offset = _scroll_speed * _floor_parallax_factor * delta
	
	# 移动天空层（较慢）
	_tile_map_layer_sky.position -= Vector2(sky_scroll_offset, 0)
	_tile_map_layer_sky2.position -= Vector2(sky_scroll_offset, 0)
	
	# 移动地面层（较快）
	_tile_map_layer_floor.position -= Vector2(floor_scroll_offset, 0)
	_tile_map_layer_floor2.position -= Vector2(floor_scroll_offset, 0)
	
	# 检查是否需要重置位置（无缝循环）
	reset_tile_map_positions()

## 重置TileMap位置实现无缝循环
func reset_tile_map_positions():
	# 重置天空层位置
	if _tile_map_layer_sky.position.x <= -_sky_map_width:
		var new_pos = Vector2(_tile_map_layer_sky2.position.x + _sky_map_width, _tile_map_layer_sky.position.y)
		_tile_map_layer_sky.position = new_pos
	
	if _tile_map_layer_sky2.position.x <= -_sky_map_width:
		var new_pos = Vector2(_tile_map_layer_sky.position.x + _sky_map_width, _tile_map_layer_sky2.position.y)
		_tile_map_layer_sky2.position = new_pos
	
	# 重置地面层位置
	if _tile_map_layer_floor.position.x <= -_floor_map_width:
		var new_pos = Vector2(_tile_map_layer_floor2.position.x + _floor_map_width, _tile_map_layer_floor.position.y)
		_tile_map_layer_floor.position = new_pos
	
	if _tile_map_layer_floor2.position.x <= -_floor_map_width:
		var new_pos = Vector2(_tile_map_layer_floor.position.x + _floor_map_width, _tile_map_layer_floor2.position.y)
		_tile_map_layer_floor2.position = new_pos

## 播放按钮点击事件
func _on_button_pressed():
	# 这里可以切换到关卡选择场景
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_select/level_select.tscn")
	
	# 或者如果有关卡选择场景的PackedScene引用，可以这样做：
	# if level_select_scene != null:
	#     var level_select_instance = level_select_scene.instantiate()
	#     get_tree().root.add_child(level_select_instance)
	#     queue_free()
