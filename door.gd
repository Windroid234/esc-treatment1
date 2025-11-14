extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("[door] _on_body_entered fired. body=", body, " name=", body.name, " class=", body.get_class())
	if not (body is Player):
		print("[door] Ignoring - entering body is not Player")
		return
	print("[door] Player detected. Requesting fade transition to room_1.tscn...")
	if GGameGlobals.instance != null:
		GGameGlobals.instance.fade_and_change_scene("res://room_1.tscn")
	else:
		var err = get_tree().change_scene_to_file("res://room_1.tscn")
		print("[door] change_scene_to_file returned:", err)
		if err != OK:
			push_error("[door] Failed to change scene to res://room_1.tscn (error: %d)" % err)
