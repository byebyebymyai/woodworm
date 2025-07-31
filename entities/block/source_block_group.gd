extends RefCounted
class_name SourceBlockGroup

var _source_blocks: Array[SourceBlock] = []

func _init():
	pass

func update(delta: float):
	if not is_on_floor() and not is_moving():
		for block in _source_blocks:
			block.fall_async()

func add_source_block(source_block: SourceBlock):
	# 只管理逻辑分组，不改变场景树结构
	_source_blocks.append(source_block)

func remove_source_block(source_block: SourceBlock):
	# 只从逻辑分组中移除，不改变场景树结构
	_source_blocks.erase(source_block)

func contains_source_block(source_block: SourceBlock) -> bool:
	return source_block in _source_blocks

func get_source_blocks() -> Array[SourceBlock]:
	return _source_blocks

func count() -> int:
	return _source_blocks.size()

func is_empty() -> bool:
	return _source_blocks.size() == 0

func is_moving() -> bool:
	# 如果任何一个block在移动，整个分组就被视为在移动
	for block in _source_blocks:
		if block.is_moving():
			return true
	return false # 所有blocks都不在移动

func is_on_floor() -> bool:
	if _source_blocks.size() == 0:
		return false
	
	# 按列分组blocks
	var column_groups: Dictionary = {}
	
	for block in _source_blocks:
		var x = block.grid_position.x
		if not column_groups.has(x):
			column_groups[x] = []
		column_groups[x].append(block)
	
	for column in column_groups.values():
		# 找到该列最下方的block（Y坐标最大）
		var bottom_block = column[0]
		for block in column:
			if block.grid_position.y > bottom_block.grid_position.y:
				bottom_block = block
		
		if bottom_block.is_on_floor():
			return true
	
	return false