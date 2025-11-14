class_name Player extends Node2D

@export var mov_body: CharacterBody2D
@export var anim_sprite: AnimatedSprite2D
@export var camera: Camera2D
@export var default_camera_zoom: Vector2 = Vector2(4.0, 4.0)

@export var mov_speed: float = 150.0
var can_move: bool = true
@export var debug_movement: bool = false
var last_direction: Vector2 = Vector2.DOWN


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

	# auto-assign anim_sprite if not set
	if anim_sprite == null:
		anim_sprite = find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
		if anim_sprite != null:
			print("[Player] anim_sprite was null; auto-assigned from scene tree")
		else:
			print("[Player] WARNING: Could not find AnimatedSprite2D child")


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

	# Update last direction if moving
	if direction.length() > 0.1:
		last_direction = direction

	# Animation selection: play walk if moving, idle if stopped (using last_direction)
	if anim_sprite != null:
		var is_moving = direction.length() > 0.1
		var anim_direction = last_direction if not is_moving else direction
		var anim = "idle_down"
		
		if is_moving:
			# Prioritize horizontal over vertical for walk
			if abs(anim_direction.x) > abs(anim_direction.y):
				anim = "walk_left" if anim_direction.x < 0 else "walk_right"
			else:
				anim = "walk_up" if anim_direction.y < 0 else "walk_down"
		else:
			# Prioritize horizontal over vertical for idle
			if abs(anim_direction.x) > abs(anim_direction.y):
				anim = "idle_left" if anim_direction.x < 0 else "idle_right"
			else:
				anim = "idle_up" if anim_direction.y < 0 else "idle_down"
		
		if anim_sprite.sprite_frames != null and anim_sprite.sprite_frames.has_animation(anim):
			anim_sprite.play(anim)
		elif debug_movement:
			print("[Player] Animation '%s' not found in sprite_frames" % anim)
	elif debug_movement:
		print("[Player] anim_sprite is NULL")
