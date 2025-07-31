extends Node2D

var head: WoodwormNode
var body: WoodwormNode
var tail: WoodwormNode

var _direction_history: Array[Vector2i] = []

var left_orientation: bool = false

func _ready():
	head = get_node("Head") as WoodwormNode
	body = get_node("Body") as WoodwormNode
	tail = get_node("Tail") as WoodwormNode


	# 位置初始化到最接近的格子中心
	# head.global_position = GridSizeConfig.instance.world_to_nearest_world(head.global_position)
	# print("Head.Position: " + str(head.position))
	# body.global_position = GridSizeConfig.instance.world_to_nearest_world(body.global_position)
	# print("Body.Position: " + str(body.position))
	# tail.global_position = GridSizeConfig.instance.world_to_nearest_world(tail.global_position)
	# print("Tail.Position: " + str(tail.position))
	_direction_history.append(Vector2i(1, 0))
	_direction_history.append(Vector2i(1, 0))

func _process(delta):
	if not is_on_floor() and not is_moving() and not is_on_wall():
		head.fall_async()
		body.fall_async()
		tail.fall_async()
	
	if not is_moving():
		if Input.is_action_just_pressed("ui_up"):
			move_to_grid_direction_async(Vector2i.UP, delta)
		if Input.is_action_just_pressed("ui_down"):
			move_to_grid_direction_async(Vector2i.DOWN, delta)
		if Input.is_action_just_pressed("ui_left"):
			move_to_grid_direction_async(Vector2i.LEFT, delta)
		if Input.is_action_just_pressed("ui_right"):
			move_to_grid_direction_async(Vector2i.RIGHT, delta)

func move_to_grid_direction_async(direction_param: Vector2i, delta: float):
	if not head.can_move_to_grid_direction(direction_param) or is_moving():
		return
	
	if direction_param == Vector2i.LEFT:
		left_orientation = true
	if direction_param == Vector2i.RIGHT:
		left_orientation = false
	
	# 设置所有节点的参数
	head.direction = direction_param
	head.orientation = direction_param
	head.on_left_wall = left_orientation
	_direction_history.append(direction_param)
	
	body.orientation = direction_param
	direction_param = _direction_history.pop_front()
	body.direction = direction_param
	body.on_left_wall = left_orientation
	_direction_history.append(direction_param)
	
	tail.orientation = direction_param
	direction_param = _direction_history.pop_front()
	tail.direction = direction_param
	tail.on_left_wall = left_orientation
	
	# 同时启动并等待三个异步任务完成
	await _move_all_parts_async(delta)

# 并发执行所有部位的移动动画  
func _move_all_parts_async(delta: float):
	# 同时启动三个异步任务
	call_deferred("_move_head_async", delta)
	call_deferred("_move_body_async", delta)
	call_deferred("_move_tail_async", delta)
	
	# 等待所有部分完成移动
	while head.is_moving() or body.is_moving() or tail.is_moving():
		await get_tree().process_frame

# 头部移动的异步包装
func _move_head_async(delta: float):
	await head.move_and_slide_async(delta)

# 身体移动的异步包装  
func _move_body_async(delta: float):
	await body.move_and_slide_async(delta)

# 尾部移动的异步包装
func _move_tail_async(delta: float):
	await tail.move_and_slide_async(delta)

func is_moving() -> bool:
	return head.is_moving() or body.is_moving() or tail.is_moving()

func is_on_wall() -> bool:
	return head.is_touching_floor() or body.is_touching_floor() or tail.is_touching_floor()

func is_on_floor() -> bool:
	return head.is_touching_wall() or body.is_touching_wall() or tail.is_touching_wall()

## 重置虫子到初始状态
func reset(initial_position: Vector2):
	# 设置虫子整体位置
	position = initial_position
	
	# 重置各个部分到初始位置和状态
	head.reset()
	body.reset()
	tail.reset()
	
	# 重置方向历史
	_direction_history.clear()
	_direction_history.append(Vector2i(1, 0))
	_direction_history.append(Vector2i(1, 0))
	
	# 重置朝向
	left_orientation = false
