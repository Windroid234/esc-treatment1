class_name Player extends Node2D

@export var mov_body: CharacterBody2D
@export var sprite: Sprite2D
@export var camera: Camera2D

var mov_speed: float = 300.0
var can_move: bool = true


func _ready() -> void:
	self.name = "Player"
	GEntityAdmin.register_entity(self)
	var spawn_point = get_parent().find_child("SpawnPoint", true, false)
	if spawn_point != null:
		global_position = spawn_point.global_position
	
	if camera != null:
		camera.zoom = Vector2(2.5, 2.5)


func _physics_process(_delta: float) -> void:
	if mov_body == null or not can_move:
		return
	
	var direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	mov_body.velocity = direction.normalized() * mov_speed
	mov_body.move_and_slide()
