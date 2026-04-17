class_name DataManager

const CONFIG_FILE_PATH := "user://settings.cfg"
const DEFAULT_SAVE_PATH := "user://save.sav"
const AUDIO_CONFIG_SECTION := "audio"


## 创建一份新的默认运行时数据，供新游戏或坏档兜底时使用。
static func create_new_runtime() -> RunTime:
	return RunTime.create_new()


## 把运行时数据序列化后写入指定存档文件。
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


## 从指定存档文件读取运行时数据；如果文件缺失或损坏，则回退到默认运行时。
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


## 保存当前三条音频总线的线性音量。
## 这里统一按总线名读取，避免后续调整 bus 顺序后把配置写到错误的索引上。
static func save_configuration() -> void:
	var config := ConfigFile.new()
	config.set_value(AUDIO_CONFIG_SECTION, "music", _get_bus_volume_linear(&"Music"))
	config.set_value(AUDIO_CONFIG_SECTION, "sfx", _get_bus_volume_linear(&"SFX"))
	config.set_value(AUDIO_CONFIG_SECTION, "ui", _get_bus_volume_linear(&"UI"))
	config.save(CONFIG_FILE_PATH)


## 读取玩家保存的音量配置。
## 如果配置文件不存在或缺少某个键，就沿用 bus layout 当前已经生效的默认值，
## 避免再维护一套容易和默认布局漂移的魔法数字。
static func load_configuration() -> void:
	var config := ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)

	if err != OK:
		save_configuration()
		return

	_set_bus_volume_linear(&"Music", config.get_value(AUDIO_CONFIG_SECTION, "music", _get_bus_volume_linear(&"Music")))
	_set_bus_volume_linear(&"SFX", config.get_value(AUDIO_CONFIG_SECTION, "sfx", _get_bus_volume_linear(&"SFX")))
	_set_bus_volume_linear(&"UI", config.get_value(AUDIO_CONFIG_SECTION, "ui", _get_bus_volume_linear(&"UI")))


## 按总线名读取当前线性音量，作为配置缺省值和保存值的统一入口。
static func _get_bus_volume_linear(bus_name: StringName) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return 1.0

	return AudioServer.get_bus_volume_linear(bus_index)


## 按总线名写入线性音量。
static func _set_bus_volume_linear(bus_name: StringName, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return

	AudioServer.set_bus_volume_linear(bus_index, value)
