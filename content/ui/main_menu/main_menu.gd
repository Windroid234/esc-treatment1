extends CanvasLayer


func _ready() -> void:
	print("MainMenu _ready called - START")
	print("Trying to find buttons...")
	print("get_child_count: ", get_child_count())
	
	var play_button: Button = null
	var quit_button: Button = null
	
	if has_node("ButtonsBox/PlayButton"):
		play_button = get_node("ButtonsBox/PlayButton") as Button
		print("PlayButton found: ", play_button)
	else:
		print("FAILED to find PlayButton at ButtonsBox/PlayButton")
		print("Available children of self: ", get_children())
		if has_node("ButtonsBox"):
			var buttons_box = get_node("ButtonsBox")
			print("ButtonsBox children: ", buttons_box.get_children())
	
	if has_node("ButtonsBox/QuitButton"):
		quit_button = get_node("ButtonsBox/QuitButton") as Button
		print("QuitButton found: ", quit_button)
	else:
		print("FAILED to find QuitButton at ButtonsBox/QuitButton")
	
	if play_button:
		play_button.pressed.connect(play_pressed)
		print("PlayButton signal connected")
	
	if quit_button:
		quit_button.pressed.connect(quit_pressed)
		print("QuitButton signal connected")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Mouse clicked at: ", event.position)


func play_pressed() -> void:
	print("Play button pressed!")
	print("Current scene: ", get_tree().current_scene)
	print("Attempting scene change...")
	var error = get_tree().change_scene_to_file("res://content/level/first_level/first_level.tscn")
	print("Scene change returned: ", error)
	if error != OK:
		print("Scene change error: ", error)


func quit_pressed() -> void:
	print("Quit button pressed!")
	get_tree().quit()
