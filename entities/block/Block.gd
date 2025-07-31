extends StaticBody2D
class_name Block

var grid_position: Vector2i

var _background_sprite: Sprite2D
var _collision_shape: CollisionShape2D
var _rectangle_shape: RectangleShape2D
var _gravity_ray_cast: RayCast2D

var _moving: bool = false

@export var animation_speed: float = 5.0

func _init(grid_pos: Vector2i):
	grid_position = grid_pos
	var global_position_calculated = GridConfig.grid_to_global_position(grid_position)
	position = global_position_calculated
	
	collision_layer = CollisionLayers.WALLS
	collision_mask = 0
	
	_rectangle_shape = RectangleShape2D.new()
	_rectangle_shape.size = Vector2(GridConfig.cell_size)
	_collision_shape = CollisionShape2D.new()
	_collision_shape.shape = _rectangle_shape
	_collision_shape.position = Vector2(GridConfig.cell_size) / 2
	add_child(_collision_shape)
	
	_gravity_ray_cast = RayCast2D.new()
	_gravity_ray_cast.position = Vector2(GridConfig.cell_size) / 2
	_gravity_ray_cast.target_position = Vector2(0, GridConfig.cell_size.y)
	_gravity_ray_cast.collision_mask = CollisionLayers.ALL
	add_child(_gravity_ray_cast)
	
	setup_tile_background()

func setup_tile_background():
	# 这个方法应该在子类中被重写
	pass

func setup_background_sprite(texture: Texture2D, region: Rect2):
	# 创建 Sprite2D 作为背景
	_background_sprite = Sprite2D.new()
	
	# 设置纹理和区域
	_background_sprite.texture = texture
	_background_sprite.region_enabled = true
	_background_sprite.region_rect = region
	
	# 设置位置和缩放
	_background_sprite.position = Vector2(GridConfig.cell_size) / 2
	_background_sprite.scale = Vector2(GridConfig.cell_size) / region.size
	
	add_child(_background_sprite)

func is_moving() -> bool:
	return _moving

func fall_async():
	var target_position = position + Vector2(0, GridConfig.cell_size.y)
	grid_position += Vector2i.DOWN
	
	_moving = true
	
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	
	_moving = false

func is_on_floor() -> bool:
	_gravity_ray_cast.target_position = Vector2(0, GridConfig.cell_size.y)
	_gravity_ray_cast.force_raycast_update()
	return _gravity_ray_cast.is_colliding()