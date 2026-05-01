extends CharacterBody3D


const JUMP_VELOCITY = 4.5

const mouse_sensitivity = Vector2(.5, .2)

var speed = 3.0
var walking_speed = 3.0
var running_speed = 5.0
var running = false
var kicking = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animation_player: AnimationPlayer = $visuals/mixamo_base/AnimationPlayer
@onready var camera_mount: Node3D = $camera_mount
@onready var visuals: Node3D = $visuals

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity.x))
		visuals.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity.x))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity.y))

func _physics_process(delta: float) -> void:
	
	if !animation_player.is_playing():
		kicking = false
	
	if Input.is_action_just_pressed("kick"):
		kicking = true
		animate("kick")
	
	
	if Input.is_action_just_pressed("run"):
		running = true
		speed = running_speed
	else:
		running = false
		speed = walking_speed
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "forward", "backward")

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not kicking:
			if running:
				animate("running")
			else:
				animate("walking")
			
			visuals.look_at(position * direction)
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if not kicking:
			animate("idle")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if not kicking:
		move_and_slide()

func animate(animation: String):
	if animation_player.current_animation != animation:
		animation_player.play(animation)
