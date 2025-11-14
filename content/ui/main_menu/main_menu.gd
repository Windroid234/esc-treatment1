extends CanvasLayer



func _on_play_button_pressed():
	print("start")
	get_tree().change_scene_to_file("res://content/level/first_level/first_level.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
