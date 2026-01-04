extends Camera3D

@export var move_speed: float = 10.0
@export var look_sensitivity: float = 0.002

var rotation_x: float = 0.0
var rotation_y: float = 0.0
var sky_material: ShaderMaterial

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Try to find the sky material to update parallax
	var env = get_viewport().world_3d.environment
	if env and env.sky:
		sky_material = env.sky.sky_material

func _input(event):
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.y * look_sensitivity
		rotation_y -= event.relative.x * look_sensitivity
		rotation_x = clamp(rotation_x, -PI/2, PI/2)
		transform.basis = Basis.from_euler(Vector3(rotation_x, rotation_y, 0))
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	var direction = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		direction -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		direction += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		direction -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		direction += transform.basis.x
	if Input.is_key_pressed(KEY_E):
		direction += transform.basis.y
	if Input.is_key_pressed(KEY_Q):
		direction -= transform.basis.y
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		position += direction * move_speed * delta
		
	# Update the sky shader with the current camera position
	if sky_material:
		sky_material.set_shader_parameter("camera_position", position)
