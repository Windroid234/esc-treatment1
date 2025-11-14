extends Area2D

@export var target_scene: String = "res://room_1.tscn"
@export var block_until_papers: bool = false


func _on_body_entered(body: Node2D) -> void:
	print("[door] (door.gd) script=", self.get_script().resource_path)
	print("[door] _on_body_entered fired. body=", body, " name=", body.name, " class=", body.get_class())
	if not (body is Player):
		print("[door] Ignoring - entering body is not Player")
		return

	# Only block if this door instance is configured to block until papers are found.
	if block_until_papers:
		# Treat missing GGameGlobals.instance as not completed to avoid accidental bypass.
		var puzzle_done := false
		if GGameGlobals.instance != null:
			puzzle_done = GGameGlobals.instance.puzzle_papers_completed
		else:
			print("[door] Warning: GGameGlobals.instance is null — treating as not completed")
		print("[door] puzzle_papers_completed=", puzzle_done)
		if not puzzle_done:
			if GGameGlobals.instance != null:
				GGameGlobals.instance.show_notice("Please find all papers")
			else:
				print("[door] Player tried to leave but puzzle not completed")
			return

	print("[door] Player detected. Requesting fade transition to %s..." % target_scene)
	if GGameGlobals.instance != null:
		GGameGlobals.instance.fade_and_change_scene(target_scene)
	else:
		var err = get_tree().change_scene_to_file(target_scene)
		print("[door] change_scene_to_file returned:", err)
		if err != OK:
			push_error("[door] Failed to change scene to %s (error: %d)" % [target_scene, err])
