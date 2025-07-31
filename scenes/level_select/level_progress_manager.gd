extends Node

const SAVE_FILE_PATH = "user://level_progress.save"
var _level_completed_status: Dictionary = {}

func _ready():
	load_progress()

## 检查关卡是否已完成
func is_level_completed(level_name: String) -> bool:
	return _level_completed_status.get(level_name, false)

## 标记关卡为已完成
func mark_level_completed(level_name: String):
	_level_completed_status[level_name] = true
	save_progress()
	print("关卡 %s 已完成！" % level_name)

## 获取总完成关卡数量
func get_completed_level_count() -> int:
	var count = 0
	for completed in _level_completed_status.values():
		if completed:
			count += 1
	return count

## 重置所有进度（用于调试）
func reset_all_progress():
	_level_completed_status.clear()
	save_progress()
	print("所有关卡进度已重置")

## 保存进度到文件
func save_progress():
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file != null:
		var save_data = {}
		for key in _level_completed_status:
			save_data[key] = _level_completed_status[key]
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		print("关卡进度已保存")

## 从文件加载进度
func load_progress():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("未找到保存文件，使用默认进度")
		return
	
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if save_file != null:
		var json_string = save_file.get_as_text()
		save_file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK and json.data is Dictionary:
			var save_data = json.data as Dictionary
			_level_completed_status.clear()
			
			for key in save_data.keys():
				if key is String and save_data[key] is bool:
					_level_completed_status[key] = save_data[key]
			
			print("已加载关卡进度，共 %d 个关卡已完成" % get_completed_level_count())