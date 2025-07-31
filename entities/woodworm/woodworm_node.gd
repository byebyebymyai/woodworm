extends CharacterBody2D
class_name WoodwormNode

var grid_position: Vector2i
var grid_orientation: Vector2i

var _animated_sprite: AnimatedSprite2D
var _collision_shape: CollisionShape2D
var _gravity_ray_cast: RayCast2D
var _left_wall_ray_cast: RayCast2D
var _right_wall_ray_cast: RayCast2D

var direction: Vector2i
var orientation: Vector2i
var on_left_wall: bool = false

@export var animation_speed: float = 5.0

var _moving: bool = false

func _ready():
	_animated_sprite = get_node("AnimatedSprite2D")
	_collision_shape = get_node("CollisionShape2D")
	_gravity_ray_cast = get_node("GravityRayCast")
	_left_wall_ray_cast = get_node("LeftWallRayCast")
	_right_wall_ray_cast = get_node("RightWallRayCast")
	grid_orientation = Vector2i.RIGHT
	grid_position = GridConfig.global_position_to_grid(global_position)
	
	collision_layer = CollisionLayers.PLAYER
	collision_mask = CollisionLayers.ALL_EXCEPT_PLAYER
	
	_gravity_ray_cast.collision_mask = CollisionLayers.ALL_EXCEPT_PLAYER
	_left_wall_ray_cast.collision_mask = CollisionLayers.ALL_BLOCKS
	_right_wall_ray_cast.collision_mask = CollisionLayers.ALL_BLOCKS

func move_and_slide_async(_delta: float):
	if not _moving:
		var start_position = position
		var target_position = position + Vector2(direction * GridConfig.cell_size)
		var offset_position = start_position + Vector2(direction * GridConfig.cell_size) / 2
		
		# 立即更新逻辑位置和碰撞区域
		grid_position += direction
		position = target_position
		_moving = true
		
		# 设置精灵的初始偏移位置（相对于节点）
		var start_sprite_offset = start_position - target_position
		var offset_sprite_position = offset_position - target_position
		_animated_sprite.position = start_sprite_offset
		
		var tween = create_tween()
		
		# 非垂直时使用蠕动动画 - 分三个阶段
		
		# 阶段1: 拉伸阶段 - 身体开始向目标方向拉伸，占据两个格子
		var stretch_duration = 1.0 / animation_speed * 0.4 # 40%的时间用于拉伸
		
		# 根据移动方向调整拉伸
		var stretch_scale = Vector2.ONE
		stretch_scale = Vector2(1.0, 1.0) # 水平拉伸
		
		# 同时执行拉伸和位置调整（只影响精灵）
		tween.parallel().tween_property(_animated_sprite, "position", offset_sprite_position, stretch_duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(_animated_sprite, "scale", stretch_scale, stretch_duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		# 阶段2: 移动和收缩阶段 - 分两个子阶段以便平滑转换朝向
		var total_duration = 1.0 / animation_speed * 0.6 # 总时间60%
		var first_phase_duration = total_duration * 0.7
		var second_phase_duration = total_duration * 0.3
		
		var mid_sprite_position = start_sprite_offset + (Vector2.ZERO - start_sprite_offset) * 0.7
		var mid_scale = stretch_scale
		
		# 阶段2a: 移动和收缩的前半段
		tween.parallel().tween_property(_animated_sprite, "position", mid_sprite_position, first_phase_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(_animated_sprite, "scale", mid_scale, first_phase_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# 在两个子阶段之间进行朝向转换
		tween.tween_callback(set_grid_orientation)
		
		# 阶段2b: 移动和收缩的后半段
		tween.parallel().tween_property(_animated_sprite, "position", Vector2.ZERO, second_phase_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(_animated_sprite, "scale", Vector2.ONE, second_phase_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		
		await tween.finished
		
		_moving = false

func set_grid_orientation():
	grid_orientation = orientation
	
	if orientation == Vector2i.DOWN:
		_animated_sprite.rotation = PI * 1 / 2
		if on_left_wall:
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = true
		else:
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = false
	elif orientation == Vector2i.UP:
		_animated_sprite.rotation = PI * 3 / 2
		if on_left_wall:
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = true
		else:
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = false
	else:
		_animated_sprite.rotation = 0
		_animated_sprite.flip_h = orientation.x < 0 # 向左时水平翻转
		_animated_sprite.flip_v = false
	
	direction = Vector2i.ZERO
	orientation = Vector2i.ZERO

func is_moving() -> bool:
	return _moving

func fall_async():
	var start_position = position
	var target_position = position + Vector2(0, GridConfig.cell_size.y)
	
	# 立即更新逻辑位置和碰撞区域
	grid_position += Vector2i.DOWN
	position = target_position
	
	_moving = true
	
	# 设置精灵的初始偏移位置（相对于节点）
	_animated_sprite.position = start_position - target_position
	
	var tween = create_tween()
	tween.tween_property(_animated_sprite, "position", Vector2.ZERO, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	
	_moving = false

func get_left_wall_target_position() -> Vector2:
	# 数学简化：逆时针90度旋转 (x, y) -> (-y, x) - 相对于朝向的左侧
	var left_direction = Vector2i(-grid_orientation.y, grid_orientation.x)
	return Vector2(left_direction * GridConfig.cell_size)

func get_right_wall_target_position() -> Vector2:
	# 数学简化：顺时针90度旋转 (x, y) -> (y, -x) - 相对于朝向的右侧
	var right_direction = Vector2i(grid_orientation.y, -grid_orientation.x)
	return Vector2(right_direction * GridConfig.cell_size)

func is_touching_wall() -> bool:
	if grid_orientation == Vector2i.LEFT or grid_orientation == Vector2i.RIGHT:
		return false
	
	_left_wall_ray_cast.target_position = get_left_wall_target_position()
	_left_wall_ray_cast.force_raycast_update()
	_right_wall_ray_cast.target_position = get_right_wall_target_position()
	_right_wall_ray_cast.force_raycast_update()
	return _left_wall_ray_cast.is_colliding() or _right_wall_ray_cast.is_colliding()

func is_touching_floor() -> bool:
	_gravity_ray_cast.target_position = Vector2(0, GridConfig.cell_size.y)
	_gravity_ray_cast.force_raycast_update()
	return _gravity_ray_cast.is_colliding()

## 重置WoodwormNode到指定的网格位置和状态
func reset():
	orientation = Vector2i.RIGHT
	direction = Vector2i.RIGHT
	on_left_wall = false
	grid_position = GridConfig.global_position_to_grid(global_position)
	
	_moving = false
	set_grid_orientation()
	
	# 重置精灵位置和缩放（防止动画过程中的偏移和缩放残留）
	if _animated_sprite != null:
		_animated_sprite.position = Vector2.ZERO
		_animated_sprite.scale = Vector2.ONE
