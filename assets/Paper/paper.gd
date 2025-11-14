class_name Paper
extends Area2D

signal picked_up(paper_id: int)

@export var paper_id: int = 0
@export var description: String = ""
var _picked: bool = false

func _ready() -> void:
	# Connect to Area2D body_entered to detect player stepping on the paper
	print("[Paper] ready: id=", paper_id, " pos=", global_position)
	# Ensure monitoring is enabled so we receive body_entered
	monitoring = true
	monitorable = true
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		self.connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		self.connect("area_entered", Callable(self, "_on_area_entered"))

func _on_body_entered(body: Node) -> void:
	# Accept CharacterBody2D player or any node on the player collision layer
	# Prefer explicit Player class check if available
	if body == null:
		return
	if _picked:
		return
	print("[Paper] body_entered: id=", paper_id, " body=", body, " body_type=", typeof(body))
	# Primary: CharacterBody2D (player)
	if body is CharacterBody2D:
		_picked = true
		emit_signal("picked_up", paper_id)
		if GGameGlobals.instance != null:
			GGameGlobals.instance.register_paper_pickup(paper_id)
		queue_free()
		return
	# fallback: detect by name
	var lower_name := ""
	if body.has_method("get_name"):
		lower_name = body.name.to_lower()
	if lower_name.find("player") != -1:
		_picked = true
		emit_signal("picked_up", paper_id)
		if GGameGlobals.instance != null:
			GGameGlobals.instance.register_paper_pickup(paper_id)
		queue_free()
		return
	# otherwise ignore

func _on_area_entered(area: Area2D) -> void:
	print("[Paper] area_entered: id=", paper_id, " area=", area)
	# if an Area overlaps (e.g., player uses Area), try to resolve parent node
	if _picked:
		return
	var parent_node := area.get_parent()
	if parent_node != null:
		_on_body_entered(parent_node)


func _physics_process(_delta: float) -> void:
	# Fallback: if physics signals aren't firing, detect the player by proximity.
	# This makes the pickup robust to layer/mask misconfiguration during testing.
	if _picked or GEntityAdmin.player == null:
		return
	var player_pos := GEntityAdmin.player.global_position
	var dist := player_pos.distance_to(global_position)
	# threshold tuned to sprite size; adjust if needed
	if dist <= 20.0:
		print("[Paper] proximity pickup: id=", paper_id, " dist=", dist)
		# Call the same handler as if the player entered; don't pre-mark _picked here
		# because _on_body_entered will mark it. This avoids blocking the handler.
		_on_body_entered(GEntityAdmin.player)
