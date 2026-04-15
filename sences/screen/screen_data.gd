class_name ScreenData

## 标记切到下一个界面时，要执行哪一种进入流程。
enum EnterMode {
	NONE,
	NEW_GAME,
	LOAD_GAME,
}

var run: RunTime = RunTime.create_new()
var slot: int = -1
var enter_mode: EnterMode = EnterMode.NONE


## 构建一份新的界面传参对象。
static func build() -> ScreenData:
	return ScreenData.new()


## 传递运行态对象。
func set_run(context_run: RunTime) -> ScreenData:
	run = context_run
	return self


## 记录被选中的存档槽位。
func set_slot(context_slot: int) -> ScreenData:
	slot = context_slot
	return self


## 标记进入游戏界面后应该执行的新游戏或读档流程。
func set_enter_mode(context_enter_mode: EnterMode) -> ScreenData:
	enter_mode = context_enter_mode
	return self
