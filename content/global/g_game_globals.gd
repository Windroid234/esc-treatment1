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
