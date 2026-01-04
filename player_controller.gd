extends CharacterBody3D

@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.002

@onready var camera = $Camera3D
var sky_material: ShaderMaterial

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Find sky material
	var env = get_world_3d().environment
	if env and env.sky:
		sky_material = env.sky.sky_material

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Basic walking movement
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Re-mapping WASD to standard UI actions if not already done, or just using keys
	if input_dir == Vector2.ZERO:
		input_dir.x = Input.get_axis("KEY_A", "KEY_D")
		input_dir.y = Input.get_axis("KEY_W", "KEY_S") # Note: inverted for get_vector-like logic
	
	# Alternative manual check for WASD
	var direction = (transform.basis * Vector3(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") 
		if Input.is_action_pressed("ui_right") 
		else (1.0 
		if Input.is_key_pressed(KEY_D) 
		else 0.0) - (1.0 if Input.is_key_pressed(KEY_A) else 0.0),
		0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up") 
		if Input.is_action_pressed("ui_down") 
		else (1.0 
		if Input.is_key_pressed(KEY_S) 
		else 0.0) - (1.0 if Input.is_key_pressed(KEY_W) 
		else 0.0)
	)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	# Update sky parallax based on global camera position
	if sky_material:
		sky_material.set_shader_parameter("camera_position", camera.global_position)
