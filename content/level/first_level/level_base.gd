class_name LevelBase extends Node

signal time_changed()


@export var level_modulate: CanvasModulate

var time_elapsed: int = 0
var hold_time: bool = false

func _ready() -> void:
	var level_timer := Timer.new()

	level_timer.wait_time = 1
	level_timer.one_shot = false;
	level_timer.connect("timeout", update_time)
	add_child(level_timer)
	level_timer.start()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		print("ESC pressed - returning to main menu")
		get_tree().change_scene_to_file("res://content/ui/main_menu/main_menu.tscn")

## Update the time elapsed.
func update_time() -> void:
	if hold_time:
		return

	time_elapsed += 1
	time_changed.emit()


## Returns the elapsed time as a string.
func get_time_string() -> String:
	@warning_ignore("integer_division")
	return "%02d:%02d" % [time_elapsed / 60, time_elapsed % 60]

	#GPostProcessing.fade_from_black()
