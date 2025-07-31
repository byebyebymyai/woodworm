extends WoodwormNode

func _ready():
	super ()

func set_grid_orientation():
	grid_orientation = orientation
	
	if orientation != direction:
		_animated_sprite.rotation = 0
		if orientation == Vector2i.UP and direction == Vector2i.RIGHT:
			var animation_name = "alt-2"
			_animated_sprite.play(animation_name)
			_animated_sprite.flip_v = true
			_animated_sprite.flip_h = true
		elif orientation == Vector2i.RIGHT and direction == Vector2i.UP:
			var animation_name = "alt-1"
			_animated_sprite.play(animation_name)
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = false
		elif orientation == Vector2i.LEFT and direction == Vector2i.UP:
			var animation_name = "alt-1"
			_animated_sprite.play(animation_name)
			_animated_sprite.flip_h = true
			_animated_sprite.flip_v = false
		elif orientation == Vector2i.DOWN and direction == Vector2i.LEFT:
			var animation_name = "alt-1"
			_animated_sprite.play(animation_name)
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = false
		elif orientation == Vector2i.RIGHT and direction == Vector2i.DOWN:
			var animation_name = "alt-2"
			_animated_sprite.play(animation_name)
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = true
		elif orientation == Vector2i.UP and direction == Vector2i.LEFT:
			var animation_name = "alt-2"
			_animated_sprite.play(animation_name)
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = true
		elif orientation == Vector2i.DOWN and direction == Vector2i.RIGHT:
			var animation_name = "alt-1"
			_animated_sprite.play(animation_name)
			_animated_sprite.flip_h = true
			_animated_sprite.flip_v = false
		elif orientation == Vector2i.LEFT and direction == Vector2i.DOWN:
			var animation_name = "alt-2"
			_animated_sprite.play(animation_name)
			_animated_sprite.flip_h = true
			_animated_sprite.flip_v = true
		else:
			var animation_name = "alt-1"
			_animated_sprite.play(animation_name)
			_animated_sprite.flip_h = false
			_animated_sprite.flip_v = false
	else:
		# 使用默认动画
		var animation_name = "default"
		_animated_sprite.play(animation_name)
		super.set_grid_orientation()
	
	direction = Vector2i.ZERO
	orientation = Vector2i.ZERO

func reset():
	position = Vector2i(-1, 0) * GridConfig.cell_size + Vector2i.ONE * GridConfig.cell_size / 2
	super ()