class_name Player extends Node2D

@export var mov_body: CharacterBody2D
@export var sprite: Sprite2D
@export var camera: Camera2D
@export var default_camera_zoom: Vector2 = Vector2(4.0, 4.0)

var mov_speed: float = 300.0
var can_move: bool = true
@export var debug_movement: bool = false


func _ready() -> void:
	self.name = "Player"
	GEntityAdmin.register_entity(self)
	var spawn_point = get_parent().find_child("SpawnPoint", true, false)
	if spawn_point != null:
		global_position = spawn_point.global_position
	
	if camera != null:
		camera.zoom = default_camera_zoom

	# safety: ensure mov_body is assigned (some instancing can leave it null)
	if mov_body == null:
		var self_node := get_node(".") as CharacterBody2D
		if self_node != null:
			mov_body = self_node
			if debug_movement:
				print("[Player] mov_body was null in _ready(); auto-assigned to self")


func _physics_process(_delta: float) -> void:
	if mov_body == null or not can_move:
		if debug_movement:
			if mov_body == null:
				print("[Player] mov_body is NULL — cannot move")
			else:
				print("[Player] can_move is false — movement disabled")
		return

	var direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	if debug_movement:
		print("[Player] direction=", direction, " normalized=", direction.normalized())
	mov_body.velocity = direction.normalized() * mov_speed
	mov_body.move_and_slide()
