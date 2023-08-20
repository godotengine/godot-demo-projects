extends CharacterBody3D

@onready var player_camera =  $camera
@onready var animplay = $visual/mixamo_base/AnimationPlayer
@onready var visual = $visual
const SPEED = 2.8
const JUMP_VELOCITY = 4.5

var mouse_senstivity = .25
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_senstivity))
		visual.rotate_y(deg_to_rad(event.relative.x * mouse_senstivity))
		player_camera.rotate_x(deg_to_rad(-event.relative.y * mouse_senstivity))
		

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		animplay.play("idle")
		

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if animplay.current_animation != "walking":
			animplay.play("walking")
			
		visual.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animplay.current_animation != "idle":
			animplay.play("idle")
	
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
