class_name GGameGlobals extends Node

static var instance: GGameGlobals = null


func _ready() -> void:
	self.name = "GGameGlobals"
	instance = self

	_create_scene_overlay()


var _scene_overlay: ColorRect = null
var _darkness_rect: ColorRect = null
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

	var darkness = ColorRect.new()
	darkness.name = "DarknessOverlay"
	darkness.color = Color(0, 0, 0, 0.85)
	darkness.set_anchors_preset(Control.PRESET_FULL_RECT)
	darkness.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
uniform vec2 light_pos : hint_range(0.0, 1.0) = vec2(0.5, 0.5);
uniform float radius : hint_range(0.0, 1.0) = 0.2;
uniform float softness : hint_range(0.0, 1.0) = 0.12;
void fragment() {
    vec2 uv = SCREEN_UV;
    float d = distance(uv, light_pos);
    float a = smoothstep(radius, radius + softness, d);
    COLOR = vec4(0.0, 0.0, 0.0, a);
}
"""

	var mat := ShaderMaterial.new()
	mat.shader = sh
	darkness.material = mat

	layer.add_child(darkness)
	layer.add_child(_scene_overlay)

	_darkness_rect = darkness


func _process(_delta: float) -> void:
	return




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
