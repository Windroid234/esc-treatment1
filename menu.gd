extends Control




func _on_start_pressed() -> void:
	# Before leaving the menu, restore the global dim so gameplay scenes have the intended look.
	if GGameGlobals.instance != null:
		GGameGlobals.instance.set_global_dim(true)
	get_tree().change_scene_to_file("res://test.tscn")
	
	


func _on_quit_pressed() -> void:
	get_tree().quit()


func _ready() -> void:
	# Disable the global dimming so the menu appears at full brightness.
	if GGameGlobals.instance != null:
		GGameGlobals.instance.set_global_dim(false)
