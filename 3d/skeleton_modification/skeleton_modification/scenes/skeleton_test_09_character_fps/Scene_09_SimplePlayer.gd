extends Node3D

var head_node:Node3D;
var body_node:Node3D;
var MOUSE_SENSITIVITY:float = 0.05

var bullet_scene:PackedScene = preload("res://skeleton_modification/scenes/skeleton_test_09_character_fps/Test_09_Bullet.tscn");
var gun_end:Node3D;
var fire_timer:float = 0;
const FIRE_WAIT_TIME:float = 0.2;

var gun:Node3D
var gun_shake_rotation:Vector3 = Vector3.ZERO;
var gun_shake_strength = 0.0;

var gun_animation_player:AnimationPlayer;
var current_animation = "Idle";

var random_number_generator:RandomNumberGenerator = RandomNumberGenerator.new();


func _ready():
	head_node = $Body/Head as Node3D
	body_node = $Body as Node3D;
	gun_end = $Body/Head/GunAssembly/Gun/Gun_END as Node3D;
	gun_animation_player = $Body/Head/AnimationPlayer as AnimationPlayer;
	gun = $Body/Head/GunAssembly/Gun as Node3D;

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	randomize();

func _process(delta:float):
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

	if Input.is_action_pressed("fire"):
		if (fire_timer <= 0):
			var clone = bullet_scene.instantiate();
			clone.global_transform = gun_end.global_transform;
			clone.scale = Vector3(1, 1, 1);
			#clone.linear_velocity = gun_end.global_transform.basis.get_rotation_quat().xform(Vector3(0, 0, 32));
			clone.linear_velocity = gun_end.global_transform.basis.get_rotation_quaternion() * Vector3(0, 0, 32);
			get_parent().add_child(clone);

			gun_shake_strength = 0.25;
			gun_shake_rotation.x = deg2rad(random_number_generator.randf_range(-60, 60));
			gun_shake_rotation.y = deg2rad(random_number_generator.randf_range(-60, 60));
			fire_timer = FIRE_WAIT_TIME;
	fire_timer -= delta;

	if Input.is_action_pressed("fire_alt"):
		if current_animation != "Scope":
			if gun_animation_player.is_playing() == false:
				gun_animation_player.play("Idle_To_Scope");
				current_animation = "Scope";
	else:
		if current_animation != "Idle":
			if gun_animation_player.is_playing() == false:
				gun_animation_player.play("Scope_To_Idle");
				current_animation = "Idle";

	#gun.rotation_degrees = gun_shake_rotation * gun_shake_strength;
	#gun.rotation = lerp(gun.rotation, gun_shake_rotation * gun_shake_strength, delta * 20);
	#gun.rotation_degrees = lerp(gun.rotation_degrees, gun_shake_rotation * gun_shake_strength, delta * 20);
	gun.rotation = gun.rotation.lerp(gun_shake_rotation * gun_shake_strength, delta * 20.0);

	if (gun_shake_strength > 0):
		gun_shake_strength = clamp(gun_shake_strength - (delta * 6), 0, 100);


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head_node.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		body_node.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = head_node.rotation
		camera_rot.x = clamp(camera_rot.x, deg2rad(-70), deg2rad(70))
		head_node.rotation = camera_rot
