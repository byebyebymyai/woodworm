extends WoodwormNode

var _ray_cast: RayCast2D

func _ready():
	super ()
	_ray_cast = get_node("RayCast2D")
	_ray_cast.collision_mask = CollisionLayers.ALL

func move_and_slide_async(delta: float):
	if can_move_to_grid_direction(direction):
		# 检查目标位置是否有SourceBlock
		var target_grid_position = grid_position + direction
		check_and_eat_source_block(target_grid_position)
		
		var start_position = position
		var target_position = position + Vector2(direction * GridConfig.cell_size)
		
		# 立即更新逻辑位置和碰撞区域
		grid_position += direction
		position = target_position
		
		_moving = true
		
		set_grid_orientation()
		
		# 只移动视觉部分（精灵），碰撞区域已经在目标位置了
		_animated_sprite.position = start_position - target_position # 相对于节点的偏移
		
		var tween = create_tween()
		tween.tween_property(_animated_sprite, "position", Vector2.ZERO, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		
		await tween.finished
		_moving = false

func can_move_to_grid_direction(direction_param: Vector2i) -> bool:
	# 首先检查是否会超出边界
	var target_grid_position = grid_position + direction_param
	if is_out_of_bounds(target_grid_position):
		return false # 超出边界，不能移动
	
	_ray_cast.target_position = Vector2(direction_param * GridConfig.cell_size)
	_ray_cast.force_raycast_update()
	
	# 如果碰撞到的是SourceBlock，可以移动（因为会被吃掉）
	if _ray_cast.is_colliding():
		var collider = _ray_cast.get_collider()
		if collider.has_method("start_being_eaten"):
			return not is_moving() # 可以移动到SourceBlock位置
		return false # 碰撞到其他物体，不能移动
	
	return not is_moving() # 没有碰撞，可以移动

## 检查指定的网格位置是否超出边界
func is_out_of_bounds(grid_pos: Vector2i) -> bool:
	var grid_size = GridConfig.grid_size
	
	# 检查是否超出左右边界
	if grid_pos.x < 0 or grid_pos.x >= grid_size.x:
		return true
	
	# 检查是否超出上下边界
	if grid_pos.y < 0 or grid_pos.y >= grid_size.y:
		return true
	
	return false

func is_touching_wall() -> bool:
	return false

func check_and_eat_source_block(target_grid_position: Vector2i):
	# 使用RayCast检测目标位置的物体
	_ray_cast.target_position = Vector2((target_grid_position - grid_position) * GridConfig.cell_size)
	_ray_cast.force_raycast_update()
	
	if _ray_cast.is_colliding():
		var collider = _ray_cast.get_collider()
		if collider.has_method("start_being_eaten"):
			collider.start_being_eaten()

func reset():
	position = Vector2i(0, 0) * GridConfig.cell_size + Vector2i.ONE * GridConfig.cell_size / 2
	super ()