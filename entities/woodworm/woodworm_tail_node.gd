extends WoodwormNode

func _ready():
	super ()

func is_touching_floor() -> bool:
	_gravity_ray_cast.position = Vector2.ZERO
	_gravity_ray_cast.target_position = Vector2(0, GridConfig.cell_size.y)
	_gravity_ray_cast.force_raycast_update()
	return _gravity_ray_cast.is_colliding()

func reset():
	position = Vector2i(-2, 0) * GridConfig.cell_size + Vector2i.ONE * GridConfig.cell_size / 2
	super ()
