extends Node2D

func _on_return_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://content/ui/main_menu/main_menu.tscn")
