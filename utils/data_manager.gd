class_name DataManager

const CONFIG_FILE_PATH := "user://settings.cfg"
const DEFAULT_SAVE_PATH := "user://save.sav"

## 创建一份新游戏默认运行态，供无存档或坏档时兜底使用。
static func create_new_runtime() -> RunTime:
	return RunTime.create_new()


## 将运行态序列化后写入指定存档文件。
static func save_runtime(runtime: RunTime, save_path: String = DEFAULT_SAVE_PATH) -> bool:
	if runtime == null:
		return false

	var dir_path = save_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	if save_file == null:
		return false

	save_file.store_line(JSON.stringify(runtime.to_save_dictionary()))
	return true


## 从指定存档文件读取运行态；若文件缺失或损坏则返回默认运行态。
static func load_runtime(save_path: String = DEFAULT_SAVE_PATH) -> RunTime:
	if not FileAccess.file_exists(save_path):
		return create_new_runtime()

	var save_file = FileAccess.open(save_path, FileAccess.READ)
	if save_file == null:
		return create_new_runtime()

	var parsed_data = JSON.parse_string(save_file.get_line())
	if parsed_data is Dictionary:
		return RunTime.from_save_dictionary(parsed_data)

	return create_new_runtime()

static func save_configuration() -> void :
	var config := ConfigFile.new()
	config.set_value( "audio", "music", AudioServer.get_bus_volume_linear( 2 ) )
	config.set_value( "audio", "sfx", AudioServer.get_bus_volume_linear( 3 ) )
	config.set_value( "audio", "ui", AudioServer.get_bus_volume_linear( 4 ) )
	config.save( CONFIG_FILE_PATH )

static func load_configuration() -> void:
	var config := ConfigFile.new()
	var err = config.load( CONFIG_FILE_PATH )
	
	if err != OK :
		AudioServer.set_bus_volume_linear( 2, 0.2 )
		AudioServer.set_bus_volume_linear( 3, 1.0 )
		AudioServer.set_bus_volume_linear( 4, 1.0 )
		return
	
	AudioServer.set_bus_volume_linear( 2, config.get_value( "audio", "music", 0.8 ) )
	AudioServer.set_bus_volume_linear( 3, config.get_value( "audio", "sfx", 1.0 ) )
	AudioServer.set_bus_volume_linear( 4, config.get_value( "audio", "ui", 1.0 ) )
