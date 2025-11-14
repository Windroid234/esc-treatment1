class_name GGameGlobals extends Node

static var instance: GGameGlobals = null


func _ready() -> void:
	self.name = "GGameGlobals"
	instance = self

	_create_scene_overlay()


var _scene_overlay: ColorRect = null
var _light_sprite: Sprite2D = null
var _canvas_modulate: CanvasModulate = null
const FADE_TIME: float = 0.25

# Paper / collectible tracking (level-local, simple global helper)
var _papers_found: Dictionary = {}
var papers_total: int = 3
var puzzle_papers_completed: bool = false
var _paper_auto_counter: int = 1



func _create_scene_overlay() -> void:
	var layer = CanvasLayer.new()
	layer.name = "SceneFadeLayer"
	layer.layer = 100
	add_child(layer)

	_scene_overlay = ColorRect.new()
	_scene_overlay.name = "SceneFadeOverlay"
	_scene_overlay.color = Color(0, 0, 0, 0)
	_scene_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scene_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	layer.add_child(_scene_overlay)

	var canvas_mod = CanvasModulate.new()
	canvas_mod.color = Color(0.3, 0.3, 0.3, 1.0)
	add_child(canvas_mod)
	_canvas_modulate = canvas_mod

	var light_circle = Sprite2D.new()
	light_circle.name = "LightHalo"
	light_circle.scale = Vector2(2.0, 2.0)
	light_circle.self_modulate = Color(1, 1, 1, 0.6)
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "LightLayer"
	canvas_layer.layer = 50
	canvas_layer.add_child(light_circle)
	add_child(canvas_layer)
	_light_sprite = light_circle


func _process(_delta: float) -> void:
	if _light_sprite == null or GEntityAdmin.player == null:
		return
	_light_sprite.global_position = GEntityAdmin.player.global_position


## Register that a paper with [paper_id] has been collected.
## This is intentionally lightweight: it updates an internal counter,
## shows a quick popup, and sets a completion flag when all are found.
func register_paper_pickup(paper_id: int) -> void:
	if puzzle_papers_completed:
		return
	# support unassigned/default paper_id (0) by generating an internal unique key
	var key
	if paper_id <= 0:
		key = "__auto_%d" % _paper_auto_counter
		_paper_auto_counter += 1
	else:
		key = paper_id

	if _papers_found.has(key):
		return

	_papers_found[key] = true
	var found_count := _papers_found.keys().size()
	# Log and show small popup
	GLogger.log("Paper found: %s (%d/%d)" % [str(paper_id), found_count, papers_total], Color(0.2, 0.6, 1.0))
	_show_paper_popup(found_count)
	if found_count >= papers_total:
		puzzle_papers_completed = true
		_on_all_papers_found()


func _show_paper_popup(found_count: int) -> void:
	if _scene_overlay == null:
		return
	# Create a temporary label on the SceneFadeLayer (top layer)
	var layer := get_node_or_null("SceneFadeLayer")
	if layer == null:
		layer = _scene_overlay.get_parent()
	var lbl := Label.new()
	lbl.name = "PaperPopup"
	lbl.text = "Paper: %d/%d" % [found_count, papers_total]
	lbl.modulate = Color(1,1,1,0)
	# place near the top center-ish (use global_position on Control to avoid invalid property on Label)
	lbl.global_position = Vector2(10, 10)
	layer.add_child(lbl)

	var tw = lbl.create_tween()
	tw.tween_property(lbl, "modulate:a", 1.0, 0.15)
	tw.tween_interval(1.0)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.connect("finished", Callable(lbl, "queue_free"))


func show_notice(text: String, duration: float = 1.5) -> void:
	# Generic small notice centered near bottom of screen
	if _scene_overlay == null:
		return
	var layer := get_node_or_null("SceneFadeLayer")
	if layer == null:
		layer = _scene_overlay.get_parent()
	if layer == null:
		layer = self

	var lbl := Label.new()
	lbl.name = "Notice"
	lbl.text = text
	lbl.modulate = Color(1,1,1,0)
	# smaller font and center bottom
	lbl.scale = Vector2(1.2, 1.2)
	var vp_rect := get_viewport().get_visible_rect()
	lbl.global_position = vp_rect.position + Vector2(vp_rect.size.x * 0.5 - 120, vp_rect.size.y * 0.75)
	layer.add_child(lbl)

	var tw = lbl.create_tween()
	tw.tween_property(lbl, "modulate:a", 1.0, 0.15)
	tw.tween_interval(duration)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.connect("finished", Callable(lbl, "queue_free"))


func _on_all_papers_found() -> void:
	GLogger.log("All papers found! Puzzle complete.", Color(1.0, 0.84, 0.0))
	# Show a centered completion splash and provide a hook for extra behavior (open door, trigger event)
	_show_completion_splash()


func _show_completion_splash() -> void:
	# Create a centered large label on the SceneFadeLayer
	var layer := get_node_or_null("SceneFadeLayer")
	if layer == null:
		layer = _scene_overlay.get_parent()
	if layer == null:
		# fallback to adding to this node
		layer = self

	var lbl := Label.new()
	lbl.name = "CompletionSplash"
	lbl.text = "Congratulations — you've collected them all. You can now leave."
	lbl.modulate = Color(1,1,1,0)
	# make it visually prominent
	lbl.scale = Vector2(2.0, 2.0)

	# place at screen center
	var vp_rect := get_viewport().get_visible_rect()
	var center := vp_rect.size * 0.5 + vp_rect.position
	lbl.global_position = center - Vector2(0, 0)

	layer.add_child(lbl)

	var tw = lbl.create_tween()
	# pop-in scale and fade
	lbl.scale = lbl.scale * 0.8
	tw.tween_property(lbl, "modulate:a", 1.0, 0.25)
	tw.tween_property(lbl, "scale", Vector2(1.05, 1.05), 0.25)
	tw.tween_interval(2.0)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.connect("finished", Callable(lbl, "queue_free"))




func fade_and_change_scene(path: String) -> void:
	await _fade_out()
	var err = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("GGameGlobals: Failed to change scene to %s (error: %d)" % [path, err])
	await _fade_in()


func _fade_out() -> void:
	_scene_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw = _scene_overlay.create_tween()
	tw.tween_property(_scene_overlay, "color:a", 1.0, FADE_TIME)
	await tw.finished


func _fade_in() -> void:
	var tw = _scene_overlay.create_tween()
	tw.tween_property(_scene_overlay, "color:a", 0.0, FADE_TIME)
	await tw.finished
	_scene_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
