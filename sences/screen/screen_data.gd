class_name ScreenData

var run : RunTime = RunTime.create_new()
var slot : int 

static func build() -> ScreenData:
	return ScreenData.new()

func set_run( context_run : RunTime ) -> ScreenData:
	run = context_run
	return self

func set_slot( context_slot : int ) -> ScreenData:
	slot = context_slot
	return self
