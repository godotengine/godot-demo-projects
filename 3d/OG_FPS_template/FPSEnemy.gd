extends RigidBody

class_name FPSEnemy

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(float) var recovery_time = 0.2;
export(float) var max_hp = 100;
export(float) var decel_multiplier = 0.8;
export(Color) var hit_colour = Color(1,0,0,1);

var recovering = false;
var recovery_timer = 0;
var base_colour;
var hp = 100;
var velocity = Vector3();
var enemy_sprite;

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_sprite = get_node("Sprite3D");
	base_colour = enemy_sprite.modulate;
	pass # Replace with function body.

func take_damage(var damage, var direction, var knockback):
	# take the damage
	hp -= damage;
	# react to the damage
	enemy_sprite.modulate = hit_colour;
	velocity += -direction.normalized() * knockback;
	recovering = true;
	recovery_timer = 0;
	pass
	

func _physics_process(delta):
	if (recovering):
		recovery_timer += delta;
		if (recovery_timer >= recovery_time):
			recovering = false;
			enemy_sprite.modulate = base_colour;
			recovery_timer = 0;
	if (velocity.length() < 0.001):
		velocity = Vector3(rand_range(-1000,1000), 0, rand_range(-1000,1000));
	velocity *= decel_multiplier;
	apply_central_impulse(velocity * delta);	
	pass
	
func TimerTimeout():
	print("t");
