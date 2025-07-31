extends Node
class_name SourceBlockGroupManager

signal all_blocks_settled

var _source_blocks_groups: Array[SourceBlockGroup] = []
var _parent_node: Node2D
var _was_moving_in_last_frame: bool = false

# 并查集类
class UnionFind:
	var _parent: Dictionary = {}
	var _rank: Dictionary = {}
	
	func _init(positions: Array):
		for position in positions:
			_parent[position] = position
			_rank[position] = 0
	
	func find(position: Vector2i) -> Vector2i:
		if _parent[position] != position:
			_parent[position] = find(_parent[position]) # 路径压缩
		return _parent[position]
	
	func union(pos1: Vector2i, pos2: Vector2i):
		var root1 = find(pos1)
		var root2 = find(pos2)
		
		if root1 != root2:
			# 按秩合并
			if _rank[root1] < _rank[root2]:
				_parent[root1] = root2
			elif _rank[root1] > _rank[root2]:
				_parent[root2] = root1
			else:
				_parent[root2] = root1
				_rank[root1] += 1
	
	func get_groups() -> Dictionary:
		var groups: Dictionary = {}
		
		for position in _parent.keys():
			var root = find(position)
			if not groups.has(root):
				groups[root] = []
			groups[root].append(position)
		
		return groups

func _ready():
	_parent_node = get_parent()

func _process(delta):
	for group in _source_blocks_groups:
		group.update(delta)
	
	# 检查所有blocks是否已经稳定（不在移动且在地面上）
	var are_all_blocks_settled = _are_all_blocks_settled()
	
	# 如果从移动状态变为稳定状态，发出信号
	if _was_moving_in_last_frame and are_all_blocks_settled:
		all_blocks_settled.emit()
	
	_was_moving_in_last_frame = not are_all_blocks_settled

## 检查所有SourceBlocks是否都已稳定（不在移动且在地面上）
func _are_all_blocks_settled() -> bool:
	if _source_blocks_groups.size() == 0:
		return true
	
	for group in _source_blocks_groups:
		# 如果任何一个分组还在移动或不在地面上，返回false
		if group.is_moving() or not group.is_on_floor():
			return false
	
	return true

## 使用并查集算法将相邻的SourceBlock分组
func group_source_blocks(source_blocks: Array[SourceBlock]):
	if source_blocks.size() == 0:
		return
	
	# 清空现有分组
	_source_blocks_groups.clear()
	
	# 获取所有SourceBlock的网格位置
	var positions: Array[Vector2i] = []
	for sb in source_blocks:
		positions.append(sb.grid_position)
	
	# 创建位置到SourceBlock的映射
	var position_to_block: Dictionary = {}
	for sb in source_blocks:
		position_to_block[sb.grid_position] = sb
	
	# 创建并查集
	var union_find = UnionFind.new(positions)
	
	var directions = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]
	
	# 检查每个SourceBlock的相邻位置
	for source_block in source_blocks:
		var current_pos = source_block.grid_position
		
		for direction in directions:
			var neighbor_pos = current_pos + direction
			
			# 如果相邻位置也有SourceBlock，则合并它们
			if position_to_block.has(neighbor_pos):
				union_find.union(current_pos, neighbor_pos)
	
	# 获取分组结果
	var groups = union_find.get_groups()
	
	# 为每个分组创建SourceBlockGroup
	for group in groups.values():
		var source_block_group = SourceBlockGroup.new()
		
		# 将SourceBlock添加到分组中
		for position in group:
			var source_block = position_to_block[position]
			source_block_group.add_source_block(source_block)
		
		# 只添加到分组集合，不加入场景树
		_source_blocks_groups.append(source_block_group)
	
	print("SourceBlock分组完成: 共创建了 %d 个分组" % _source_blocks_groups.size())
	
	# 打印分组详情
	var group_index = 1
	for group in _source_blocks_groups:
		var group_positions: Array[Vector2i] = []
		for sb in group.get_source_blocks():
			group_positions.append(sb.grid_position)
		print("分组 %d: 包含 %d 个SourceBlock，位置: %s" % [group_index, group_positions.size(), str(group_positions)])
		group_index += 1

## 处理SourceBlock被吃掉的事件
func handle_source_block_being_eaten(source_block: SourceBlock):
	# 找到被移除block所在的分组
	var affected_group: SourceBlockGroup = null
	for group in _source_blocks_groups:
		if group.contains_source_block(source_block):
			affected_group = group
			break
	
	# 如果找到了受影响的分组，需要检查是否分裂
	if affected_group != null:
		# 从分组中移除
		affected_group.remove_source_block(source_block)
		
		# 如果分组变空，直接移除分组
		if affected_group.is_empty():
			_source_blocks_groups.erase(affected_group)
			print("移除了空的分组")
		else:
			# 检查移除后分组是否分裂，如果是则重新分组
			_check_and_regroup_after_removal(affected_group)

## 检查并重新分组受影响的SourceBlock组
func _check_and_regroup_after_removal(affected_group: SourceBlockGroup):
	if affected_group.count() <= 1:
		return # 只有一个或没有block，无需重新分组
	
	# 获取分组中剩余的所有SourceBlock
	var remaining_blocks = affected_group.get_source_blocks().duplicate()
	
	# 移除原有分组
	_source_blocks_groups.erase(affected_group)
	
	# 使用DFS检查剩余的block是否仍然连通
	var new_groups: Array = []
	
	while remaining_blocks.size() > 0:
		# 取第一个block作为起点进行DFS
		var start_block = remaining_blocks[0]
		var connected_group: Array[SourceBlock] = []
		
		_dfs_find_connected_blocks(start_block, remaining_blocks, connected_group)
		
		if connected_group.size() > 0:
			new_groups.append(connected_group)
			# 从剩余blocks中移除已找到的连通组
			for block in connected_group:
				remaining_blocks.erase(block)
	
	# 为每个新分组创建SourceBlockGroup
	for new_group in new_groups:
		var source_block_group = SourceBlockGroup.new()
		
		# 将SourceBlock添加到分组中
		for source_block in new_group:
			source_block_group.add_source_block(source_block)
		
		# 只添加到分组集合，不加入场景树
		_source_blocks_groups.append(source_block_group)
	
	if new_groups.size() > 1:
		print("分组分裂: 原分组分裂为 %d 个新分组" % new_groups.size())
		for i in range(new_groups.size()):
			var positions: Array[Vector2i] = []
			for sb in new_groups[i]:
				positions.append(sb.grid_position)
			print("  新分组 %d: 包含 %d 个SourceBlock，位置: %s" % [i + 1, positions.size(), str(positions)])
	else:
		print("分组保持连通，无需分裂")

## 使用DFS找到与指定block连通的所有block
func _dfs_find_connected_blocks(start_block: SourceBlock, available_blocks: Array, connected_group: Array):
	if start_block not in available_blocks or start_block in connected_group:
		return
	
	connected_group.append(start_block)
	
	# 检查四个方向的相邻block
	var directions = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]
	
	for direction in directions:
		var neighbor_pos = start_block.grid_position + direction
		
		# 在可用blocks中查找相邻位置的block
		var neighbor_block: SourceBlock = null
		for block in available_blocks:
			if block.grid_position == neighbor_pos:
				neighbor_block = block
				break
		
		if neighbor_block != null and neighbor_block not in connected_group:
			_dfs_find_connected_blocks(neighbor_block, available_blocks, connected_group)